# GitHub Actions Workflows

Этот репозиторий содержит GitHub Actions workflows для автоматической сборки и тестирования приложения LINKa Type.

## Workflows

### 1. Test Windows Build (`test-windows-build.yml`)

**Триггеры:**
- Pull Request в ветку `main`
- Push в ветку `main`

**Функции:**
- Проверка кода (анализ, форматирование, тесты)
- Сборка Windows приложения
- Проверка корректности сборки

### 2. Windows Installer Build (`windows-installer.yml`)

**Триггеры:**
- Создание релиза (release)
- Ручной запуск (workflow_dispatch)

**Функции:**
- Сборка Windows приложения
- Создание MSI инсталлятора с помощью WiX Toolset
- Автоматическая загрузка инсталлятора в релиз
- Создание ярлыков на рабочем столе и в меню Пуск

## Структура инсталлятора

MSI инсталлятор включает:
- Основное приложение (`linka_type_flutter.exe`)
- Flutter Engine (`flutter_windows.dll`)
- Flutter Assets (`flutter_assets/`)
- ICU Data (`icudtl.dat`)
- AOT Library (`app.so`)
- Native Assets
- Plugin Libraries (audioplayers, connectivity, flutter_tts, etc.)
- Ярлыки на рабочем столе и в меню Пуск

## Использование

### Создание релиза

1. Создайте новый релиз в GitHub
2. Workflow автоматически запустится и создаст MSI инсталлятор
3. Инсталлятор будет автоматически загружен в релиз

### Ручной запуск

1. Перейдите в раздел Actions
2. Выберите "Windows Installer Build"
3. Нажмите "Run workflow"

## Требования

- Flutter 3.24.0
- WiX Toolset 3.11.2
- Windows runner (windows-latest)

## Файлы

- `.github/workflows/windows-installer.yml` - Основной workflow для создания инсталлятора
- `.github/workflows/test-windows-build.yml` - Workflow для тестирования сборки
- `installer/Product.wxs` - WiX source файл для создания MSI инсталлятора
