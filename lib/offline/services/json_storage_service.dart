import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/offline_data.dart';
import '../models/offline_operation.dart';
import '../models/sync_state.dart';

/// Сервис для работы с JSON хранилищем оффлайн данных
class JsonStorageService {
  static const String _dataFileName = 'offline_data.json';
  static const String _operationsFileName = 'offline_operations.json';
  static const String _syncStateFileName = 'sync_state.json';

  /// Получает директорию для хранения данных приложения
  Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${directory.path}/offline');

    if (!await offlineDir.exists()) {
      await offlineDir.create(recursive: true);
    }

    return offlineDir;
  }

  /// Сохраняет оффлайн данные
  Future<void> saveOfflineData(OfflineData data) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_dataFileName');

      final jsonString = jsonEncode(data.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('JsonStorageService: Error saving offline data: $e');
      rethrow;
    }
  }

  /// Загружает оффлайн данные
  Future<OfflineData?> loadOfflineData() async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_dataFileName');

      if (!await file.exists()) {
        print('JsonStorageService: Файл оффлайн данных не существует');
        return null;
      }

      final jsonString = await file.readAsString();
      print('JsonStorageService: Загружено ${jsonString.length} символов из файла');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final data = OfflineData.fromJson(jsonData);
      print('JsonStorageService: Загружены оффлайн данные - категорий: ${data.categories.length}, фраз: ${data.statements.length}');
      return data;
    } catch (e) {
      print('JsonStorageService: Error loading offline data: $e');
      return null;
    }
  }

  /// Сохраняет список оффлайн операций
  Future<void> saveOfflineOperations(List<OfflineOperation> operations) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_operationsFileName');

      final jsonList = operations.map((op) => op.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('JsonStorageService: Error saving offline operations: $e');
      rethrow;
    }
  }

  /// Загружает список оффлайн операций
  Future<List<OfflineOperation>> loadOfflineOperations() async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_operationsFileName');

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      final operations = jsonList
          .map(
              (json) => OfflineOperation.fromJson(json as Map<String, dynamic>))
          .toList();

      return operations;
    } catch (e) {
      print('JsonStorageService: Error loading offline operations: $e');
      return [];
    }
  }

  /// Добавляет новую оффлайн операцию
  Future<void> addOfflineOperation(OfflineOperation operation) async {
    final operations = await loadOfflineOperations();
    operations.add(operation);
    await saveOfflineOperations(operations);
  }

  /// Удаляет оффлайн операцию по ID
  Future<void> removeOfflineOperation(String operationId) async {
    final operations = await loadOfflineOperations();
    operations.removeWhere((op) => op.id == operationId);
    await saveOfflineOperations(operations);
  }

  /// Обновляет статус операции
  Future<void> updateOperationStatus({
    required String operationId,
    required bool synced,
    String? error,
  }) async {
    final operations = await loadOfflineOperations();
    final index = operations.indexWhere((op) => op.id == operationId);

    if (index != -1) {
      operations[index] = operations[index].copyWith(
        synced: synced,
        lastSyncAttempt: DateTime.now(),
        lastError: error,
      );
      await saveOfflineOperations(operations);
    }
  }

  /// Сохраняет состояние синхронизации
  Future<void> saveSyncState(SyncState syncState) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_syncStateFileName');

      final jsonString = jsonEncode(syncState.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('JsonStorageService: Error saving sync state: $e');
      rethrow;
    }
  }

  /// Загружает состояние синхронизации
  Future<SyncState?> loadSyncState() async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$_syncStateFileName');

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final syncState = SyncState.fromJson(jsonData);
      return syncState;
    } catch (e) {
      print('JsonStorageService: Error loading sync state: $e');
      return null;
    }
  }

  /// Очищает все оффлайн данные (для сброса или тестирования)
  Future<void> clearAllData() async {
    try {
      final directory = await _getAppDirectory();

      final dataFile = File('${directory.path}/$_dataFileName');
      final operationsFile = File('${directory.path}/$_operationsFileName');
      final syncStateFile = File('${directory.path}/$_syncStateFileName');

      if (await dataFile.exists()) await dataFile.delete();
      if (await operationsFile.exists()) await operationsFile.delete();
      if (await syncStateFile.exists()) await syncStateFile.delete();
    } catch (e) {
      print('JsonStorageService: Error clearing offline data: $e');
      rethrow;
    }
  }

  /// Получает размер хранилища в байтах
  Future<int> getStorageSize() async {
    try {
      final directory = await _getAppDirectory();
      int totalSize = 0;

      final files = [
        File('${directory.path}/$_dataFileName'),
        File('${directory.path}/$_operationsFileName'),
        File('${directory.path}/$_syncStateFileName'),
      ];

      for (final file in files) {
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Проверяет существование файлов оффлайн данных
  Future<bool> hasOfflineData() async {
    try {
      final directory = await _getAppDirectory();
      final dataFile = File('${directory.path}/$_dataFileName');
      return await dataFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Сохраняет строку по ключу
  Future<void> setString(String key, String value) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$key.json');
      await file.writeAsString(value);
    } catch (e) {
      print('JsonStorageService: Error saving string for key $key: $e');
      rethrow;
    }
  }

  /// Получает строку по ключу
  Future<String?> getString(String key) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$key.json');

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsString();
    } catch (e) {
      print('JsonStorageService: Error loading string for key $key: $e');
      return null;
    }
  }

  /// Удаляет данные по ключу
  Future<void> remove(String key) async {
    try {
      final directory = await _getAppDirectory();
      final file = File('${directory.path}/$key.json');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('JsonStorageService: Error removing key $key: $e');
      rethrow;
    }
  }
}
