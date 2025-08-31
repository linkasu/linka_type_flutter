import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../services/tts_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TTSService _ttsService = TTSService.instance;
  
  bool _useYandex = false;
  double _volume = 1.0;
  double _rate = 1.0;
  double _pitch = 1.0;
  String _selectedVoice = '';
  List<TTSVoice> _offlineVoices = [];
  List<YandexVoice> _yandexVoices = [];
  bool _isLoading = true;
  String? _lastError;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupTTSEvents();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _useYandex = await _ttsService.getUseYandex();
      _volume = await _ttsService.getVolume();
      _rate = await _ttsService.getRate();
      _pitch = await _ttsService.getPitch();
      
      _offlineVoices = await _ttsService.getOfflineVoices();
      _yandexVoices = _ttsService.getYandexVoices();
      
      final selectedVoice = await _ttsService.getSelectedVoice();
      _selectedVoice = selectedVoice.voiceURI;
    } catch (e) {
      print('Ошибка загрузки настроек: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _setupTTSEvents() {
    _ttsService.events.listen((event) {
      if (mounted) {
        setState(() {
          if (event.startsWith('error:')) {
            _lastError = event.substring(6);
          }
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TTS секция
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                                     Row(
                             children: [
                               const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   'Настройки TTS',
                                   style: Theme.of(context).textTheme.titleLarge,
                                 ),
                               ),
                               if (_lastError != null)
                                 IconButton(
                                   icon: const Icon(Icons.copy, size: 20),
                                   onPressed: () {
                                     Clipboard.setData(ClipboardData(text: _lastError!));
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(
                                         content: Text('Ошибка скопирована в буфер обмена'),
                                         duration: Duration(seconds: 2),
                                       ),
                                     );
                                   },
                                   tooltip: 'Копировать ошибку',
                                 ),
                             ],
                           ),
                          const SizedBox(height: 16),
                          
                          // Отображение ошибки
                          if (_lastError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ошибка: $_lastError',
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: _lastError!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ошибка скопирована'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    tooltip: 'Копировать ошибку',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Переключатель режима TTS (скрыт на Linux)
                          if (!Platform.isLinux)
                            SwitchListTile(
                              title: const Text('Использовать Яндекс TTS'),
                              subtitle: const Text('Онлайн режим с высоким качеством'),
                              value: _useYandex,
                              onChanged: (value) async {
                                await _ttsService.setUseYandex(value);
                                setState(() {
                                  _useYandex = value;
                                });
                              },
                            ),
                          if (Platform.isLinux)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'На Linux используется только Яндекс TTS',
                                      style: TextStyle(color: Colors.blue.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Выбор голоса
                          Text(
                            'Голос',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedVoice.isNotEmpty && ((_useYandex || Platform.isLinux) ? _yandexVoices.any((v) => v.voiceURI == _selectedVoice) : _offlineVoices.any((v) => v.voiceURI == _selectedVoice)) ? _selectedVoice : null,
                            decoration: const InputDecoration(
                              labelText: 'Выберите голос',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              if (_useYandex || Platform.isLinux) ...[
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Яндекс голоса'),
                                ),
                                ..._yandexVoices.map((voice) => DropdownMenuItem(
                                  value: voice.voiceURI,
                                  child: Text('${voice.text} (Яндекс)'),
                                )),
                              ] else ...[
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('Системные голоса'),
                                ),
                                ..._offlineVoices.map((voice) => DropdownMenuItem(
                                  value: voice.voiceURI,
                                  child: Text('${voice.text} (Системный)'),
                                )),
                              ],
                            ].where((item) => item.value == null || item.value!.isNotEmpty).toList(),
                            onChanged: (value) async {
                              if (value != null && value.isNotEmpty) {
                                await _ttsService.setVoice(value);
                                setState(() {
                                  _selectedVoice = value;
                                });
                              }
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Громкость
                          Text(
                            'Громкость: ${(_volume * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 100,
                            onChanged: (value) async {
                              await _ttsService.setVolume(value);
                              setState(() {
                                _volume = value;
                              });
                            },
                          ),
                          
                          // Скорость
                          Text(
                            'Скорость: ${(_rate * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Slider(
                            value: _rate,
                            min: 0.1,
                            max: 2.0,
                            divisions: 19,
                            onChanged: (value) async {
                              await _ttsService.setRate(value);
                              setState(() {
                                _rate = value;
                              });
                            },
                          ),
                          
                          // Тон
                          Text(
                            'Тон: ${(_pitch * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Slider(
                            value: _pitch,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            onChanged: (value) async {
                              await _ttsService.setPitch(value);
                              setState(() {
                                _pitch = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Тест TTS
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тест настроек',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _ttsService.say('Привет! Это тест настроек TTS.'),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Тест'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _ttsService.stop(),
                                icon: const Icon(Icons.stop),
                                label: const Text('Стоп'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Информация о голосах
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Информация',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                                                     Text(
                             'Доступно Яндекс голосов: ${_yandexVoices.length}',
                             style: Theme.of(context).textTheme.bodyMedium,
                           ),
                           const SizedBox(height: 8),
                           Text(
                             'Текущий режим: Яндекс TTS (онлайн)',
                             style: Theme.of(context).textTheme.bodyMedium,
                           ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
