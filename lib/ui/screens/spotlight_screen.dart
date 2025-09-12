import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/spotlight_theme.dart';
import '../widgets/spotlight_container.dart';
import '../widgets/spotlight_predictor_widget.dart';
import '../../services/shortcut_controller.dart';

class SpotlightScreen extends StatefulWidget {
  final String initialText;

  const SpotlightScreen({
    super.key,
    required this.initialText,
  });

  @override
  State<SpotlightScreen> createState() => _SpotlightScreenState();
}

class _SpotlightScreenState extends State<SpotlightScreen> {
  late TextEditingController _textController;
  bool _isEditing = false;
  final ShortcutController _shortcutController = ShortcutController();
  List<String> _currentPredictions = [];
  int _currentPos = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController.addListener(() {
      setState(() {});
    });
    _shortcutController.setCloseSpotlightCallback(() {
      Navigator.of(context).pop();
    });
    _shortcutController.setPredictionCallback((index) {
      _onPredictionShortcut(index);
    });

    // Автоматически включаем редактирование на десктопах при переходе в режим показа
    final isDesktop = kIsWeb ||
        (defaultTargetPlatform == TargetPlatform.windows) ||
        (defaultTargetPlatform == TargetPlatform.macOS) ||
        (defaultTargetPlatform == TargetPlatform.linux);

    if (isDesktop) {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    // Сбрасываем callback при закрытии экрана
    _shortcutController.setCloseSpotlightCallback(null);
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = kIsWeb ||
        (defaultTargetPlatform == TargetPlatform.windows) ||
        (defaultTargetPlatform == TargetPlatform.macOS) ||
        (defaultTargetPlatform == TargetPlatform.linux);

    return Scaffold(
      backgroundColor: SpotlightTheme.backgroundColor,
      body: Column(
        children: [
          // Предиктор только на десктопах и в режиме редактирования
          if (isDesktop && _isEditing) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SpotlightPredictorWidget(
                text: _textController.text,
                onPredictionSelected: _onPredictionSelected,
                onPredictionsUpdated: _onPredictionsUpdated,
                onPosUpdated: _onPosUpdated,
              ),
            ),
          ],
          Expanded(
            child: SpotlightContainer(
              text: _textController.text,
              isEditing: isDesktop && _isEditing,
              controller: _textController,
              onTap: isDesktop ? _toggleEdit : null,
              onEditToggle: (editing) => setState(() => _isEditing = editing),
            ),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? FloatingActionButton(
              onPressed: _toggleEdit,
              backgroundColor: SpotlightTheme.buttonBackgroundColor,
              foregroundColor: SpotlightTheme.buttonForegroundColor,
              child: Icon(_isEditing ? Icons.visibility : Icons.edit),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: SpotlightTheme.textColor,
            size: SpotlightTheme.closeIconSize,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
