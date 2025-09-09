import 'package:flutter/material.dart';
import '../theme/spotlight_theme.dart';
import 'auto_size_text_display.dart';

class SpotlightContainer extends StatelessWidget {
  final String text;
  final bool isEditing;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onEditToggle;

  const SpotlightContainer({
    super.key,
    required this.text,
    this.isEditing = false,
    this.controller,
    this.onTap,
    this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * SpotlightTheme.horizontalMarginPercent,
        vertical: screenSize.height * SpotlightTheme.verticalMarginPercent,
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: SpotlightTheme.containerDecoration,
          child: AutoSizeTextDisplay(
            text: text,
            isEditing: isEditing,
            controller: controller,
            onTap: onTap,
            onEditToggle: onEditToggle,
          ),
        ),
      ),
    );
  }
}
