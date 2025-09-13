# Архитектура модуля аналитики

## Схема компонентов

```
┌─────────────────────────────────────────────────────────────────┐
│                        AnalyticsManager                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Singleton     │  │  Auto-sync      │  │  Online/Offline │ │
│  │   Pattern       │  │  Timer (30s)    │  │  Detection      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
        ┌───────────▼───┐   ┌───▼───┐   ┌───▼──────────┐
        │AnalyticsService│   │  OR  │   │OfflineAnalytics│
        │                │   │      │   │Service         │
        │ ┌────────────┐ │   │      │   │                │
        │ │API Client  │ │   │      │   │ ┌────────────┐ │
        │ │Integration │ │   │      │   │ │JSON Storage│ │
        │ └────────────┘ │   │      │   │ │Service     │ │
        └────────────────┘   │      │   │ └────────────┘ │
                             │      │   └────────────────┘
                             │      │
                    ┌────────▼───┐  │
                    │   Online   │  │
                    │   Mode     │  │
                    └────────────┘  │
                                    │
                            ┌───────▼───────┐
                            │  Offline Mode │
                            │               │
                            │ ┌───────────┐ │
                            │ │Local      │ │
                            │ │Storage    │ │
                            │ │(1000 max) │ │
                            │ └───────────┘ │
                            └───────────────┘
```

## Поток данных

### 1. Трекинг события

```
User Action → AnalyticsManager.trackEvent()
    ↓
Check Online Status
    ↓
┌─ Online ──→ AnalyticsService.trackEvent() ──→ API Server
│
└─ Offline ─→ OfflineAnalyticsService.saveEvent() ──→ Local Storage
```

### 2. Синхронизация

```
Timer (30s) → AnalyticsManager.syncPendingEvents()
    ↓
OfflineAnalyticsService.getPendingEvents()
    ↓
AnalyticsService.trackEvents() (batch)
    ↓
OfflineAnalyticsService.markEventsAsSent()
```

### 3. Очистка

```
Timer (daily) → OfflineAnalyticsService.cleanupOldEvents()
    ↓
Remove events older than 7 days
    ↓
Keep only unsent events
```

## Модели данных

### Event (API)
```dart
{
  "id": "event_123",
  "userId": "user_456", 
  "event": "button_clicked",
  "data": "{\"button\": \"submit\"}",
  "createdAt": "2024-01-15T10:35:00Z"
}
```

### OfflineEvent (Local)
```dart
{
  "id": "1642248900000",
  "event": "button_clicked", 
  "data": {"button": "submit"},
  "createdAt": "2024-01-15T10:35:00Z",
  "isSent": false
}
```

## Конфигурация

### Настройки по умолчанию

- **Синхронизация**: каждые 30 секунд
- **Максимум оффлайн событий**: 1000
- **Время хранения**: 7 дней
- **API эндпойнт**: `/api/events`

### Переменные окружения

```dart
static const String baseUrl = 'https://type-backend.linka.su/api';
static const int _maxOfflineEvents = 1000;
static const Duration _syncInterval = Duration(seconds: 30);
static const int _daysToKeep = 7;
```

## Обработка ошибок

### Сетевые ошибки
- Автоматическое переключение в оффлайн режим
- Сохранение событий локально
- Повторная попытка при восстановлении соединения

### Ошибки валидации
- Логирование ошибки
- Продолжение работы без прерывания

### Ошибки хранилища
- Fallback на память
- Уведомление пользователя
- Автоматическое восстановление

## Мониторинг и отладка

### Логирование
```dart
developer.log('Событие отправлено: $event');
developer.log('Ошибка при отправке: $e');
developer.log('Синхронизировано: ${sentCount} событий');
```

### Метрики
- Количество неотправленных событий
- Время последней синхронизации
- Статус соединения
- Размер локального хранилища

### Отладка
```dart
// Получить все события
List<OfflineEvent> events = await analyticsManager.getAllEvents();

// Принудительная синхронизация
await analyticsManager.forceSync();

// Очистка данных
await analyticsManager.clearAllEvents();
```
