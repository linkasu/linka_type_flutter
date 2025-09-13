/// Константы для типов событий аналитики
class AnalyticsEvents {
  // События аутентификации
  static const String userLogin = 'user_login';
  static const String userLogout = 'user_logout';
  static const String userRegister = 'user_register';
  static const String passwordReset = 'password_reset';

  // События навигации
  static const String screenView = 'screen_view';
  static const String screenExit = 'screen_exit';
  static const String tabSwitch = 'tab_switch';

  // События категорий
  static const String categoryCreated = 'category_created';
  static const String categoryUpdated = 'category_updated';
  static const String categoryDeleted = 'category_deleted';
  static const String categoryViewed = 'category_viewed';

  // События утверждений (фраз)
  static const String statementCreated = 'statement_created';
  static const String statementUpdated = 'statement_updated';
  static const String statementDeleted = 'statement_deleted';
  static const String statementViewed = 'statement_viewed';
  static const String statementCopied = 'statement_copied';
  static const String statementShared = 'statement_shared';

  // События поиска
  static const String searchPerformed = 'search_performed';
  static const String searchResultClicked = 'search_result_clicked';
  static const String searchCleared = 'search_cleared';

  // События фильтрации
  static const String filterApplied = 'filter_applied';
  static const String filterCleared = 'filter_cleared';
  static const String sortApplied = 'sort_applied';

  // События экспорта/импорта
  static const String dataExported = 'data_exported';
  static const String dataImported = 'data_imported';
  static const String backupCreated = 'backup_created';
  static const String backupRestored = 'backup_restored';

  // События настроек
  static const String settingsChanged = 'settings_changed';
  static const String themeChanged = 'theme_changed';
  static const String languageChanged = 'language_changed';

  // События синхронизации
  static const String syncStarted = 'sync_started';
  static const String syncCompleted = 'sync_completed';
  static const String syncFailed = 'sync_failed';
  static const String offlineModeEnabled = 'offline_mode_enabled';
  static const String onlineModeEnabled = 'online_mode_enabled';

  // События ошибок
  static const String errorOccurred = 'error_occurred';
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';

  // События производительности
  static const String appStartup = 'app_startup';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
  static const String memoryWarning = 'memory_warning';

  // События пользовательского взаимодействия
  static const String buttonClicked = 'button_clicked';
  static const String menuOpened = 'menu_opened';
  static const String dialogOpened = 'dialog_opened';
  static const String dialogClosed = 'dialog_closed';
  static const String longPress = 'long_press';
  static const String swipeGesture = 'swipe_gesture';

  // События TTS (Text-to-Speech)
  static const String ttsStarted = 'tts_started';
  static const String ttsStopped = 'tts_stopped';
  static const String ttsPaused = 'tts_paused';
  static const String ttsResumed = 'tts_resumed';
  static const String ttsError = 'tts_error';

  // События режима выступления
  static const String presentationModeStarted = 'presentation_mode_started';
  static const String presentationModeExited = 'presentation_mode_exited';
  static const String presentationPhrasePlayed = 'presentation_phrase_played';
  static const String presentationPhraseSkipped = 'presentation_phrase_skipped';
  static const String presentationNavigation = 'presentation_navigation';
  static const String presentationKeyboardShortcut = 'presentation_keyboard_shortcut';

  // События уведомлений
  static const String notificationReceived = 'notification_received';
  static const String notificationClicked = 'notification_clicked';
  static const String notificationDismissed = 'notification_dismissed';

  // События аналитики
  static const String analyticsEnabled = 'analytics_enabled';
  static const String analyticsDisabled = 'analytics_disabled';
  static const String analyticsSyncCompleted = 'analytics_sync_completed';
  static const String analyticsSyncFailed = 'analytics_sync_failed';
}
