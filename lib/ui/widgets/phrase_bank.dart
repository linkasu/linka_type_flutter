import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../api/models/category.dart';
import '../../api/models/statement.dart';
import 'category_card.dart';
import 'statement_card.dart';

class PhraseBank extends StatefulWidget {
  final List<Category> categories;
  final List<Statement> statements;
  final Function(Statement) onSayStatement;
  final Function(Statement) onEditStatement;
  final Function(Statement) onDeleteStatement;
  final Function(Category) onEditCategory;
  final Function(Category) onDeleteCategory;
  final VoidCallback onAddStatement;
  final VoidCallback onAddCategory;
  final Category? selectedCategory;
  final Function(Category?) onCategorySelected;

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
    required this.onAddCategory,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<PhraseBank> createState() => _PhraseBankState();
}

class _PhraseBankState extends State<PhraseBank> {
  bool get _showCategories => widget.selectedCategory == null;
  Category? get _selectedCategory => widget.selectedCategory;

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
                      widget.onCategorySelected(null);
                    },
                    tooltip: 'Назад к категориям',
                  ),
                const Icon(Icons.library_books, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _showCategories
                        ? 'Выберите категорию'
                        : 'Фразы: ${_selectedCategory?.title ?? ""}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                if (_showCategories)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: widget.onAddCategory,
                    tooltip: 'Добавить категорию',
                  )
                else
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
            Text(
              'Нет категорий',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить категорию',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем количество колонок в зависимости от ширины экрана
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        final childAspectRatio = constraints.maxWidth > 600 ? 2.5 : 6.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final category = widget.categories[index];
            final statementCount = widget.statements
                .where((s) => s.categoryId == category.id)
                .length;

            return CategoryCard(
              category: category,
              statementCount: statementCount,
              onTap: () => widget.onCategorySelected(category),
              onEdit: () => widget.onEditCategory(category),
              onDelete: () => widget.onDeleteCategory(category),
            );
          },
        );
      },
    );
  }

  // Построение сетки фраз
  Widget _buildStatementsGrid() {
    final statements = widget.statements
        .where((s) => s.categoryId == _selectedCategory!.id)
        .toList();

    if (statements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нет фраз в этой категории',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить фразу',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем количество колонок в зависимости от ширины экрана
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        final childAspectRatio = constraints.maxWidth > 600 ? 2.5 : 6.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: statements.length,
          itemBuilder: (context, index) {
            final statement = statements[index];

            return StatementCard(
              statement: statement,
              onTap: () => widget.onSayStatement(statement),
              onEdit: () => widget.onEditStatement(statement),
              onDelete: () => widget.onDeleteStatement(statement),
            );
          },
        );
      },
    );
  }
}
