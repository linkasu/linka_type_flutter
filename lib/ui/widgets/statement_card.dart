import 'package:flutter/material.dart';
import '../../api/models/statement.dart';
import 'item_card.dart';

class StatementCard extends StatelessWidget {
  final Statement statement;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StatementCard({
    super.key,
    required this.statement,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: statement.title,
      onTap: onTap,
      onPlay: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
