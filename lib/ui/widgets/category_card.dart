import 'package:flutter/material.dart';
import '../../api/models/category.dart';
import 'item_card.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int statementCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.statementCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: category.title,
      subtitle: '$statementCount фраз',
      icon: Icons.folder,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
