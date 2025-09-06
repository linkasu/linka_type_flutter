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
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      onSecondaryTapDown: (details) => _showContextMenu(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppTheme.primaryColor, size: 16),
                  const SizedBox(height: 2),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Flexible(
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
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
    );
  }

  void _showContextMenu(BuildContext context) {
    final items = <ContextMenuItem>[];
    
    if (onPlay != null) {
      items.add(ContextMenuItem(
        icon: const Icon(Icons.play_arrow),
        title: 'Воспроизвести',
        onTap: onPlay!,
      ));
    }
    
    if (onEdit != null) {
      items.add(ContextMenuItem(
        icon: const Icon(Icons.edit),
        title: 'Редактировать',
        onTap: onEdit!,
      ));
    }
    
    if (onDelete != null) {
      items.add(ContextMenuItem(
        icon: const Icon(Icons.delete, color: Colors.red),
        title: 'Удалить',
        onTap: onDelete!,
        textStyle: const TextStyle(color: Colors.red),
      ));
    }

    if (items.isNotEmpty) {
      CrudDialogs.showContextMenu(context: context, items: items);
    }
  }
}
