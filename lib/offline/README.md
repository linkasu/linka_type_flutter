# Оффлайн система доступа к данным

Система обеспечивает прозрачную работу приложения в оффлайн режиме с автоматической синхронизацией при восстановлении подключения.

## Основные компоненты

### 1. Модели данных
- `OfflineData` - контейнер для хранения всех данных
- `OfflineOperation` - модель для отложенных операций
- `SyncState` - состояние синхронизации

### 2. Сервисы
- `JsonStorageService` - сохранение/загрузка данных в JSON формате
- `OfflineOperationService` - управление очередью оффлайн операций
- `SyncService` - интеллектуальная синхронизация данных
- `OfflineManager` - основной менеджер оффлайн функциональности

### 3. Провайдеры
- `SyncProvider` - управление состоянием синхронизации в UI

### 4. Виджеты
- `SyncStatusWidget` - компактный индикатор статуса синхронизации
- `SyncStatusBanner` - подробная панель статуса синхронизации
- `OfflineDemoWidget` - демонстрационный виджет

## Использование

### Инициализация

```dart
import 'package:linka_type_flutter/services/data_manager.dart';
import 'package:linka_type_flutter/api/services/data_service.dart';

void main() async {
  final dataService = DataService();
  final dataManager = await DataManager.create(dataService);

  runApp(MyApp(dataManager: dataManager));
}
```

### В виджетах

```dart
import 'package:provider/provider.dart';
import 'package:linka_type_flutter/offline/offline.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Column(
          children: [
            // Индикатор статуса
            SyncStatusWidget(syncState: syncProvider.syncState),

            // Основной контент
            // ...
          ],
        );
      },
    );
  }
}
```

### Работа с данными

```dart
// Получение менеджера данных
final dataManager = context.read<DataManager>();

// CRUD операции (работают как онлайн, так и оффлайн)
final categories = await dataManager.getCategories();
final statements = await dataManager.getStatements();

final newCategory = await dataManager.createCategory('Новая категория');
final newStatement = await dataManager.createStatement('Текст', categoryId);

// Операции автоматически добавляются в очередь при отсутствии интернета
// и синхронизируются при восстановлении подключения
```

## Функциональность

### Оффлайн режим
- ✅ Автоматическое переключение в оффлайн режим при потере связи
- ✅ Сохранение CRUD операций в очередь
- ✅ Локальное обновление данных для немедленной обратной связи
- ✅ Fallback на оффлайн данные при ошибках сети

### Синхронизация
- ✅ Интеллектуальная синхронизация по updatedAt полям
- ✅ Инкрементальная синхронизация для оптимизации трафика
- ✅ Автоматическая повторная синхронизация при восстановлении связи
- ✅ Обработка конфликтов и ошибок синхронизации

### UI интеграция
- ✅ Stream-based обновления состояния синхронизации
- ✅ Визуальные индикаторы статуса
- ✅ Возможность принудительной синхронизации
- ✅ Отображение количества ожидающих операций

## Архитектура

```
DataManager (единый интерфейс)
├── DataService (онлайн API)
├── OfflineManager (оффлайн менеджер)
│   ├── JsonStorageService (хранение данных)
│   ├── OfflineOperationService (очередь операций)
│   ├── SyncService (синхронизация)
│   └── Connectivity monitoring
└── SyncProvider (UI состояние)
```

## Особенности реализации

1. **Прозрачность**: API остается неизменным для существующего кода
2. **Автоматичность**: Переключение режимов происходит автоматически
3. **Оптимизация**: Интеллектуальная синхронизация минимизирует трафик
4. **Надежность**: Graceful degradation при проблемах с сетью
5. **Уведомления**: Пользователь всегда знает о состоянии синхронизации

## Тестирование

Для тестирования оффлайн режима:
1. Запустите приложение с интернетом
2. Создайте несколько категорий и фраз
3. Отключите интернет
4. Продолжите создавать/редактировать данные
5. Включите интернет обратно
6. Наблюдайте автоматическую синхронизацию

## Производительность

- JSON storage для быстрого доступа к данным
- Инкрементальная синхронизация для экономии трафика
- Ленивая загрузка и кэширование
- Минимальные накладные расходы на UI обновления
