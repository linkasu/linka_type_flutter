import 'package:flutter/material.dart';
import '../utils/text_utils.dart';
import '../theme/spotlight_theme.dart';

class AutoSizeTextDisplay extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEditing;
  final TextEditingController? controller;
  final ValueChanged<bool>? onEditToggle;

  const AutoSizeTextDisplay({
    super.key,
    required this.text,
    this.onTap,
    this.isEditing = false,
    this.controller,
    this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaleFactor = MediaQuery.textScaleFactorOf(context);
        final fontSize = TextUtils.calculateOptimalFontSize(
          constraints,
          text,
          textScaleFactor: textScaleFactor,
        );

        if (isEditing && controller != null) {
          return _buildEditableText(fontSize);
        } else {
          return _buildDisplayText(fontSize);
        }
      },
    );
  }

  Widget _buildEditableText(double fontSize) {
    return Container(
      color: SpotlightTheme.backgroundColor,
      child: TextField(
        controller: controller,
        style: SpotlightTheme.textStyle.copyWith(fontSize: fontSize),
        maxLines: null,
        expands: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          hintText: 'Введите текст...',
          hintStyle: SpotlightTheme.hintStyle.copyWith(fontSize: fontSize),
        ),
      ),
    );
  }

  Widget _buildDisplayText(double fontSize) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(SpotlightTheme.contentPadding),
        child: Center(
          child: Text(
            text.isEmpty ? 'Нажмите для редактирования' : text,
            style: SpotlightTheme.textStyle.copyWith(fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
