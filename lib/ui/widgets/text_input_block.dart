import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../../services/tts_service.dart';

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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent && 
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    HardwareKeyboard.instance.isControlPressed) {
                  if (_hasText) {
                    _sayText();
                  }
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Введите текст для озвучивания',
                  border: OutlineInputBorder(),
                  hintText: 'Например: Привет, как дела? (Ctrl+Enter для озвучивания)',
                ),
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
    super.dispose();
  }
}
