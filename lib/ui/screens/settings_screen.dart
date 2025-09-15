import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../services/tts_service.dart';
import '../../services/tts_cache_service.dart';
import '../../api/api.dart';
import '../theme/app_theme.dart';
import '../widgets/shortcuts_dialog.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final TTSService _ttsService = TTSService.instance;
  final AuthService _authService = AuthService();
  late TabController _tabController;

  bool _useYandex = false;
  double _volume = 1.0;
  double _rate = 1.0;
  double _pitch = 1.0;
  String _selectedVoice = '';
  List<TTSVoice> _offlineVoices = [];
  List<YandexVoice> _yandexVoices = [];
  bool _isLoading = true;
  String? _lastError;
  String _ttsStatus = 'Готов';
  String? _userEmail;

  // Cache settings
  bool _cacheEnabled = true;
  double _cacheSizeLimitMB = 2048; // 2GB default
  double _currentCacheSizeMB = 0;
  int _cacheFileCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
    _setupTTSEvents();
    _loadUserInfo();
    _loadCacheSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final email = await TokenManager.getUserEmail();
      setState(() {
        _userEmail = email;
      });
    } catch (e) {}
  }

  Future<void> _loadCacheSettings() async {
    try {
      final cacheService = TTSCacheService.instance;
      final cacheInfo = await cacheService.getCacheInfo();

      setState(() {
        _cacheEnabled = cacheInfo.enabled;
        _cacheSizeLimitMB = cacheInfo.sizeLimitMB;
        _currentCacheSizeMB = cacheInfo.sizeMB;
        _cacheFileCount = cacheInfo.fileCount;
      });
    } catch (e) {
      // Игнорируем ошибки загрузки настроек кеша
    }
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
    } catch (e) {}

    setState(() {
      _isLoading = false;
    });
  }

  void _setupTTSEvents() {
    _ttsService.events.listen((event) {
      if (mounted) {
        setState(() {
          if (event == 'start') {
            _ttsStatus = 'Говорит...';
            _lastError = null;
          } else if (event == 'end') {
            _ttsStatus = 'Готов';
            _lastError = null;
          } else if (event.startsWith('error:')) {
            _lastError = event.substring(6);
            _ttsStatus = 'Ошибка: $_lastError';
          }
        });
      }
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToResetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.volume_up), text: 'TTS'),
            Tab(icon: Icon(Icons.account_circle), text: 'Аккаунт'),
            Tab(icon: Icon(Icons.cached), text: 'Кеш'),
            Tab(icon: Icon(Icons.info), text: 'Информация'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTTSTab(),
                _buildAccountTab(),
                _buildCacheTab(),
                _buildInfoTab()
              ],
            ),
    );
  }

  Widget _buildTTSTab() {
    return SingleChildScrollView(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Настройки TTS',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Статус: $_ttsStatus',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (_lastError != null)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _lastError!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ошибка скопирована в буфер обмена',
                                ),
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
                              Clipboard.setData(
                                ClipboardData(text: _lastError!),
                              );
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
                  Text('Голос', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedVoice.isNotEmpty &&
                            ((_useYandex || Platform.isLinux)
                                ? _yandexVoices.any(
                                    (v) => v.voiceURI == _selectedVoice,
                                  )
                                : _offlineVoices.any(
                                    (v) => v.voiceURI == _selectedVoice,
                                  ))
                        ? _selectedVoice
                        : null,
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
                        ..._yandexVoices.map(
                          (voice) => DropdownMenuItem(
                            value: voice.voiceURI,
                            child: Text('${voice.text} (Яндекс)'),
                          ),
                        ),
                      ] else ...[
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Системные голоса'),
                        ),
                        ..._offlineVoices.map(
                          (voice) => DropdownMenuItem(
                            value: voice.voiceURI,
                            child: Text('${voice.text} (Системный)'),
                          ),
                        ),
                      ],
                    ]
                        .where(
                          (item) =>
                              item.value == null || item.value!.isNotEmpty,
                        )
                        .toList(),
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

          // Управление TTS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Управление TTS',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _ttsService.say('Привет! Это тест настроек TTS.'),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _ttsService.playLastAudio(),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Воспроизвести последнее'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Информация об аккаунте',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_userEmail != null) ...[
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(_userEmail!),
                    ),
                    const Divider(),
                  ],
                  ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Сбросить пароль'),
                    subtitle: const Text('Отправить ссылку для сброса пароля'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _navigateToResetPassword,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Выйти из аккаунта',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Завершить текущую сессию'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.cached,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Кеширование TTS',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Файлы: $_cacheFileCount, Размер: ${_currentCacheSizeMB.toStringAsFixed(1)} МБ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Включение/отключение кеширования
                  SwitchListTile(
                    title: const Text('Включить кеширование'),
                    subtitle: const Text(
                        'Сохранять TTS файлы для повторного использования'),
                    value: _cacheEnabled,
                    onChanged: (value) async {
                      final cacheService = TTSCacheService.instance;
                      await cacheService.setCacheEnabled(value);
                      setState(() {
                        _cacheEnabled = value;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Кеширование включено'
                                  : 'Кеширование отключено',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Прогресс-бар использования кеша
                  Text(
                    'Использование кеша',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _cacheSizeLimitMB > 0
                        ? _currentCacheSizeMB / _cacheSizeLimitMB
                        : 0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentCacheSizeMB >= _cacheSizeLimitMB * 0.9
                          ? Colors.red
                          : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentCacheSizeMB.toStringAsFixed(1)} МБ из ${_cacheSizeLimitMB.toStringAsFixed(0)} МБ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  // Настройка размера кеша
                  Text(
                    'Максимальный размер кеша',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _cacheSizeLimitMB,
                          min: 100, // Минимум 100 МБ
                          max: 10000, // Максимум 10 ГБ
                          divisions: 99,
                          onChanged: _cacheEnabled
                              ? (value) async {
                                  final cacheService = TTSCacheService.instance;
                                  await cacheService.setCacheSizeLimitMB(value);
                                  setState(() {
                                    _cacheSizeLimitMB = value;
                                  });
                                  await _loadCacheSettings(); // Обновляем информацию
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_cacheSizeLimitMB.toStringAsFixed(0)} МБ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _cacheEnabled ? null : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Управление кешем
                  Text(
                    'Управление кешем',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Очистить кеш?'),
                                content: const Text(
                                  'Все сохраненные TTS файлы будут удалены. '
                                  'При следующем использовании они будут загружены заново.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Очистить'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final cacheService = TTSCacheService.instance;
                              await cacheService.clearCache();
                              await _loadCacheSettings();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Кеш очищен'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Очистить кеш'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _loadCacheSettings();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Информация обновлена'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Обновить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Информация о приложении',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
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
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.keyboard),
                    title: const Text('Горячие клавиши'),
                    subtitle: const Text('Показать список доступных шорткатов'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ShortcutsDialog(),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Справка'),
                    subtitle: const Text('Как использовать приложение'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Добавить экран справки
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Справка будет добавлена позже'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bug_report),
                    title: const Text('Сообщить об ошибке'),
                    subtitle: const Text('Отправить отчет об ошибке'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Добавить форму отправки ошибки
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Форма отправки ошибки будет добавлена позже',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
