import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/statement_service.dart';
import '../../services/data_refresh_service.dart';
import '../../services/data_manager.dart';
import '../../services/analytics_manager.dart';
import '../../services/analytics_events.dart';
import '../../api/api.dart';
import '../../offline/models/sync_state.dart';
import '../theme/app_theme.dart';
import '../widgets/text_input_block.dart';
import '../widgets/phrase_bank.dart';
import '../widgets/crud_dialogs.dart';
import '../widgets/notification_banner.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TTSService _ttsService = TTSService.instance;
  final StatementService _statementService = StatementService();
  late final DataManager _dataManager;
  late final AnalyticsManager _analyticsManager;
  late final DataRefreshService _refreshService;
  final FocusNode _phraseBankFocus = FocusNode();

  List<Category> _categories = [];
  List<Statement> _statements = [];
  bool _isLoading = true;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _setupShortcuts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Инициализируем менеджеры данных
    _dataManager = context.read<DataManager>();
    _analyticsManager = context.read<AnalyticsManager>();
    _refreshService = DataRefreshService(_dataManager.offlineManager);

    // Получаем данные при первой загрузке
    if (!mounted) {
      return;
    }

    _loadData();
    _setupDataRefresh();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.screenView, data: {
      'screen_name': 'home_screen',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _setupShortcuts() {
    // Shortcuts are now handled globally in main.dart
  }

  void _setupDataRefresh() {
    // Настраиваем callbacks для обработки обновлений данных
    _refreshService.setCallbacks(
      onCategoriesUpdated: _onCategoriesUpdated,
      onStatementsUpdated: _onStatementsUpdated,
      onCategoryStatementsUpdated: _onCategoryStatementsUpdated,
      onSyncStateChanged: _onSyncStateChanged,
    );

    // Запускаем периодическую проверку каждые 5 секунд
    _refreshService.startPeriodicRefresh();

  }

  void _onCategoriesUpdated(List<Category> newCategories) {
    if (!mounted) return;

    // Проверяем, изменились ли категории
    final hasChanges = !_areCategoriesEqual(_categories, newCategories);

    if (hasChanges) {
      setState(() {
        _categories = newCategories;

        // Если выбранная категория была удалена, сбрасываем выбор
        if (_selectedCategory != null) {
          final stillExists =
              newCategories.any((cat) => cat.id == _selectedCategory!.id);
          if (!stillExists) {
            _selectedCategory = null;
          }
        }
      });

      // Показываем уведомление о обновлении
      _showUpdateNotification('Категории обновлены');

    }
  }

  void _onStatementsUpdated(List<Statement> newStatements) {
    if (!mounted) return;


    // Проверяем, изменились ли фразы
    final hasChanges = !_areStatementsEqual(_statements, newStatements);

    if (hasChanges) {
      setState(() {
        _statements = newStatements;
      });

      // Показываем уведомление о обновлении
      _showUpdateNotification('Фразы обновлены');

    } else {
    }
  }

  void _onCategoryStatementsUpdated(
      Category? category, List<Statement> statements) {
    if (!mounted || category == null) return;

    // Обновляем фразы только для выбранной категории
    final categoryStatements =
        statements.where((stmt) => stmt.categoryId == category.id).toList();

    final currentCategoryStatements =
        _statements.where((stmt) => stmt.categoryId == category.id).toList();

    final hasChanges =
        !_areStatementsEqual(currentCategoryStatements, categoryStatements);

    if (hasChanges) {
      // Обновляем только фразы этой категории
      final otherStatements =
          _statements.where((stmt) => stmt.categoryId != category.id).toList();

      setState(() {
        _statements = [...otherStatements, ...categoryStatements];
      });

      _showUpdateNotification(
          'Фразы в категории "${category.title}" обновлены');

    }
  }

  void _onSyncStateChanged(SyncState syncState) {
    if (!mounted) return;


    // Обновляем UI в зависимости от состояния синхронизации
    if (syncState.status == SyncStatus.synced &&
        syncState.hasPendingOperations) {
      _showUpdateNotification('Синхронизация завершена');
    } else if (syncState.hasError) {
      _showErrorSnackBar(
          'Ошибка синхронизации: ${syncState.errorMessage ?? "Неизвестная ошибка"}');
    }
  }

  bool _areCategoriesEqual(List<Category> list1, List<Category> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].title != list2[i].title ||
          list1[i].updatedAt != list2[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  bool _areStatementsEqual(List<Statement> list1, List<Statement> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].title != list2[i].title ||
          list1[i].categoryId != list2[i].categoryId ||
          list1[i].updatedAt != list2[i].updatedAt) {
        return false;
      }
    }
    return true;
  }

  void _showUpdateNotification(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'ОК',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final categories = await _dataManager.getCategories();
      final statements = await _dataManager.getStatements();

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
    await _analyticsManager.trackEvent(AnalyticsEvents.ttsStarted, data: {
      'text_length': text.length,
      'source': 'text_input',
    });
    await _ttsService.say(text);
  }

  Future<void> _downloadText(String text) async {
    await _analyticsManager.trackEvent(AnalyticsEvents.ttsStarted, data: {
      'text_length': text.length,
      'source': 'text_input',
      'download': true,
    });
    await _ttsService.say(text, download: true);
  }

  Future<void> _sayStatement(Statement statement) async {
    await _analyticsManager.trackEvent(AnalyticsEvents.ttsStarted, data: {
      'statement_id': statement.id,
      'category_id': statement.categoryId,
      'text_length': statement.title.length,
      'source': 'phrase_bank',
    });
    await _ttsService.say(statement.title);
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
    });

    // Трекинг события выбора категории
    _analyticsManager.trackEvent(AnalyticsEvents.categoryViewed, data: {
      'category_id': category?.id,
      'category_title': category?.title,
    });

    // Устанавливаем категорию для мониторинга в refresh service
    _refreshService.setMonitoredCategory(category);

    // Если выбрана категория, сразу проверяем её фразы
    if (category != null) {
      _refreshService.checkCategoryStatements(category);
    }
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
        await _dataManager.updateStatement(
          statement.id,
          result['text']!,
          result['dropdown']!,
        );

        // Трекинг успешного обновления
        await _analyticsManager
            .trackEvent(AnalyticsEvents.statementUpdated, data: {
          'statement_id': statement.id,
          'old_category_id': statement.categoryId,
          'new_category_id': result['dropdown']!,
          'text_length': result['text']!.length,
        });

        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза обновлена')));
        }
      } catch (e) {
        // Трекинг ошибки обновления
        await _analyticsManager
            .trackEvent(AnalyticsEvents.errorOccurred, data: {
          'error_type': 'statement_update_failed',
          'statement_id': statement.id,
          'error_message': e.toString(),
        });

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
        await _dataManager.deleteStatement(statement.id);

        // Трекинг успешного удаления
        await _analyticsManager
            .trackEvent(AnalyticsEvents.statementDeleted, data: {
          'statement_id': statement.id,
          'category_id': statement.categoryId,
          'text_length': statement.title.length,
        });

        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза удалена')));
        }
      } catch (e) {
        // Трекинг ошибки удаления
        await _analyticsManager
            .trackEvent(AnalyticsEvents.errorOccurred, data: {
          'error_type': 'statement_delete_failed',
          'statement_id': statement.id,
          'error_message': e.toString(),
        });

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
        await _dataManager.updateCategory(category.id, result);
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
        await _dataManager.deleteCategory(category.id);
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
        await _dataManager.createCategory(result);

        // Трекинг успешного создания категории
        await _analyticsManager
            .trackEvent(AnalyticsEvents.categoryCreated, data: {
          'category_title': result,
          'title_length': result.length,
        });

        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Категория добавлена')));
        }
      } catch (e) {
        // Трекинг ошибки создания
        await _analyticsManager
            .trackEvent(AnalyticsEvents.errorOccurred, data: {
          'error_type': 'category_create_failed',
          'category_title': result,
          'error_message': e.toString(),
        });

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
        await _dataManager.createStatement(
          result['text']!,
          result['dropdown']!,
        );

        // Трекинг успешного создания фразы
        await _analyticsManager
            .trackEvent(AnalyticsEvents.statementCreated, data: {
          'category_id': result['dropdown']!,
          'text_length': result['text']!.length,
          'selected_category_id': _selectedCategory?.id,
        });

        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Фраза добавлена')));
        }
      } catch (e) {
        // Трекинг ошибки создания
        await _analyticsManager
            .trackEvent(AnalyticsEvents.errorOccurred, data: {
          'error_type': 'statement_create_failed',
          'category_id': result['dropdown']!,
          'text_length': result['text']!.length,
          'error_message': e.toString(),
        });

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

  Future<void> _bulkDownloadToCache(List<String> phrases, String voice) async {
    if (!mounted) return;

    // Получаем текущий голос из настроек TTS, если передан маркер 'current'
    String actualVoice = voice;
    if (voice == 'current') {
      final currentVoiceData = await _ttsService.getSelectedVoice();
      actualVoice = currentVoiceData.voiceURI;
    }

    // Создаем прогресс нотифаер для отслеживания прогресса
    final progressNotifier = ValueNotifier<(int, int)>((0, phrases.length));

    // Показываем диалог прогресса
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BulkDownloadProgressDialog(
        totalPhrases: phrases.length,
        progressNotifier: progressNotifier,
        onDownload: () async {
          await _ttsService.downloadPhrasesToCache(
            phrases,
            actualVoice,
            (current, total) {
              if (mounted) {
                progressNotifier.value = (current, total);
              }
            },
          );
        },
      ),
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
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await _analyticsManager
                  .trackEvent(AnalyticsEvents.buttonClicked, data: {
                'button_name': 'settings',
                'screen': 'home_screen',
              });
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
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
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
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
                                onBulkDownloadToCache: _bulkDownloadToCache,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

          // Баннер уведомлений
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationBanner(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshService.dispose();
    _phraseBankFocus.dispose();
    super.dispose();
  }
}

class _BulkDownloadProgressDialog extends StatefulWidget {
  final int totalPhrases;
  final ValueNotifier<(int, int)> progressNotifier;
  final Future<void> Function() onDownload;

  const _BulkDownloadProgressDialog({
    required this.totalPhrases,
    required this.progressNotifier,
    required this.onDownload,
  });

  @override
  State<_BulkDownloadProgressDialog> createState() =>
      _BulkDownloadProgressDialogState();
}

class _BulkDownloadProgressDialogState
    extends State<_BulkDownloadProgressDialog> {
  bool _isDownloading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      await widget.onDownload();
      setState(() {
        _isCompleted = true;
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при скачивании: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Скачивание в кеш'),
      content: ValueListenableBuilder<(int, int)>(
        valueListenable: widget.progressNotifier,
        builder: (context, progress, child) {
          final (current, total) = progress;
          final progressValue = total > 0 ? current / total : 0.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: _isCompleted ? 1.0 : progressValue,
              ),
              const SizedBox(height: 16),
              Text(
                _isCompleted
                    ? 'Скачивание завершено'
                    : 'Скачивание: $current из $total фраз',
                textAlign: TextAlign.center,
              ),
              if (_isCompleted) ...[
                const SizedBox(height: 16),
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        if (_isCompleted)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Готово'),
          )
        else if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
