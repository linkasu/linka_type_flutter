import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../api/models/category.dart';
import '../../api/models/statement.dart';
import '../../services/tts_service.dart';
import '../../services/analytics_manager.dart';
import '../../services/analytics_events.dart';
import '../theme/app_theme.dart';

class _PreviousIntent extends Intent {
  const _PreviousIntent();
}

class _NextIntent extends Intent {
  const _NextIntent();
}

class _PlayPauseIntent extends Intent {
  const _PlayPauseIntent();
}

class _ExitIntent extends Intent {
  const _ExitIntent();
}

class PresentationModeScreen extends StatefulWidget {
  final Category category;
  final List<Statement> statements;
  
  const PresentationModeScreen({
    super.key,
    required this.category,
    required this.statements,
  });

  @override
  State<PresentationModeScreen> createState() => _PresentationModeScreenState();
}

class _PresentationModeScreenState extends State<PresentationModeScreen>
    with TickerProviderStateMixin {
  late final AnalyticsManager _analyticsManager;
  final TTSService _ttsService = TTSService.instance;
  final FocusNode _focusNode = FocusNode();
  
  List<Statement> _statements = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _filterStatements();
    _trackScreenView();
    
    // Устанавливаем фокус для обработки клавиш
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analyticsManager = context.read<AnalyticsManager>();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    // Устанавливаем анимацию в конечное состояние для первой фразы
    _slideController.value = 1.0;
  }

  Future<void> _trackScreenView() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.screenView, data: {
      'screen_name': 'presentation_mode_screen',
      'category_id': widget.category.id,
      'category_title': widget.category.title,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _filterStatements() {
    final categoryStatements = widget.statements
        .where((s) => s.categoryId == widget.category.id)
        .toList();
    
    // Сортируем от старых к новым по дате создания
    categoryStatements.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    setState(() {
      _statements = categoryStatements;
      _isLoading = false;
    });
  }

  bool get _hasStatements => _statements.isNotEmpty;
  Statement? get _currentStatement => 
      _hasStatements && _currentIndex < _statements.length 
          ? _statements[_currentIndex] 
          : null;

  Future<void> _navigateToPrevious() async {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _slideController.forward(from: 0.0);
      
      await _analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
        'button_name': 'previous_phrase',
        'screen': 'presentation_mode_screen',
        'current_index': _currentIndex,
      });
    }
  }

  Future<void> _navigateToNext() async {
    if (_currentIndex < _statements.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _slideController.forward(from: 0.0);
      
      await _analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
        'button_name': 'next_phrase',
        'screen': 'presentation_mode_screen',
        'current_index': _currentIndex,
      });
    }
  }

  Future<void> _togglePlayback() async {
    final statement = _currentStatement;
    if (statement == null) return;

    if (_isPlaying) {
      await _ttsService.stop();
      setState(() {
        _isPlaying = false;
      });
      
      await _analyticsManager.trackEvent(AnalyticsEvents.ttsStopped, data: {
        'statement_id': statement.id,
        'source': 'presentation_mode',
      });
    } else {
      await _ttsService.say(statement.title);
      setState(() {
        _isPlaying = true;
      });
      
      await _analyticsManager.trackEvent(AnalyticsEvents.ttsStarted, data: {
        'statement_id': statement.id,
        'text_length': statement.title.length,
        'source': 'presentation_mode',
      });
      
      // Автоматически останавливаем воспроизведение через некоторое время
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isPlaying) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  Future<void> _exitPresentationMode() async {
    if (_isPlaying) {
      await _ttsService.stop();
    }
    
    await _analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
      'button_name': 'exit_presentation_mode',
      'screen': 'presentation_mode_screen',
      'session_duration': DateTime.now().difference(_sessionStartTime).inSeconds,
    });
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  late final DateTime _sessionStartTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.keyZ): _PreviousIntent(),
          SingleActivator(LogicalKeyboardKey.keyM): _NextIntent(),
          SingleActivator(LogicalKeyboardKey.space): _PlayPauseIntent(),
          SingleActivator(LogicalKeyboardKey.escape): _ExitIntent(),
        },
        child: Actions(
          actions: {
            _PreviousIntent: CallbackAction<_PreviousIntent>(
              onInvoke: (_) => _navigateToPrevious(),
            ),
            _NextIntent: CallbackAction<_NextIntent>(
              onInvoke: (_) => _navigateToNext(),
            ),
            _PlayPauseIntent: CallbackAction<_PlayPauseIntent>(
              onInvoke: (_) => _togglePlayback(),
            ),
            _ExitIntent: CallbackAction<_ExitIntent>(
              onInvoke: (_) => _exitPresentationMode(),
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            child: SafeArea(
              child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _hasStatements
                  ? _buildPresentationView()
                  : _buildEmptyState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresentationView() {
    return Column(
      children: [
        // Заголовок с информацией о категории
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitPresentationMode,
                tooltip: 'Выход (Esc)',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentIndex + 1} из ${_statements.length}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Для балансировки
            ],
          ),
        ),
        
        // Основная область с фразой
        Expanded(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _currentStatement?.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        
        // Индикатор прогресса
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
          child: LinearProgressIndicator(
            value: _hasStatements ? (_currentIndex + 1) / _statements.length : 0.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        
        // Управление
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Предыдущая фраза
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: _currentIndex > 0 ? Colors.white : Colors.grey,
                  size: 32,
                ),
                onPressed: _currentIndex > 0 ? _navigateToPrevious : null,
                tooltip: 'Предыдущая фраза (Z)',
              ),
              
              // Воспроизведение
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: _togglePlayback,
                tooltip: 'Воспроизведение (Space)',
              ),
              
              // Следующая фраза
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: _currentIndex < _statements.length - 1 ? Colors.white : Colors.grey,
                  size: 32,
                ),
                onPressed: _currentIndex < _statements.length - 1 ? _navigateToNext : null,
                tooltip: 'Следующая фраза (M)',
              ),
            ],
          ),
        ),
        
        // Подсказки по управлению
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Z - предыдущая | Space - воспроизведение | M - следующая | Esc - выход',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет фраз в этой категории',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _exitPresentationMode,
            child: const Text('Вернуться'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _focusNode.dispose();
    if (_isPlaying) {
      _ttsService.stop();
    }
    super.dispose();
  }
}
