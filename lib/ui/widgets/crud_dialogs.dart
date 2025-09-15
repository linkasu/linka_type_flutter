import 'package:flutter/material.dart';

class CrudDialogs {
  static Future<String?> showTextInputDialog({
    required BuildContext context,
    required String title,
    required String labelText,
    String? initialValue,
    String? hintText,
    int maxLines = 1,
    bool autofocus = true,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          autofocus: autofocus,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, String>?> showTextWithDropdownDialog({
    required BuildContext context,
    required String title,
    required String textLabel,
    required String dropdownLabel,
    required List<Map<String, String>> dropdownItems,
    String? initialText,
    String? initialDropdownValue,
    int textMaxLines = 1,
  }) async {
    final TextEditingController textController = TextEditingController(
      text: initialText,
    );
    String? selectedValue = initialDropdownValue;

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: textLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: textMaxLines,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  labelText: dropdownLabel,
                  border: const OutlineInputBorder(),
                ),
                items: dropdownItems.map((item) {
                  return DropdownMenuItem(
                    value: item['value'],
                    child: Text(item['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty &&
                    selectedValue != null) {
                  Navigator.of(context).pop({
                    'text': textController.text.trim(),
                    'dropdown': selectedValue!,
                  });
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Удалить',
    String cancelText = 'Отмена',
    bool isDestructive = true,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showContextMenu({
    required BuildContext context,
    required List<ContextMenuItem> items,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (item) => ListTile(
                  leading: item.icon,
                  title: Text(item.title, style: item.textStyle),
                  onTap: () {
                    Navigator.pop(context);
                    item.onTap();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ContextMenuItem {
  final Icon icon;
  final String title;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  ContextMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textStyle,
  });
}
