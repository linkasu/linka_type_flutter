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
          Flexible(
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
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile ? constraints.maxWidth - 32 : (constraints.maxWidth - 48) / 2; // 100% на мобилках, 50% на десктопе
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12, // 1em отступы между карточками
            runSpacing: 12, // 1em отступы между рядами
            children: widget.categories.map((category) {
              final statementCount = widget.statements
                  .where((s) => s.categoryId == category.id)
                  .length;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: SizedBox(
                        width: cardWidth,
                        child: CategoryCard(
                          category: category,
                          statementCount: statementCount,
                          onTap: () => widget.onCategorySelected(category),
                          onEdit: () => widget.onEditCategory(category),
                          onDelete: () => widget.onDeleteCategory(category),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
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
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile ? constraints.maxWidth - 32 : (constraints.maxWidth - 48) / 2; // 100% на мобилках, 50% на десктопе
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12, // 1em отступы между карточками
            runSpacing: 12, // 1em отступы между рядами
            children: statements.map((statement) {
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: SizedBox(
                        width: cardWidth,
                        child: StatementCard(
                          statement: statement,
                          onTap: () => widget.onSayStatement(statement),
                          onEdit: () => widget.onEditStatement(statement),
                          onDelete: () => widget.onDeleteStatement(statement),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
