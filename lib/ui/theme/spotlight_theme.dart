import 'package:flutter/material.dart';

class SpotlightTheme {
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;
  static const Color borderColor = Colors.white;
  static const Color hintColor = Colors.white54;
  static const Color buttonBackgroundColor = Colors.white;
  static const Color buttonForegroundColor = Colors.black;

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
