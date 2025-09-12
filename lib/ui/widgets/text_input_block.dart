import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';
import '../screens/spotlight_screen.dart';
import '../../services/shortcut_controller.dart';
import 'predictor_widget.dart';

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
  List<String> _currentPredictions = [];
  int _currentPos = 0;

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
    _shortcutController.setPredictionCallback((index) {
      _onPredictionShortcut(index);
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

  void _onPredictionSelected(String prediction) {
    final currentText = _textController.text;
    final selection = _textController.selection;

    // Вычисляем позицию для вставки с учетом pos
    final insertPosition =
        _currentPos < 0 ? selection.start + _currentPos : selection.start;
    final deleteStart = insertPosition;
    final deleteEnd = selection.start;

    // Формируем текст для вставки
    String textToInsert = prediction;
    if (_currentPos == 1) {
      textToInsert = ' $prediction';
    } else {
      textToInsert = '$prediction ';
    }

    // Вставляем предсказание, удаляя нужное количество символов
    final newText = currentText.replaceRange(
      deleteStart,
      deleteEnd,
      textToInsert,
    );

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: insertPosition + textToInsert.length,
    );
  }

  void _onPredictionShortcut(int index) {
    if (index < _currentPredictions.length) {
      _onPredictionSelected(_currentPredictions[index]);
    }
  }

  void _onPredictionsUpdated(List<String> predictions) {
    setState(() {
      _currentPredictions = predictions;
    });
  }

  void _onPosUpdated(int pos) {
    setState(() {
      _currentPos = pos;
    });
  }

  String _getHintText() {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'Например: Привет, как дела? (Enter для озвучивания, Ctrl+I для фокуса, Ctrl+1-5 для выбора подсказок)';
    } else {
      return 'Например: Привет, как дела? (Enter для озвучивания)';
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
            // Предиктор только на десктопах
            if (kIsWeb ||
                defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS) ...[
              PredictorWidget(
                text: _textController.text,
                onPredictionSelected: _onPredictionSelected,
                onPredictionsUpdated: _onPredictionsUpdated,
                onPosUpdated: _onPosUpdated,
                register: null, // Можно настроить в зависимости от контекста
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (_hasText) {
                  _sayText();
                  // Оставляем фокус в поле после произнесения
                  _focusNode.requestFocus();
                }
              },
              decoration: InputDecoration(
                labelText: 'Введите текст для озвучивания',
                border: const OutlineInputBorder(),
                hintText: _getHintText(),
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
