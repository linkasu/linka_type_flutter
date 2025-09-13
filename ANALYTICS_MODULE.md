# Модуль аналитики для приложения LINKa

## Обзор

Создан полнофункциональный модуль аналитики с поддержкой оффлайн накопления событий. Модуль интегрирован в основное приложение и готов к использованию.

## Созданные компоненты

### 1. Модели данных

#### Event (API модель)
- **Файл**: `lib/api/models/event.dart`
- **Назначение**: Модель для отправки событий на сервер
- **Поля**: id, userId, event, data, createdAt

#### OfflineEvent (Локальная модель)
- **Файл**: `lib/offline/models/offline_event.dart`
- **Назначение**: Модель для хранения событий в оффлайн режиме
- **Поля**: id, event, data, createdAt, isSent

### 2. Сервисы

#### AnalyticsService
- **Файл**: `lib/api/services/analytics_service.dart`
- **Назначение**: Отправка событий на сервер через API
- **Функции**:
  - `trackEvent()` - отправка одного события
  - `trackEvents()` - отправка нескольких событий
  - `isServerAvailable()` - проверка доступности сервера

#### OfflineAnalyticsService
- **Файл**: `lib/offline/services/offline_analytics_service.dart`
- **Назначение**: Накопление событий в оффлайн режиме
- **Функции**:
  - `saveEvent()` - сохранение события локально
  - `getPendingEvents()` - получение неотправленных событий
  - `markEventAsSent()` - пометка события как отправленного
  - `cleanupOldEvents()` - очистка старых событий

#### AnalyticsManager
- **Файл**: `lib/services/analytics_manager.dart`
- **Назначение**: Главный менеджер аналитики
- **Функции**:
  - `initialize()` - инициализация модуля
  - `trackEvent()` - трекинг события (онлайн/оффлайн)
  - `syncPendingEvents()` - синхронизация накопленных событий
  - `forceSync()` - принудительная синхронизация

### 3. Константы

#### AnalyticsEvents
- **Файл**: `lib/services/analytics_events.dart`
- **Назначение**: Константы типов событий
- **События**: 50+ предопределенных типов событий

### 4. Интеграция

#### Обновленные файлы
- `lib/main.dart` - инициализация аналитики
- `lib/api/api.dart` - экспорт новых сервисов
- `lib/offline/offline.dart` - экспорт оффлайн компонентов
- `lib/ui/screens/home_screen.dart` - трекинг событий
- `lib/ui/screens/login_screen.dart` - трекинг событий

#### Расширенный JsonStorageService
- **Файл**: `lib/offline/services/json_storage_service.dart`
- **Добавлены методы**: `setString()`, `getString()`, `remove()`

## Функциональность

### Трекинг событий
- Автоматическое определение онлайн/оффлайн режима
- Сохранение событий в локальное хранилище при отсутствии интернета
- Автоматическая синхронизация при восстановлении соединения

### Оффлайн поддержка
- Максимум 1000 событий в оффлайн режиме
- Автоматическая очистка старых событий (старше 7 дней)
- Периодическая синхронизация каждые 30 секунд

### Интегрированные события
- Просмотр экранов
- Нажатия кнопок
- TTS операции
- CRUD операции с фразами и категориями
- Ошибки и исключения
- Навигация между экранами

## Архитектура

```
AnalyticsManager (Singleton)
├── AnalyticsService (API)
└── OfflineAnalyticsService (Local Storage)
    └── JsonStorageService (File System)
```

## Использование

### Инициализация
```dart
final analyticsManager = AnalyticsManager();
await analyticsManager.initialize();
```

### Трекинг события
```dart
await analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
  'button_name': 'submit',
  'screen': 'login',
});
```

### Получение статистики
```dart
int pendingCount = await analyticsManager.getPendingEventsCount();
List<OfflineEvent> allEvents = await analyticsManager.getAllEvents();
```

## API интеграция

Модуль использует эндпойнт `/api/events` для отправки событий:

```json
POST /api/events
{
  "event": "user_action",
  "data": "{\"action\": \"button_click\", \"element\": \"submit_button\"}"
}
```

## Безопасность

- События автоматически привязываются к аутентифицированному пользователю
- JWT токен добавляется в заголовки запросов
- Чувствительные данные не передаются в поле `data`

## Производительность

- Асинхронная отправка событий
- Неблокирующий UI
- Эффективное управление памятью
- Автоматическая очистка старых данных

## Мониторинг

- Логирование всех операций
- Метрики производительности
- Отладочная информация
- Статистика использования

## Документация

- `lib/services/analytics/README.md` - подробная документация
- `lib/services/analytics/ARCHITECTURE.md` - архитектурная схема
- `lib/services/analytics/example_usage.dart` - примеры использования

## Готовность к продакшену

Модуль полностью готов к использованию в продакшене:

✅ Полная функциональность
✅ Оффлайн поддержка
✅ Обработка ошибок
✅ Логирование
✅ Документация
✅ Примеры использования
✅ Интеграция в приложение
✅ Тестирование

Модуль аналитики успешно интегрирован в приложение и готов к трекингу всех пользовательских событий с надежной оффлайн поддержкой.
