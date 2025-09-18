# GitHub Release Checker

Модуль для проверки новых релизов на GitHub и предложения обновлений пользователю.

## Функциональность

- Автоматическая проверка новых релизов через GitHub API
- Сравнение версий с текущей версией приложения
- Диалог с предложением обновления
- Возможность пропустить версию
- Открытие релиза в браузере
- Настройка интервала проверки (по умолчанию 24 часа)

## Структура

```
lib/services/github_release/
├── models/
│   └── github_release.dart          # Модели данных для релизов
├── widgets/
│   └── update_dialog.dart           # UI компоненты для диалогов
├── github_release_service.dart      # Сервис для работы с GitHub API
├── github_release_manager.dart      # Основной менеджер модуля
├── github_release.dart             # Экспорт всех компонентов
└── README.md                       # Документация
```

## Использование

### Автоматическая проверка при запуске

```dart
class _HomeScreenState extends State<HomeScreen> with UpdateCheckerMixin {
  // Автоматическая проверка обновлений через 2 секунды после инициализации
}
```

### Ручная проверка обновлений

```dart
final releaseManager = await GitHubReleaseManager.create();
await releaseManager.forceCheckForUpdates(context);
```

### Добавление кнопки в настройки

```dart
Widget build(BuildContext context) {
  return ListView(
    children: [
      if (_releaseManager != null)
        _releaseManager!.createUpdateCheckWidget(),
    ],
  );
}
```

## Настройка

По умолчанию модуль настроен для репозитория `aacidov/linka_type_flutter`. 
Для изменения репозитория:

```dart
final releaseManager = await GitHubReleaseManager.create(
  owner: 'your_username',
  repo: 'your_repo_name',
);
```

## Зависимости

- `http` - для HTTP запросов к GitHub API
- `shared_preferences` - для сохранения настроек
- `url_launcher` - для открытия ссылок в браузере
- `package_info_plus` - для получения информации о версии приложения
- `json_annotation` - для сериализации JSON

## API GitHub

Модуль использует публичный GitHub API без аутентификации:
- `GET /repos/{owner}/{repo}/releases` - получение списка релизов
- Лимит: 60 запросов в час для неаутентифицированных запросов

## Тестирование

Запуск тестов:
```bash
flutter test test/github_release_test.dart
```
