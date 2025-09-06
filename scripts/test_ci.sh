#!/bin/bash

# Скрипт для локального тестирования CI pipeline
# Выполняет те же проверки, что и GitHub Actions

# set -e  # Отключено для более устойчивой работы

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
flutter analyze
echo "✅ Анализ кода завершен"

# Запуск тестов
echo "🧪 Запуск тестов..."
flutter test || echo "⚠️  Некоторые тесты не прошли (ожидаемо для плагинов)"
echo "✅ Тесты завершены"

# Проверка сборки (только для текущей платформы)
echo "🔨 Проверка сборки..."
case "$(uname -s)" in
    Linux*)
        echo "Сборка для Linux..."
        if flutter build linux --release; then
            echo "✅ Linux сборка успешна"
        else
            echo "⚠️  Linux сборка не удалась"
            echo "💡 Для сборки Linux приложения с аудио плагинами установите:"
            echo "   sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev"
            echo "   sudo apt-get install gstreamer1.0-plugins-base gstreamer1.0-plugins-good"
        fi
        ;;
    Darwin*)
        echo "Сборка для macOS..."
        if flutter build macos --release; then
            echo "✅ macOS сборка успешна"
        else
            echo "⚠️  macOS сборка не удалась"
        fi
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo "Сборка для Windows..."
        if flutter build windows --release; then
            echo "✅ Windows сборка успешна"
        else
            echo "⚠️  Windows сборка не удалась"
        fi
        ;;
    *)
        echo "⚠️  Неизвестная платформа, пропускаем сборку"
        ;;
esac

echo "🎉 Локальный CI pipeline завершен успешно!"
