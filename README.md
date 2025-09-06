# LINKa Type Flutter

Приложение для набора текста с поддержкой синтеза речи.

## Возможности

- Кроссплатформенное приложение (Linux, Windows, macOS, Android, iOS, Web)
- Синтез речи с поддержкой голосов Яндекса
- Современный интерфейс на Flutter

## Быстрый старт

### Установка зависимостей

```bash
flutter pub get
```

### Запуск приложения

```bash
flutter run
```

### Запуск тестов

```bash
flutter test
```

### Локальная проверка CI

```bash
./scripts/test_ci.sh
```

## CI/CD

Проект настроен с автоматическим CI/CD pipeline:

- **Тесты**: Запускаются при каждом push и pull request
- **Сборка**: Автоматическая сборка под все платформы

## Разработка

### Структура проекта

- `lib/` - исходный код приложения
- `test/` - тесты
- `.github/workflows/` - CI/CD конфигурация
- `scripts/` - вспомогательные скрипты

### Требования

- Flutter 3.35.3+
- Dart 3.5.0+

### Полезные команды

```bash
# Анализ кода
flutter analyze

# Форматирование
flutter format .

# Сборка для конкретной платформы
flutter build linux --release
flutter build windows --release
flutter build macos --release
flutter build apk --release
flutter build web --release
```
