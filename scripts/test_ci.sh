#!/bin/bash

# Скрипт для локального тестирования CI pipeline
# Выполняет те же проверки, что и GitHub Actions

set -e

echo "🚀 Запуск локального CI pipeline..."

# Проверка Flutter
echo "📱 Проверка Flutter..."
flutter --version

# Получение зависимостей
echo "📦 Получение зависимостей..."
flutter pub get

# Проверка форматирования
echo "🎨 Проверка форматирования..."
if ! dart format --set-exit-if-changed .; then
    echo "❌ Код не отформатирован. Запустите: dart format ."
    exit 1
fi
echo "✅ Форматирование корректно"

# Анализ кода
echo "🔍 Анализ кода..."
if ! flutter analyze; then
    echo "❌ Анализ кода выявил проблемы"
    exit 1
fi
echo "✅ Анализ кода прошел успешно"

# Запуск тестов
echo "🧪 Запуск тестов..."
if ! flutter test; then
    echo "❌ Тесты не прошли"
    exit 1
fi
echo "✅ Все тесты прошли успешно"

# Проверка сборки (только для текущей платформы)
echo "🔨 Проверка сборки..."
case "$(uname -s)" in
    Linux*)
        echo "Сборка для Linux..."
        flutter build linux --release
        echo "✅ Linux сборка успешна"
        ;;
    Darwin*)
        echo "Сборка для macOS..."
        flutter build macos --release
        echo "✅ macOS сборка успешна"
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo "Сборка для Windows..."
        flutter build windows --release
        echo "✅ Windows сборка успешна"
        ;;
    *)
        echo "⚠️  Неизвестная платформа, пропускаем сборку"
        ;;
esac

echo "🎉 Локальный CI pipeline завершен успешно!"
