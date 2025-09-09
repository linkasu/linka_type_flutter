import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YandexVoice {
  final String voiceURI;
  final String text;
  
  YandexVoice({required this.voiceURI, required this.text});
}

class TTSVoice {
  final String voiceURI;
  final String text;
  final String? locale;
  final bool isDefault;
  
  TTSVoice({
    required this.voiceURI,
    required this.text,
    this.locale,
    this.isDefault = false,
  });
}

class TTSService {
  static TTSService? _instance;
  static TTSService get instance {
    _instance ??= TTSService._();
    return _instance!;
  }
  
  late SharedPreferences _prefs;
  
  final StreamController<String> _eventController = StreamController<String>.broadcast();
  Stream<String> get events => _eventController.stream;
  
  // Последняя ошибка для копирования
  String? _lastError;
  String? get lastError => _lastError;
  
  bool _isInitialized = false;
  bool _useYandex = true; // По умолчанию используем Яндекс
  TTSVoice? _currentVoice;
  AudioPlayer? _audioPlayer;
  FlutterTts? _flutterTts;
  
  TTSService._() {
    _init();
  }
  
  Future<void> _init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    _useYandex = await getUseYandex();
    _currentVoice = await getSelectedVoice();
    
    // Инициализируем AudioPlayer
    _audioPlayer = AudioPlayer();
    
    // Инициализируем FlutterTts для нативного TTS (только для поддерживаемых платформ)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS)) {
      _flutterTts = FlutterTts();
      
      try {
        // Настраиваем FlutterTts
        await _flutterTts?.setLanguage("ru-RU");
        await _flutterTts?.setSpeechRate(await getRate());
        await _flutterTts?.setVolume(await getVolume());
        await _flutterTts?.setPitch(await getPitch());
        
        // Устанавливаем обработчики событий
        _flutterTts?.setStartHandler(() {
          _eventController.add('start');
        });
        
        _flutterTts?.setCompletionHandler(() {
          _eventController.add('end');
        });
        
        _flutterTts?.setErrorHandler((msg) {
          _lastError = msg;
          _eventController.add('error: $msg');
        });
        
        // Проверяем доступность голосов на macOS
        if (Platform.isMacOS) {
          final voices = await getOfflineVoices();
          
          // Устанавливаем русский голос по умолчанию для macOS
          if (voices.isNotEmpty) {
            final russianVoice = voices.firstWhere(
              (voice) => voice.locale?.startsWith('ru') == true,
              orElse: () => voices.first,
            );
            
            if (russianVoice.locale?.startsWith('ru') == true) {
              await _flutterTts?.setVoice({
                "name": russianVoice.voiceURI,
                "locale": russianVoice.locale ?? "ru-RU"
              });
            }
          }
        }
              } catch (e) {
          _lastError = 'Ошибка инициализации FlutterTts: $e';
        }
    }
    
    _isInitialized = true;
  }
  
  Future<void> say(String text, {bool download = false}) async {
    if (text.isEmpty) return;
    
    await _init();
    
    if (download) {
      // Для скачивания всегда используем Яндекс TTS
      await _yandexSay(text, download: true);
    } else if (_useYandex || Platform.isLinux) {
      // Используем Яндекс TTS если включен или на Linux
      await _yandexSay(text, download: false);
    } else {
      // Используем нативный TTS (по умолчанию для macOS)
      await _nativeSay(text);
    }
  }
  
  Future<void> _nativeSay(String text) async {
    try {
      if (_flutterTts == null) {
        _lastError = 'FlutterTts не инициализирован';
        _eventController.add('error: FlutterTts не инициализирован');
        return;
      }
      
      await _flutterTts!.speak(text);
    } catch (e) {
      _lastError = e.toString();
      _eventController.add('error: $e');
      print('Ошибка нативного TTS: $e');
    }
  }
  
  Future<void> _yandexSay(String text, {bool download = false}) async {
    try {
      _eventController.add('start');
      
      final response = await http.post(
        Uri.parse('https://tts.linka.su/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': _currentVoice?.voiceURI ?? 'zahar',
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final bytes = response.bodyBytes;
        
        if (download) {
          await _downloadAudio(bytes, text);
        } else {
          // Воспроизводим аудио с помощью audioplayers
          try {
            final tempDir = await getTemporaryDirectory();
            final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
            final file = File('${tempDir.path}/$fileName');
            await file.writeAsBytes(bytes);
            
            print('Аудио сохранено: ${file.path}');
            
            // Воспроизводим аудио
            await _audioPlayer?.play(DeviceFileSource(file.path));
            
            // Ждем окончания воспроизведения
            _audioPlayer?.onPlayerComplete.listen((_) {
              _eventController.add('end');
            });
            
          } catch (e) {
            print('Ошибка воспроизведения: $e');
            _lastError = 'Ошибка воспроизведения: $e';
            _eventController.add('error: $e');
          }
        }
      } else {
        _lastError = 'HTTP ${response.statusCode}';
        _eventController.add('error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _lastError = e.toString();
      _eventController.add('error: $e');
    }
  }
  
  Future<void> _downloadAudio(Uint8List bytes, String text) async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        _lastError = 'Cannot access downloads directory';
        _eventController.add('error: Cannot access downloads directory');
        return;
      }
      
      final fileName = 'LINKa. напиши. ${text.substring(0, text.length > 5 ? 5 : text.length)}.mp3';
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      print('Аудиофайл сохранен: ${file.path}');
      _eventController.add('end');
    } catch (e) {
      _lastError = e.toString();
      _eventController.add('error: $e');
    }
  }
  
  Future<void> stop() async {
    try {
      if (_useYandex) {
        await _audioPlayer?.stop();
      } else {
        await _flutterTts?.stop();
      }
      _eventController.add('end');
    } catch (e) {
      print('Ошибка остановки: $e');
    }
  }
  
  Future<void> playLastAudio() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync()
          .where((file) => file is File && file.path.contains('tts_'))
          .cast<File>()
          .toList();
      
      if (files.isNotEmpty) {
        // Берем последний созданный файл
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        final lastFile = files.first;
        
        print('Воспроизведение: ${lastFile.path}');
        
        // Воспроизводим через audioplayers
        await _audioPlayer?.play(DeviceFileSource(lastFile.path));
        
        // Ждем окончания воспроизведения
        _audioPlayer?.onPlayerComplete.listen((_) {
          _eventController.add('end');
        });
        
      } else {
        print('Нет сохраненных аудиофайлов');
        _lastError = 'Нет сохраненных аудиофайлов';
        _eventController.add('error: Нет сохраненных аудиофайлов');
      }
    } catch (e) {
      print('Ошибка воспроизведения: $e');
      _lastError = 'Ошибка воспроизведения: $e';
      _eventController.add('error: $e');
    }
  }
  
  // Volume
  Future<double> getVolume() async {
    return _prefs.getDouble('volume') ?? 1.0;
  }
  
  Future<void> setVolume(double volume) async {
    await _prefs.setDouble('volume', volume);
    await _flutterTts?.setVolume(volume);
  }
  
  // Rate
  Future<double> getRate() async {
    return _prefs.getDouble('rate') ?? 1.0;
  }
  
  Future<void> setRate(double rate) async {
    await _prefs.setDouble('rate', rate);
    await _flutterTts?.setSpeechRate(rate);
  }
  
  // Pitch
  Future<double> getPitch() async {
    return _prefs.getDouble('pitch') ?? 1.0;
  }
  
  Future<void> setPitch(double pitch) async {
    await _prefs.setDouble('pitch', pitch);
    await _flutterTts?.setPitch(pitch);
  }
  
  // Yandex mode
  Future<bool> getUseYandex() async {
    // На macOS по умолчанию используем нативный TTS
    if (Platform.isMacOS) {
      return _prefs.getBool('yandex') ?? false;
    }
    // На Linux по умолчанию используем Яндекс TTS
    return _prefs.getBool('yandex') ?? true;
  }
  
  Future<void> setUseYandex(bool value) async {
    await _prefs.setBool('yandex', value);
    _useYandex = value;
  }
  
  // Voice selection
  Future<void> setVoice(String voiceURI) async {
    final yandexVoices = getYandexVoices();
    final offlineVoices = await getOfflineVoices();
    
    TTSVoice? selectedVoice;
    
    try {
      // Сначала ищем в Яндекс голосах
      final yandexVoice = yandexVoices.firstWhere((v) => v.voiceURI == voiceURI);
      selectedVoice = TTSVoice(
        voiceURI: yandexVoice.voiceURI,
        text: yandexVoice.text,
      );
    } catch (e) {
      try {
        // Затем ищем в офлайн голосах
        final offlineVoice = offlineVoices.firstWhere((v) => v.voiceURI == voiceURI);
        selectedVoice = offlineVoice;
        
        // Устанавливаем голос в FlutterTts
        await _flutterTts?.setVoice({"name": voiceURI, "locale": offlineVoice.locale ?? "ru-RU"});
      } catch (e2) {
        // Если голос не найден, используем первый доступный
        if (yandexVoices.isNotEmpty) {
          final firstYandex = yandexVoices.first;
          selectedVoice = TTSVoice(
            voiceURI: firstYandex.voiceURI,
            text: firstYandex.text,
          );
        } else if (offlineVoices.isNotEmpty) {
          selectedVoice = offlineVoices.first;
          await _flutterTts?.setVoice({"name": selectedVoice.voiceURI, "locale": selectedVoice.locale ?? "ru-RU"});
        }
      }
    }
    
    if (selectedVoice != null) {
      await _prefs.setString('voiceuri', selectedVoice.voiceURI);
      _currentVoice = selectedVoice;
    }
  }
  
  Future<TTSVoice> getSelectedVoice() async {
    final yandexVoices = getYandexVoices();
    final offlineVoices = await getOfflineVoices();
    final savedURI = _prefs.getString('voiceuri') ?? 'zahar';
    
    try {
      // Сначала ищем в Яндекс голосах
      final yandexVoice = yandexVoices.firstWhere((v) => v.voiceURI == savedURI);
      return TTSVoice(
        voiceURI: yandexVoice.voiceURI,
        text: yandexVoice.text,
      );
    } catch (e) {
      try {
        // Затем ищем в офлайн голосах
        final offlineVoice = offlineVoices.firstWhere((v) => v.voiceURI == savedURI);
        return offlineVoice;
      } catch (e2) {
        // Если не найден, возвращаем первый доступный
        if (yandexVoices.isNotEmpty) {
          final firstYandex = yandexVoices.first;
          return TTSVoice(
            voiceURI: firstYandex.voiceURI,
            text: firstYandex.text,
          );
        } else if (offlineVoices.isNotEmpty) {
          // На macOS приоритет русским голосам
          if (Platform.isMacOS) {
            final russianVoice = offlineVoices.firstWhere(
              (voice) => voice.locale?.startsWith('ru') == true,
              orElse: () => offlineVoices.first,
            );
            return russianVoice;
          }
          return offlineVoices.first;
        } else {
          // Fallback
          return TTSVoice(
            voiceURI: 'default',
            text: 'По умолчанию',
          );
        }
      }
    }
  }
  
  Future<List<TTSVoice>> getOfflineVoices() async {
    // Для Linux возвращаем пустой список
    if (Platform.isLinux) return [];
    
    try {
      if (_flutterTts == null) return [];
      
      final voices = await _flutterTts!.getVoices;
      
      if (voices == null) return [];
      
      if (voices is List) {
        final voiceList = voices.map((voice) {
          if (voice is Map) {
            final Map<Object?, Object?> voiceMap = voice as Map<Object?, Object?>;
            return TTSVoice(
              voiceURI: (voiceMap['name'] ?? '').toString(),
              text: (voiceMap['name'] ?? '').toString(),
              locale: (voiceMap['locale'] ?? '').toString(),
              isDefault: voiceMap['default'] == true,
            );
          } else {
            print('Неожиданный тип voice: ${voice.runtimeType}');
            return TTSVoice(
              voiceURI: 'unknown',
              text: 'Неизвестный голос',
              locale: 'ru-RU',
              isDefault: false,
            );
          }
        }).toList();
        
        // Сортируем голоса: сначала русские, затем английские, затем остальные
        voiceList.sort((a, b) {
          // Русский язык имеет высший приоритет
          if (a.locale?.startsWith('ru') == true && b.locale?.startsWith('ru') != true) return -1;
          if (b.locale?.startsWith('ru') == true && a.locale?.startsWith('ru') != true) return 1;
          
          // Английский язык имеет второй приоритет
          if (a.locale?.startsWith('en') == true && b.locale?.startsWith('en') != true) return -1;
          if (b.locale?.startsWith('en') == true && a.locale?.startsWith('en') != true) return 1;
          
          // По умолчанию сортируем по названию
          return a.text.compareTo(b.text);
        });
        
        return voiceList;
      } else {
        print('voices не является List: ${voices.runtimeType}');
        return [];
      }
            } catch (e) {
          return [];
        }
  }
  
  List<YandexVoice> getYandexVoices() {
    return [
      YandexVoice(voiceURI: 'zahar', text: 'Захар'),
      YandexVoice(voiceURI: 'ermil', text: 'Емиль'),
      YandexVoice(voiceURI: 'jane', text: 'Джейн'),
      YandexVoice(voiceURI: 'oksana', text: 'Оксана'),
      YandexVoice(voiceURI: 'alena', text: 'Алёна'),
      YandexVoice(voiceURI: 'filipp', text: 'Филипп'),
      YandexVoice(voiceURI: 'omazh', text: 'Ома'),
    ];
  }
  
  Future<TTSVoice?> getDefaultOfflineVoice() async {
    try {
      if (_flutterTts == null) return null;
      
      final voices = await getOfflineVoices();
      if (voices.isEmpty) return null;
      
      // На macOS приоритет русским голосам
      if (Platform.isMacOS) {
        final russianVoice = voices.firstWhere(
          (voice) => voice.locale?.startsWith('ru') == true,
          orElse: () => voices.first,
        );
        return russianVoice;
      }
      
      // Ищем голос по умолчанию или берем первый
      final defaultVoice = voices.firstWhere(
        (voice) => voice.isDefault,
        orElse: () => voices.first,
      );
      
      return defaultVoice;
            } catch (e) {
          return null;
        }
  }
  
  /// Получает список только русских голосов
  Future<List<TTSVoice>> getRussianVoices() async {
    try {
      final allVoices = await getOfflineVoices();
      return allVoices.where((voice) => voice.locale?.startsWith('ru') == true).toList();
            } catch (e) {
          return [];
        }
  }
  
  void dispose() {
    _eventController.close();
    _audioPlayer?.dispose();
    _flutterTts?.stop();
  }
}
