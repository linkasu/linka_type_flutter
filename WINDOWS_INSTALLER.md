# Windows Installer для LINKa Type

## Обзор

Настроена автоматическая сборка Windows инсталлятора (MSI) при создании релиза в GitHub.

## Файлы

- `.github/workflows/windows-installer.yml` - Основной workflow для создания инсталлятора
- `.github/workflows/test-windows-build.yml` - Workflow для тестирования сборки
- `installer/Product.wxs` - WiX source файл для создания MSI

## Как использовать

### Создание релиза

1. Создайте новый релиз в GitHub
2. Workflow автоматически запустится
3. MSI инсталлятор будет создан и загружен в релиз

### Ручной запуск

1. Перейдите в Actions → Windows Installer Build
2. Нажмите "Run workflow"

## Что включает инсталлятор

- Основное приложение (linka_type_flutter.exe)
- Flutter Engine и все зависимости
- Flutter Assets и ICU Data
- Plugin Libraries (audioplayers, connectivity, flutter_tts, etc.)
- Ярлыки на рабочем столе и в меню Пуск
- Автоматическое удаление при деинсталляции

## Технические детали

- Использует WiX Toolset 3.11.2
- Создает MSI инсталлятор для Windows
- Поддерживает обновления (MajorUpgrade)
- Устанавливается в Program Files
- Создает записи в реестре для отслеживания установки

## Требования

- Windows 10/11
- .NET Framework (обычно уже установлен)
- Права администратора для установки
