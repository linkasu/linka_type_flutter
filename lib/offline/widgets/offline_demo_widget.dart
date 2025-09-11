import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_manager.dart';
import '../providers/sync_provider.dart';
import 'sync_status_widget.dart';

/// Демонстрационный виджет для показа работы оффлайн системы
class OfflineDemoWidget extends StatefulWidget {
  const OfflineDemoWidget({super.key});

  @override
  State<OfflineDemoWidget> createState() => _OfflineDemoWidgetState();
}

class _OfflineDemoWidgetState extends State<OfflineDemoWidget> {
  final TextEditingController _statementController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _statementController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус синхронизации
            SyncStatusWidget(
              syncState: syncProvider.syncState,
              onSyncPressed:
                  syncProvider.hasError ? () => syncProvider.forceSync() : null,
            ),

            const SizedBox(height: 16),

            // Информационная панель
            _buildInfoPanel(syncProvider),

            const SizedBox(height: 16),

            // Форма создания категории
            _buildCategoryForm(),

            const SizedBox(height: 16),

            // Форма создания фразы
            _buildStatementForm(),

            const SizedBox(height: 16),

            // Списки данных
            _buildDataLists(),
          ],
        );
      },
    );
  }

  Widget _buildInfoPanel(SyncProvider syncProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Оффлайн система',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            syncProvider.isOfflineMode
                ? 'Работа в оффлайн режиме. Изменения будут синхронизированы при подключении к интернету.'
                : 'Онлайн режим. Все изменения синхронизируются автоматически.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (syncProvider.hasPendingOperations) ...[
            const SizedBox(height: 8),
            Text(
              'Ожидающих операций: ${syncProvider.pendingOperations}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Создать категорию',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      hintText: 'Название категории',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createCategory,
                  child: const Text('Создать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Создать фразу',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _statementController,
              decoration: const InputDecoration(
                hintText: 'Текст фразы',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _createStatement,
              child: const Text('Создать фразу'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataLists() {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        return FutureBuilder(
          future: Future.wait([
            dataManager.getCategories(),
            dataManager.getStatements(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Ошибка загрузки данных: ${snapshot.error}'),
              );
            }

            final categories = snapshot.data?[0] as List? ?? [];
            final statements = snapshot.data?[1] as List? ?? [];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Список категорий
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Категории (${categories.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (categories.isEmpty)
                            const Text('Нет категорий')
                          else
                            ...categories.map((category) => ListTile(
                                  title: Text(category.title),
                                  subtitle: Text(
                                    'ID: ${category.id}\nОбновлено: ${category.updatedAt}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteCategory(category.id),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Список фраз
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Фразы (${statements.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (statements.isEmpty)
                            const Text('Нет фраз')
                          else
                            ...statements.map((statement) => ListTile(
                                  title: Text(statement.title),
                                  subtitle: Text(
                                    'Категория: ${statement.categoryId}\nОбновлено: ${statement.updatedAt}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteStatement(statement.id),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createCategory() async {
    final title = _categoryController.text.trim();
    if (title.isEmpty) return;

    try {
      final dataManager = context.read<DataManager>();
      await dataManager.createCategory(title);
      _categoryController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Категория создана')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания категории: $e')),
      );
    }
  }

  Future<void> _createStatement() async {
    final title = _statementController.text.trim();
    if (title.isEmpty) return;

    try {
      final dataManager = context.read<DataManager>();
      // Используем первую категорию или создаем тестовую
      final categories = await dataManager.getCategories();
      String categoryId;

      if (categories.isNotEmpty) {
        categoryId = categories.first.id;
      } else {
        // Создаем тестовую категорию
        final category = await dataManager.createCategory('Тестовая категория');
        categoryId = category.id;
      }

      await dataManager.createStatement(title, categoryId);
      _statementController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фраза создана')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания фразы: $e')),
      );
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      final dataManager = context.read<DataManager>();
      await dataManager.deleteCategory(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Категория удалена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления категории: $e')),
      );
    }
  }

  Future<void> _deleteStatement(String id) async {
    try {
      final dataManager = context.read<DataManager>();
      await dataManager.deleteStatement(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фраза удалена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления фразы: $e')),
      );
    }
  }
}
