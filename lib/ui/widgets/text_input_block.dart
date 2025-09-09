import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/spotlight_screen.dart';
import '../../services/shortcut_controller.dart';

class TextInputBlock extends StatefulWidget {
  final Function(String) onSayText;
  final Function(String) onDownloadText;

  const TextInputBlock({
    super.key,
    required this.onSayText,
    required this.onDownloadText,
  });

  @override
  State<TextInputBlock> createState() => _TextInputBlockState();
}

class _TextInputBlockState extends State<TextInputBlock> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ShortcutController _shortcutController = ShortcutController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _shortcutController.setMainTextFieldFocus(_focusNode);
    _shortcutController.setSayTextCallback(() {
      if (_hasText) {
        _sayText();
      }
    });
    _shortcutController.setShowSpotlightCallback(() {
      _showSpotlight();
    });
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  void _sayText({bool download = false}) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      if (download) {
        widget.onDownloadText(text);
      } else {
        widget.onSayText(text);
      }
    }
  }

  void _showSpotlight() {
    final text = _textController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpotlightScreen(initialText: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 3,
              onSubmitted: (value) {
                if (_hasText) {
                  _sayText();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Введите текст для озвучивания',
                border: OutlineInputBorder(),
                hintText:
                    'Например: Привет, как дела? (Ctrl+Enter для озвучивания, Ctrl+I для фокуса)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hasText ? _sayText : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Сказать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _hasText ? () => _sayText(download: true) : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Скачать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showSpotlight,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Показать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
