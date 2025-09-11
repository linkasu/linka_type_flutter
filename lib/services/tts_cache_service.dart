import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class TTSCacheService {
  static TTSCacheService? _instance;
  static TTSCacheService get instance {
    _instance ??= TTSCacheService._();
    return _instance!;
  }

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static const String _cacheEnabledKey = 'tts_cache_enabled';
  static const String _cacheSizeLimitKey = 'tts_cache_size_limit_mb';
  static const String _defaultCacheSizeLimit = '2048'; // 2GB in MB

  TTSCacheService._();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Получить директорию кеша TTS
  Future<Directory> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'tts_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Генерирует MD5 хеш из текста и голоса
  String generateCacheKey(String text, String voice) {
    final key = '$voice:$text';
    final bytes = utf8.encode(key);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Получить путь к файлу в кеше
  Future<String> getCacheFilePath(String cacheKey) async {
    final cacheDir = await getCacheDirectory();
    return path.join(cacheDir.path, '$cacheKey.mp3');
  }

  /// Проверить, существует ли файл в кеше
  Future<bool> isCached(String cacheKey) async {
    final filePath = await getCacheFilePath(cacheKey);
    final file = File(filePath);
    return await file.exists();
  }

  /// Получить файл из кеша
  Future<File?> getCachedFile(String cacheKey) async {
    final filePath = await getCacheFilePath(cacheKey);
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Сохранить файл в кеш
  Future<void> saveToCache(String cacheKey, List<int> bytes) async {
    await _ensureInitialized();

    // Проверяем, включено ли кеширование
    if (!(await getCacheEnabled())) {
      return;
    }

    // Проверяем лимит размера кеша перед сохранением
    await _ensureCacheSizeLimit();

    final filePath = await getCacheFilePath(cacheKey);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  /// Получить размер кеша в байтах
  Future<int> getCacheSize() async {
    final cacheDir = await getCacheDirectory();
    return await _calculateDirectorySize(cacheDir);
  }

  /// Получить размер кеша в мегабайтах
  Future<double> getCacheSizeMB() async {
    final sizeBytes = await getCacheSize();
    return sizeBytes / (1024 * 1024);
  }

  /// Очистить весь кеш
  Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
  }

  /// Очистить старые файлы из кеша (удалить 50% самых старых файлов)
  Future<void> cleanupOldCacheFiles() async {
    final cacheDir = await getCacheDirectory();
    if (!await cacheDir.exists()) return;

    final files = await cacheDir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();

    if (files.isEmpty) return;

    // Сортируем по дате создания (старые сначала)
    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    // Удаляем 50% самых старых файлов
    final filesToDelete = files.take((files.length * 0.5).ceil()).toList();

    for (final file in filesToDelete) {
      try {
        await file.delete();
      } catch (e) {
        // Игнорируем ошибки удаления отдельных файлов
      }
    }
  }

  /// Проверить и обеспечить лимит размера кеша
  Future<void> _ensureCacheSizeLimit() async {
    final currentSizeMB = await getCacheSizeMB();
    final sizeLimitMB = await getCacheSizeLimitMB();

    if (currentSizeMB >= sizeLimitMB) {
      await cleanupOldCacheFiles();
    }
  }

  /// Включено ли кеширование
  Future<bool> getCacheEnabled() async {
    await _ensureInitialized();
    return _prefs.getBool(_cacheEnabledKey) ?? true; // По умолчанию включено
  }

  /// Установить статус кеширования
  Future<void> setCacheEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs.setBool(_cacheEnabledKey, enabled);
  }

  /// Получить лимит размера кеша в МБ
  Future<double> getCacheSizeLimitMB() async {
    await _ensureInitialized();
    final limitStr =
        _prefs.getString(_cacheSizeLimitKey) ?? _defaultCacheSizeLimit;
    return double.tryParse(limitStr) ?? double.parse(_defaultCacheSizeLimit);
  }

  /// Установить лимит размера кеша в МБ
  Future<void> setCacheSizeLimitMB(double limitMB) async {
    await _ensureInitialized();
    await _prefs.setString(_cacheSizeLimitKey, limitMB.toString());
  }

  /// Получить информацию о кеше
  Future<TTSCacheInfo> getCacheInfo() async {
    final enabled = await getCacheEnabled();
    final sizeMB = await getCacheSizeMB();
    final sizeLimitMB = await getCacheSizeLimitMB();
    final cacheDir = await getCacheDirectory();

    int fileCount = 0;
    if (await cacheDir.exists()) {
      fileCount =
          await cacheDir.list().where((entity) => entity is File).length;
    }

    return TTSCacheInfo(
      enabled: enabled,
      sizeMB: sizeMB,
      sizeLimitMB: sizeLimitMB,
      fileCount: fileCount,
    );
  }

  /// Рекурсивно рассчитать размер директории
  Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // Игнорируем ошибки чтения файлов
    }
    return size;
  }
}

/// Информация о состоянии кеша
class TTSCacheInfo {
  final bool enabled;
  final double sizeMB;
  final double sizeLimitMB;
  final int fileCount;

  TTSCacheInfo({
    required this.enabled,
    required this.sizeMB,
    required this.sizeLimitMB,
    required this.fileCount,
  });

  double get usagePercentage {
    if (sizeLimitMB == 0) return 0;
    return (sizeMB / sizeLimitMB) * 100;
  }

  bool get isNearLimit => usagePercentage >= 90;
}
