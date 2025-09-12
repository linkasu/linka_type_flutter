import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutInfo {
  final String description;
  final String keyCombination;
  final VoidCallback action;

  const ShortcutInfo({
    required this.description,
    required this.keyCombination,
    required this.action,
  });
}

class ShortcutController {
  static final ShortcutController _instance = ShortcutController._internal();
  factory ShortcutController() => _instance;
  ShortcutController._internal();

  final Map<String, ShortcutInfo> _shortcuts = {};
  FocusNode? _mainTextFieldFocus;
  VoidCallback? _sayTextCallback;
  VoidCallback? _showSpotlightCallback;
  VoidCallback? _closeSpotlightCallback;

  void registerShortcut(String key, ShortcutInfo shortcut) {
    _shortcuts[key] = shortcut;
  }

  void unregisterShortcut(String key) {
    _shortcuts.remove(key);
  }

  void setMainTextFieldFocus(FocusNode focusNode) {
    _mainTextFieldFocus = focusNode;
  }

  void setSayTextCallback(VoidCallback callback) {
    _sayTextCallback = callback;
  }

  void setShowSpotlightCallback(VoidCallback callback) {
    _showSpotlightCallback = callback;
  }

  void setCloseSpotlightCallback(VoidCallback? callback) {
    _closeSpotlightCallback = callback;
  }

  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isCtrlPressed) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyI:
          _focusToMainTextField();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.keyB:
          if (_closeSpotlightCallback != null) {
            _closeSpotlight();
          } else {
            _showSpotlight();
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
          _sayText();
          return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _focusToMainTextField() {
    if (_mainTextFieldFocus != null) {
      _mainTextFieldFocus!.requestFocus();
    }
  }

  void _sayText() {
    if (_sayTextCallback != null) {
      _sayTextCallback!();
    }
  }

  void _showSpotlight() {
    if (_showSpotlightCallback != null) {
      _showSpotlightCallback!();
    }
  }

  void _closeSpotlight() {
    if (_closeSpotlightCallback != null) {
      _closeSpotlightCallback!();
      _closeSpotlightCallback = null;
    }
  }

  List<ShortcutInfo> getAllShortcuts() {
    return _shortcuts.values.toList();
  }

  void clear() {
    _shortcuts.clear();
    _mainTextFieldFocus = null;
    _sayTextCallback = null;
    _showSpotlightCallback = null;
    _closeSpotlightCallback = null;
  }
}
