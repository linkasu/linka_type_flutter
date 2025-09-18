#!/bin/bash

# Скрипт для сборки DEB пакета локально
# Использование: ./scripts/build_deb.sh

set -e

echo "🔨 Начинаем сборку DEB пакета..."

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден. Установите Flutter и добавьте его в PATH."
    exit 1
fi

# Проверяем наличие fpm
if ! command -v fpm &> /dev/null; then
    echo "📦 Устанавливаем fpm для создания DEB пакетов..."
    sudo apt-get update
    sudo apt-get install -y ruby ruby-dev build-essential
    sudo gem install fpm
fi

# Получаем версию из pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
echo "📋 Версия: $VERSION"

# Собираем Flutter приложение
echo "🏗️ Собираем Flutter приложение..."
flutter clean
flutter pub get
flutter build linux --release

# Создаем структуру для DEB пакета
echo "📁 Создаем структуру DEB пакета..."
mkdir -p deb-package/usr/share/linka-napishi
mkdir -p deb-package/usr/share/applications
mkdir -p deb-package/usr/share/pixmaps
mkdir -p deb-package/usr/bin

# Копируем файлы приложения
echo "📋 Копируем файлы приложения..."
cp -r build/linux/x64/release/bundle/* deb-package/usr/share/linka-napishi/

# Создаем исполняемый файл
echo "🔧 Создаем исполняемый файл..."
cat > deb-package/usr/bin/linka-napishi << 'EOF'
#!/bin/bash
cd /usr/share/linka-napishi
exec ./linka_type_flutter "$@"
EOF
chmod +x deb-package/usr/bin/linka-napishi

# Создаем .desktop файл
echo "🖥️ Создаем .desktop файл..."
cat > deb-package/usr/share/applications/linka-napishi.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=LINKa напиши
Comment=Приложение для набора текста с поддержкой TTS
Exec=linka-napishi
Icon=linka-napishi
Terminal=false
Categories=Office;TextEditor;
Keywords=text;editor;tts;speech;
EOF

# Копируем иконку
echo "🎨 Копируем иконку..."
cp assets/app_icon.png deb-package/usr/share/pixmaps/linka-napishi.png

# Создаем DEB пакет
echo "📦 Создаем DEB пакет..."
fpm -s dir -t deb -n linka-napishi -v $VERSION --iteration 1 \
  --description "LINKa напиши - приложение для набора текста с поддержкой TTS" \
  --maintainer "aacidov <aacidov@example.com>" \
  --url "https://github.com/aacidov/linka_type_flutter" \
  --category office \
  --license "MIT" \
  --vendor "aacidov" \
  --architecture amd64 \
  --depends "libgtk-3-0" \
  --depends "libstdc++6" \
  -C deb-package .

# Очищаем временные файлы
echo "🧹 Очищаем временные файлы..."
rm -rf deb-package

# Показываем результат
echo "✅ DEB пакет создан успешно!"
ls -la linka-napishi_${VERSION}-1_amd64.deb

echo "📋 Для установки пакета выполните:"
echo "   sudo dpkg -i linka-napishi_${VERSION}-1_amd64.deb"
echo ""
echo "📋 Для исправления зависимостей (если нужно):"
echo "   sudo apt-get install -f"
