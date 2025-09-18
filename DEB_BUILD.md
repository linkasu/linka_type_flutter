# Сборка DEB пакетов

Документация по сборке DEB пакетов для Linux дистрибутивов на основе Debian/Ubuntu.

## Автоматическая сборка в CI/CD

### GitHub Actions

DEB пакеты автоматически собираются при:

1. **Создании релиза** - запускается workflow `build-deb.yml`
2. **Ручном запуске** - можно запустить workflow вручную через GitHub Actions

### Файлы workflow:

- `.github/workflows/build-deb.yml` - отдельный workflow для сборки DEB
- `.github/workflows/ci.yml` - добавлен job `build-deb` для CI
- `.github/workflows/release.yml` - добавлен job `build-linux-deb-release` для релизов

## Локальная сборка

### Предварительные требования

1. **Flutter** - установленный и настроенный
2. **fpm** - для создания DEB пакетов:
   ```bash
   sudo apt-get install ruby ruby-dev build-essential
   sudo gem install fpm
   ```
3. **Зависимости Linux**:
   ```bash
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
   ```

### Автоматическая сборка

Используйте готовый скрипт:

```bash
./scripts/build_deb.sh
```

Скрипт автоматически:
- Соберет Flutter приложение
- Создаст структуру DEB пакета
- Создаст исполняемый файл и .desktop файл
- Соберет DEB пакет
- Очистит временные файлы

### Ручная сборка

1. **Соберите приложение**:
   ```bash
   flutter clean
   flutter pub get
   flutter build linux --release
   ```

2. **Создайте структуру пакета**:
   ```bash
   mkdir -p deb-package/usr/share/linka-napishi
   mkdir -p deb-package/usr/share/applications
   mkdir -p deb-package/usr/share/pixmaps
   mkdir -p deb-package/usr/bin
   ```

3. **Скопируйте файлы**:
   ```bash
   cp -r build/linux/x64/release/bundle/* deb-package/usr/share/linka-napishi/
   cp assets/app_icon.png deb-package/usr/share/pixmaps/linka-napishi.png
   ```

4. **Создайте исполняемый файл**:
   ```bash
   cat > deb-package/usr/bin/linka-napishi << 'EOF'
   #!/bin/bash
   cd /usr/share/linka-napishi
   exec ./linka_type_flutter "$@"
   EOF
   chmod +x deb-package/usr/bin/linka-napishi
   ```

5. **Создайте .desktop файл**:
   ```bash
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
   ```

6. **Создайте DEB пакет**:
   ```bash
   fpm -s dir -t deb -n linka-napishi -v 4.0.9 --iteration 1 \
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
   ```

## Установка DEB пакета

```bash
# Установка
sudo dpkg -i linka-napishi_4.0.9-1_amd64.deb

# Исправление зависимостей (если нужно)
sudo apt-get install -f

# Удаление
sudo dpkg -r linka-napishi
```

## Структура DEB пакета

```
deb-package/
├── usr/
│   ├── bin/
│   │   └── linka-napishi          # Исполняемый файл
│   └── share/
│       ├── applications/
│       │   └── linka-napishi.desktop  # Файл приложения
│       ├── linka-napishi/         # Основные файлы приложения
│       │   ├── linka_type_flutter
│       │   ├── data/
│       │   └── lib/
│       └── pixmaps/
│           └── linka-napishi.png  # Иконка приложения
```

## Метаданные пакета

- **Имя**: linka-napishi
- **Версия**: автоматически из pubspec.yaml
- **Архитектура**: amd64
- **Категория**: office
- **Лицензия**: MIT
- **Зависимости**: libgtk-3-0, libstdc++6
- **Поддерживаемые дистрибутивы**: Ubuntu, Debian, Linux Mint и другие

## Проверка пакета

```bash
# Просмотр информации о пакете
dpkg -I linka-napishi_4.0.9-1_amd64.deb

# Просмотр содержимого пакета
dpkg -c linka-napishi_4.0.9-1_amd64.deb

# Проверка зависимостей
apt-cache depends linka-napishi
```

## Troubleshooting

### Ошибки зависимостей

Если при установке возникают ошибки зависимостей:

```bash
sudo apt-get update
sudo apt-get install -f
```

### Проблемы с правами

```bash
# Убедитесь, что исполняемый файл имеет права на выполнение
chmod +x usr/bin/linka-napishi
```

### Проблемы с иконкой

Убедитесь, что иконка находится в правильном формате PNG и размере.
