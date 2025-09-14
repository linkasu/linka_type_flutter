import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TextUtils {
  static const double defaultFontSize = 48;
  static const double minFontSize = 12;
  static const double maxFontSize = 200;
  static const double fontSizeStep = 4;
  static const double paddingOffset = 48;
  static const double lineHeight = 1.2;

  static double calculateOptimalFontSize(
    BoxConstraints constraints,
    String text, {
    double? minSize,
    double? maxSize,
    double? step,
    double? padding,
    double? textScaleFactor,
  }) {
    if (text.isEmpty) return defaultFontSize;

    final min = minSize ?? minFontSize;
    final max = maxSize ?? maxFontSize;
    final stepSize = step ?? fontSizeStep;
    final paddingSize = padding ?? paddingOffset;
    final scaleFactor = textScaleFactor ?? 1.0;

    double fontSize = max;

    while (fontSize > min) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: lineHeight,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: null,
        textScaleFactor: scaleFactor,
      );

      textPainter.layout(maxWidth: constraints.maxWidth - paddingSize);

      if (textPainter.height <= constraints.maxHeight - paddingSize) {
        break;
      }
      fontSize -= stepSize;
    }

    return fontSize.clamp(min, max);
  }
}
