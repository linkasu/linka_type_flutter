import 'package:flutter/material.dart';

class SpotlightTheme {
  // Используем цвета из предоставленной схемы
  static const Color backgroundColor =
      Color(0xFF000000); // spotlight_background
  static const Color textColor = Color(0xFFFFFFFF); // spotlight_text
  static const Color borderColor = Color(0xFFFBCC30); // colorAccent для границ
  static const Color hintColor = Color(0x66FFFFFF); // полупрозрачный белый
  static const Color buttonBackgroundColor = Color(0xFFFBCC30); // colorAccent
  static const Color buttonForegroundColor =
      Color(0xFF000000); // черный текст на желтом фоне

  static const double borderWidth = 2;
  static const double borderRadius = 8;
  static const double contentPadding = 24;
  static const double closeIconSize = 32;

  static const double horizontalMarginPercent = 0.2;
  static const double verticalMarginPercent = 0.1;

  static const TextStyle textStyle = TextStyle(
    color: textColor,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle hintStyle = TextStyle(
    color: hintColor,
    fontWeight: FontWeight.bold,
  );

  static const BoxDecoration containerDecoration = BoxDecoration(
    border: Border.fromBorderSide(
      BorderSide(color: borderColor, width: borderWidth),
    ),
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  );
}
