import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api/api.dart';
import '../../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TTSService _ttsService = TTSService.instance;
  final TextEditingController _textController = TextEditingController();
  String? _userEmail;
  String _ttsStatus = 'Готов';
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _setupTTSEvents();
  }

  Future<void> _loadUserInfo() async {
    final email = await _authService.getUserEmail();
    setState(() {
      _userEmail = email;
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

  Future<void> _sayText({bool download = false}) async {
    if (_textController.text.isNotEmpty) {
      await _ttsService.say(_textController.text, download: download);
    }
  }
  
  Future<void> _playLastAudio() async {
    await _ttsService.playLastAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Приветствие
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Добро пожаловать!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_userEmail != null)
              Text(
                'Email: $_userEmail',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            const SizedBox(height: 32),
            
            // TTS секция
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TTS Статус: $_ttsStatus',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Введите текст для озвучивания',
                        border: OutlineInputBorder(),
                        hintText: 'Например: Привет, как дела?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _textController.text.isNotEmpty ? _sayText : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Сказать'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _textController.text.isNotEmpty ? () => _sayText(download: true) : null,
                          icon: const Icon(Icons.download),
                          label: const Text('Скачать'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _playLastAudio,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Воспроизвести'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Настройки'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Вы успешно вошли в систему',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
