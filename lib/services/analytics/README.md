# Модуль аналитики

Модуль аналитики обеспечивает трекинг всех событий пользователя с поддержкой оффлайн накопления.

## Архитектура

### Основные компоненты

1. **AnalyticsManager** - главный менеджер аналитики
2. **AnalyticsService** - сервис для отправки событий на сервер
3. **OfflineAnalyticsService** - сервис для накопления событий в оффлайн режиме
4. **AnalyticsEvents** - константы типов событий

### Модели данных

- **Event** - модель события для API
- **OfflineEvent** - модель события для оффлайн хранения

## Использование

### Инициализация

```dart
final analyticsManager = AnalyticsManager();
await analyticsManager.initialize();
```

### Трекинг событий

```dart
// Простое событие
await analyticsManager.trackEvent('user_action');

// Событие с данными
await analyticsManager.trackEvent('button_clicked', data: {
  'button_name': 'submit',
  'screen': 'login',
});
```

### Типы событий

Все типы событий определены в `AnalyticsEvents`:

- `userLogin` - вход пользователя
- `userLogout` - выход пользователя
- `screenView` - просмотр экрана
- `buttonClicked` - нажатие кнопки
- `statementCreated` - создание фразы
- `categoryCreated` - создание категории
- `ttsStarted` - запуск TTS
- И многие другие...

## Оффлайн поддержка

Модуль автоматически:

1. Сохраняет события в локальное хранилище при отсутствии интернета
2. Синхронизирует накопленные события при восстановлении соединения
3. Ограничивает количество оффлайн событий (максимум 1000)
4. Очищает старые отправленные события (старше 7 дней)

## Настройка

### Периодическая синхронизация

По умолчанию события синхронизируются каждые 30 секунд. Можно изменить в `AnalyticsManager`:

```dart
_syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
  _syncPendingEvents();
});
```

### Максимальное количество оффлайн событий

```dart
static const int _maxOfflineEvents = 1000;
```

### Время хранения старых событий

```dart
await _offlineAnalyticsService.cleanupOldEvents(daysToKeep: 7);
```

## API интеграция

Модуль использует API эндпойнт `/api/events` для отправки событий:

```json
{
  "event": "user_action",
  "data": "{\"action\": \"button_click\", \"element\": \"submit_button\"}"
}
```

## Мониторинг

### Получение статистики

```dart
// Количество неотправленных событий
int pendingCount = await analyticsManager.getPendingEventsCount();

// Все события (включая отправленные)
List<OfflineEvent> allEvents = await analyticsManager.getAllEvents();
```

### Принудительная синхронизация

```dart
await analyticsManager.forceSync();
```

### Очистка данных

```dart
await analyticsManager.clearAllEvents();
```

## Интеграция в экраны

Модуль уже интегрирован в основные экраны:

- **HomeScreen** - трекинг TTS, CRUD операций, навигации
- **LoginScreen** - трекинг входа, ошибок, навигации

Для добавления трекинга в новые экраны:

```dart
class MyScreen extends StatefulWidget {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analyticsManager = context.read<AnalyticsManager>();
  }

  void _someAction() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
      'button_name': 'my_button',
      'screen': 'my_screen',
    });
  }
}
```

## Безопасность

- События автоматически привязываются к аутентифицированному пользователю
- Чувствительные данные не должны передаваться в поле `data`
- Оффлайн события шифруются при сохранении (если настроено)

## Производительность

- События отправляются асинхронно и не блокируют UI
- Оффлайн события сохраняются в фоновом режиме
- Периодическая синхронизация не влияет на производительность
- Автоматическая очистка старых событий предотвращает переполнение хранилища
