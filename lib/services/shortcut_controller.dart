import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
  Function(int)? _predictionCallback;

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

  void setPredictionCallback(Function(int)? callback) {
    _predictionCallback = callback;
  }

  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Горячие клавиши работают только на десктопах
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.linux &&
        defaultTargetPlatform != TargetPlatform.windows &&
        defaultTargetPlatform != TargetPlatform.macOS) {
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
        case LogicalKeyboardKey.digit1:
        case LogicalKeyboardKey.digit2:
        case LogicalKeyboardKey.digit3:
        case LogicalKeyboardKey.digit4:
        case LogicalKeyboardKey.digit5:
          _handlePredictionShortcut(event.logicalKey);
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

  void _handlePredictionShortcut(LogicalKeyboardKey key) {
    if (_predictionCallback != null) {
      int index = 0;
      switch (key) {
        case LogicalKeyboardKey.digit1:
          index = 0;
          break;
        case LogicalKeyboardKey.digit2:
          index = 1;
          break;
        case LogicalKeyboardKey.digit3:
          index = 2;
          break;
        case LogicalKeyboardKey.digit4:
          index = 3;
          break;
        case LogicalKeyboardKey.digit5:
          index = 4;
          break;
        default:
          return;
      }
      _predictionCallback!(index);
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
    _predictionCallback = null;
  }
}
