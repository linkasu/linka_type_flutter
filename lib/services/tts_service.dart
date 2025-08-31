import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
    
    _isInitialized = true;
  }
  
  Future<void> say(String text, {bool download = false}) async {
    if (text.isEmpty) return;
    
    await _init();
    
    // Всегда используем Яндекс TTS для Linux
    await _yandexSay(text, download: download);
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
      await _audioPlayer?.stop();
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
  }
  
  // Rate
  Future<double> getRate() async {
    return _prefs.getDouble('rate') ?? 1.0;
  }
  
  Future<void> setRate(double rate) async {
    await _prefs.setDouble('rate', rate);
  }
  
  // Pitch
  Future<double> getPitch() async {
    return _prefs.getDouble('pitch') ?? 1.0;
  }
  
  Future<void> setPitch(double pitch) async {
    await _prefs.setDouble('pitch', pitch);
  }
  
  // Yandex mode
  Future<bool> getUseYandex() async {
    return _prefs.getBool('yandex') ?? true; // По умолчанию true для Linux
  }
  
  Future<void> setUseYandex(bool value) async {
    await _prefs.setBool('yandex', value);
    _useYandex = value;
  }
  
  // Voice selection
  Future<void> setVoice(String voiceURI) async {
    final yandexVoices = getYandexVoices();
    
    TTSVoice? selectedVoice;
    
    try {
      final yandexVoice = yandexVoices.firstWhere((v) => v.voiceURI == voiceURI);
      selectedVoice = TTSVoice(
        voiceURI: yandexVoice.voiceURI,
        text: yandexVoice.text,
      );
    } catch (e) {
      // Если голос не найден, используем первый доступный
      final firstYandex = yandexVoices.first;
      selectedVoice = TTSVoice(
        voiceURI: firstYandex.voiceURI,
        text: firstYandex.text,
      );
    }
    
    if (selectedVoice != null) {
      await _prefs.setString('voiceuri', selectedVoice.voiceURI);
      _currentVoice = selectedVoice;
    }
  }
  
  Future<TTSVoice> getSelectedVoice() async {
    final yandexVoices = getYandexVoices();
    final savedURI = _prefs.getString('voiceuri') ?? 'zahar';
    
    try {
      final yandexVoice = yandexVoices.firstWhere((v) => v.voiceURI == savedURI);
      return TTSVoice(
        voiceURI: yandexVoice.voiceURI,
        text: yandexVoice.text,
      );
    } catch (e) {
      final firstYandex = yandexVoices.first;
      return TTSVoice(
        voiceURI: firstYandex.voiceURI,
        text: firstYandex.text,
      );
    }
  }
  
  Future<List<TTSVoice>> getOfflineVoices() async {
    // Для Linux возвращаем пустой список, так как используем только онлайн
    return [];
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
    // Для Linux возвращаем null
    return null;
  }
  
  void dispose() {
    _eventController.close();
    _audioPlayer?.dispose();
  }
}
