import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/spotlight_theme.dart';
import '../widgets/spotlight_container.dart';

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

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
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
      body: SpotlightContainer(
        text: _textController.text,
        isEditing: isDesktop && _isEditing,
        controller: _textController,
        onTap: isDesktop ? _toggleEdit : null,
        onEditToggle: (editing) => setState(() => _isEditing = editing),
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
