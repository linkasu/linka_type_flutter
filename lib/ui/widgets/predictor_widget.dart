import 'package:flutter/material.dart';
import '../../services/predictor_service.dart';
import '../theme/app_theme.dart';

class PredictorWidget extends StatefulWidget {
  final String text;
  final Function(String) onPredictionSelected;
  final Function(List<String>)? onPredictionsUpdated;
  final Function(int)? onPosUpdated;
  final bool? register;

  const PredictorWidget({
    super.key,
    required this.text,
    required this.onPredictionSelected,
    this.onPredictionsUpdated,
    this.onPosUpdated,
    this.register,
  });

  @override
  State<PredictorWidget> createState() => _PredictorWidgetState();
}

class _PredictorWidgetState extends State<PredictorWidget> {
  List<String> _predictions = [];
  bool _isLoading = false;
  int _lastPos = 0;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  @override
  void didUpdateWidget(PredictorWidget oldWidget) {
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

  Color _getButtonColor() {
    if (widget.register == null) return AppTheme.secondaryColor;
    return widget.register! ? AppTheme.accentColor : AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
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
            color: Colors.grey[500],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Здесь будут подсказки при вводе',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
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
                color: _getButtonColor(),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Подсказки',
                style: TextStyle(
                  color: _getButtonColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'Ctrl+1-5 для выбора',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
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
                      backgroundColor: _getButtonColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _predictions[index],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
