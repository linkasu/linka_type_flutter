import 'package:flutter/material.dart';
import '../../services/tts_service.dart';
import '../../api/api.dart';
import '../../api/utils/token_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/text_input_block.dart';
import '../widgets/phrase_bank.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _ttsService = TTSService.instance;
  final DataService _dataService = DataService();
  
  List<Category> _categories = [];
  List<Statement> _statements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final categories = await _dataService.getCategories();
      final statements = await _dataService.getStatements();
      
      setState(() {
        _categories = categories;
        _statements = statements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // Проверяем, является ли ошибка 401 (неавторизован)
        if (e.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Сессия истекла. Пожалуйста, войдите заново.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Перенаправляем на экран логина
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка загрузки данных: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _sayText(String text) async {
    await _ttsService.say(text);
  }

  Future<void> _downloadText(String text) async {
    await _ttsService.say(text, download: true);
  }

  Future<void> _sayStatement(Statement statement) async {
    await _ttsService.say(statement.title);
  }

  Future<void> _editStatement(Statement statement) async {
    // TODO: Реализовать редактирование фразы
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция редактирования фразы будет реализована позже')),
    );
  }

  Future<void> _deleteStatement(Statement statement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фразу?'),
        content: Text('Вы уверены, что хотите удалить фразу "${statement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dataService.deleteStatement(statement.id);
        await _loadData(); // Перезагружаем данные
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Фраза удалена')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: $e')),
          );
        }
      }
    }
  }

  Future<void> _editCategory(Category category) async {
    // TODO: Реализовать редактирование категории
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция редактирования категории будет реализована позже')),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('Вы уверены, что хотите удалить категорию "${category.title}"? Все фразы в этой категории также будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dataService.deleteCategory(category.id);
        await _loadData(); // Перезагружаем данные
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Категория удалена')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: $e')),
          );
        }
      }
    }
  }

  Future<void> _addStatement() async {
    // TODO: Реализовать добавление фразы
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления фразы будет реализована позже')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LINKa напиши'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выйти из аккаунта?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await TokenManager.clearAll();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
            tooltip: 'Выйти',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Блок ввода текста
                  TextInputBlock(
                    onSayText: _sayText,
                    onDownloadText: _downloadText,
                  ),
                  const SizedBox(height: 16),
                  
                  // Банк фраз
                  Expanded(
                    child: PhraseBank(
                      categories: _categories,
                      statements: _statements,
                      onSayStatement: _sayStatement,
                      onEditStatement: _editStatement,
                      onDeleteStatement: _deleteStatement,
                      onEditCategory: _editCategory,
                      onDeleteCategory: _deleteCategory,
                      onAddStatement: _addStatement,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
