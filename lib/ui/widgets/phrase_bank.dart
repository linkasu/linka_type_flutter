import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../api/models/category.dart';
import '../../api/models/statement.dart';

class PhraseBank extends StatefulWidget {
  final List<Category> categories;
  final List<Statement> statements;
  final Function(Statement) onSayStatement;
  final Function(Statement) onEditStatement;
  final Function(Statement) onDeleteStatement;
  final Function(Category) onEditCategory;
  final Function(Category) onDeleteCategory;
  final VoidCallback onAddStatement;

  const PhraseBank({
    super.key,
    required this.categories,
    required this.statements,
    required this.onSayStatement,
    required this.onEditStatement,
    required this.onDeleteStatement,
    required this.onEditCategory,
    required this.onDeleteCategory,
    required this.onAddStatement,
  });

  @override
  State<PhraseBank> createState() => _PhraseBankState();
}

class _PhraseBankState extends State<PhraseBank> {
  bool _showCategories = true;
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок и навигация
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (!_showCategories)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _showCategories = true;
                        _selectedCategory = null;
                      });
                    },
                    tooltip: 'Назад к категориям',
                  ),
                const Icon(Icons.library_books, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  _showCategories ? 'Выберите категорию' : 'Фразы: ${_selectedCategory?.title ?? ""}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_showCategories)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: widget.onAddStatement,
                    tooltip: 'Добавить фразу',
                  ),
              ],
            ),
          ),
          
          // Контент
          Expanded(
            child: _showCategories
                ? _buildCategoriesGrid()
                : _buildStatementsGrid(),
          ),
        ],
      ),
    );
  }

  // Построение сетки категорий
  Widget _buildCategoriesGrid() {
    if (widget.categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет категорий', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Добавьте категории в настройках', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final statementCount = widget.statements.where((s) => s.categoryId == category.id).length;
        
        return Card(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _showCategories = false;
              });
            },
            onLongPress: () => _showCategoryContextMenu(context, category),
            onSecondaryTapDown: (details) => _showCategoryContextMenu(context, category),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$statementCount фраз',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Построение сетки фраз
  Widget _buildStatementsGrid() {
    final statements = widget.statements.where((s) => s.categoryId == _selectedCategory!.id).toList();
    
    if (statements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет фраз в этой категории', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Нажмите + чтобы добавить фразу', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: statements.length,
      itemBuilder: (context, index) {
        final statement = statements[index];
        
        return GestureDetector(
          onTap: () => widget.onSayStatement(statement),
          onLongPress: () => _showStatementContextMenu(context, statement),
          onSecondaryTapDown: (details) => _showStatementContextMenu(context, statement),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  statement.title,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Контекстное меню для категории
  void _showCategoryContextMenu(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                widget.onEditCategory(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onDeleteCategory(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Контекстное меню для фразы
  void _showStatementContextMenu(BuildContext context, Statement statement) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Воспроизвести'),
              onTap: () {
                Navigator.pop(context);
                widget.onSayStatement(statement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                widget.onEditStatement(statement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onDeleteStatement(statement);
              },
            ),
          ],
        ),
      ),
    );
  }
}
