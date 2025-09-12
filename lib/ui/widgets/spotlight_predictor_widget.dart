import 'package:flutter/material.dart';
import '../../services/predictor_service.dart';
import '../theme/spotlight_theme.dart';

class SpotlightPredictorWidget extends StatefulWidget {
  final String text;
  final Function(String) onPredictionSelected;
  final Function(List<String>)? onPredictionsUpdated;
  final Function(int)? onPosUpdated;

  const SpotlightPredictorWidget({
    super.key,
    required this.text,
    required this.onPredictionSelected,
    this.onPredictionsUpdated,
    this.onPosUpdated,
  });

  @override
  State<SpotlightPredictorWidget> createState() =>
      _SpotlightPredictorWidgetState();
}

class _SpotlightPredictorWidgetState extends State<SpotlightPredictorWidget> {
  List<String> _predictions = [];
  bool _isLoading = false;
  int _lastPos = 0;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  @override
  void didUpdateWidget(SpotlightPredictorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _loadPredictions();
    }
  }

  Future<void> _loadPredictions() async {
    if (widget.text.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await PredictorService.getPredictions(widget.text);

    if (mounted) {
      setState(() {
        _predictions = response?.text ?? [];
        _lastPos = response?.pos ?? 0;
        _isLoading = false;
      });

      // Уведомляем родительский виджет о новых предсказаниях
      if (widget.onPredictionsUpdated != null) {
        widget.onPredictionsUpdated!(_predictions);
      }

      // Уведомляем о позиции для удаления символов
      if (widget.onPosUpdated != null) {
        widget.onPosUpdated!(_lastPos);
      }
    }
  }

  void _onPredictionTap(int index) {
    if (index < _predictions.length) {
      widget.onPredictionSelected(_predictions[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpotlightTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_predictions.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: SpotlightTheme.hintColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Здесь будут подсказки при вводе',
            style: SpotlightTheme.hintStyle.copyWith(fontSize: 14),
          ),
        ],
      );
    }

    return Opacity(
      opacity: _isLoading ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: SpotlightTheme.textColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Подсказки',
                style: SpotlightTheme.textStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Ctrl+1-5 для выбора',
                style: SpotlightTheme.hintStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_predictions.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: index < _predictions.length - 1 ? 8.0 : 0),
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _onPredictionTap(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpotlightTheme.buttonBackgroundColor,
                      foregroundColor: SpotlightTheme.buttonForegroundColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: SpotlightTheme.borderColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: SpotlightTheme.buttonForegroundColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  SpotlightTheme.borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SpotlightTheme.buttonForegroundColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _predictions[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: SpotlightTheme.buttonForegroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
