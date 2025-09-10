import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'crud_dialogs.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPlay;

  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    const double baseFontSize = 12.0;
    const double cardHeight = baseFontSize * 5; // высота: 5em

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      onSecondaryTapDown: (details) => _showContextMenu(context),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final items = <ContextMenuItem>[];

    if (onPlay != null) {
      items.add(
        ContextMenuItem(
          icon: const Icon(Icons.play_arrow),
          title: 'Воспроизвести',
          onTap: onPlay!,
        ),
      );
    }

    if (onEdit != null) {
      items.add(
        ContextMenuItem(
          icon: const Icon(Icons.edit),
          title: 'Редактировать',
          onTap: onEdit!,
        ),
      );
    }

    if (onDelete != null) {
      items.add(
        ContextMenuItem(
          icon: const Icon(Icons.delete, color: Colors.red),
          title: 'Удалить',
          onTap: onDelete!,
          textStyle: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (items.isNotEmpty) {
      CrudDialogs.showContextMenu(context: context, items: items);
    }
  }
}
