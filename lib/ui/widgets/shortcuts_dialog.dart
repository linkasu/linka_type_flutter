import 'package:flutter/material.dart';

class ShortcutsDialog extends StatelessWidget {
  const ShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      {
        'key': 'Ctrl/Cmd + I',
        'description': 'Переход к главному текстовому полю',
      },
      {
        'key': 'Ctrl/Cmd + B',
        'description': 'Переход от главного текстового поля к банку фраз',
      },
      {
        'key': 'Ctrl/Cmd + Enter',
        'description': 'Озвучить текст в главном поле',
      },
    ];

    return AlertDialog(
      title: const Text('Горячие клавиши'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: shortcuts.length,
          itemBuilder: (context, index) {
            final shortcut = shortcuts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      shortcut['key']!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      shortcut['description']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
