import 'package:flutter/material.dart';
import '../../services/tts_service.dart';
import '../../services/statement_service.dart';
import '../../api/api.dart';
import '../theme/app_theme.dart';
import '../widgets/text_input_block.dart';
import '../widgets/phrase_bank.dart';
import '../widgets/crud_dialogs.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _ttsService = TTSService.instance;
  final DataService _dataService = DataService();
  final StatementService _statementService = StatementService();
  final FocusNode _phraseBankFocus = FocusNode();

  List<Category> _categories = [];
  List<Statement> _statements = [];
  bool _isLoading = true;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupShortcuts();
  }

  void _setupShortcuts() {
    // Shortcuts are now handled globally in main.dart
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

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _editStatement(Statement statement) async {
    final dropdownItems = _categories
        .map((category) => {'value': category.id, 'label': category.title})
        .toList();

    final result = await CrudDialogs.showTextWithDropdownDialog(
      context: context,
      title: 'Редактировать фразу',
      textLabel: 'Текст фразы',
      dropdownLabel: 'Категория',
      dropdownItems: dropdownItems,
      initialText: statement.title,
      initialDropdownValue: statement.categoryId,
      textMaxLines: 3,
    );

    if (result != null) {
      try {
        await _dataService.updateStatement(
          statement.id,
          result['text']!,
          result['dropdown']!,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза обновлена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка обновления: $e')));
        }
      }
    }
  }

  Future<void> _deleteStatement(Statement statement) async {
    final confirmed = await CrudDialogs.showConfirmDialog(
      context: context,
      title: 'Удалить фразу?',
      content: 'Вы уверены, что хотите удалить фразу "${statement.title}"?',
    );

    if (confirmed == true) {
      try {
        await _dataService.deleteStatement(statement.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза удалена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await CrudDialogs.showTextInputDialog(
      context: context,
      title: 'Редактировать категорию',
      labelText: 'Название категории',
      initialValue: category.title,
    );

    if (result != null) {
      try {
        await _dataService.updateCategory(category.id, result);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Категория обновлена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка обновления: $e')));
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await CrudDialogs.showConfirmDialog(
      context: context,
      title: 'Удалить категорию?',
      content:
          'Вы уверены, что хотите удалить категорию "${category.title}"? Все фразы в этой категории также будут удалены.',
    );

    if (confirmed == true) {
      try {
        await _dataService.deleteCategory(category.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Категория удалена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  Future<void> _addCategory() async {
    final result = await CrudDialogs.showTextInputDialog(
      context: context,
      title: 'Добавить категорию',
      labelText: 'Название категории',
      hintText: 'Введите название категории',
    );

    if (result != null) {
      try {
        await _dataService.createCategory(result);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Категория добавлена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка добавления: $e')));
        }
      }
    }
  }

  Future<void> _addStatement() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создайте категорию')),
      );
      return;
    }

    final dropdownItems = _categories
        .map((category) => {'value': category.id, 'label': category.title})
        .toList();

    final result = await CrudDialogs.showTextWithDropdownDialog(
      context: context,
      title: 'Добавить фразу',
      textLabel: 'Текст фразы',
      dropdownLabel: 'Категория',
      dropdownItems: dropdownItems,
      initialDropdownValue: _selectedCategory?.id ?? _categories.first.id,
      textMaxLines: 3,
    );

    if (result != null) {
      try {
        await _dataService.createStatement(
          result['text']!,
          result['dropdown']!,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза добавлена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка добавления: $e')));
        }
      }
    }
  }

  Future<void> _bulkEditStatements(
      List<Statement> statements, String newText) async {
    final categoryId = statements.isNotEmpty
        ? statements.first.categoryId
        : _selectedCategory?.id;

    if (categoryId == null) {
      _showErrorSnackBar('Ошибка: категория не найдена');
      return;
    }

    // Валидация
    final validation = _statementService.validateBulkEditText(newText);
    if (!validation.isValid) {
      _showErrorSnackBar(validation.error!);
      return;
    }

    // Выполняем массовое редактирование
    final result = await _statementService.bulkEditStatements(
      statements,
      newText,
      categoryId,
    );

    if (result.success) {
      await _loadData();
      if (mounted) {
        _showSuccessSnackBar(
          'Обновлено: удалено ${result.deletedCount}, добавлено ${result.addedCount} фраз',
        );
      }
    } else {
      _showErrorSnackBar('Ошибка обновления: ${result.error}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Блок ввода текста
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextInputBlock(
                        onSayText: _sayText,
                        onDownloadText: _downloadText,
                      ),
                    ),

                    // Банк фраз
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: Focus(
                          focusNode: _phraseBankFocus,
                          child: PhraseBank(
                            categories: _categories,
                            statements: _statements,
                            onSayStatement: _sayStatement,
                            onEditStatement: _editStatement,
                            onDeleteStatement: _deleteStatement,
                            onEditCategory: _editCategory,
                            onDeleteCategory: _deleteCategory,
                            onAddStatement: _addStatement,
                            onAddCategory: _addCategory,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: _onCategorySelected,
                            onBulkEditStatements: _bulkEditStatements,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _phraseBankFocus.dispose();
    super.dispose();
  }
}
