import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../api/models/local_statement.dart';
import '../api/models/local_category.dart';
import '../api/models/sync_queue_item.dart';

class LocalDatabaseService {
  static const String _databaseName = 'linka_offline.db';
  static const int _databaseVersion = 1;

  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Здесь можно реализовать миграции при обновлении версии БД
    // Пока просто пересоздаем таблицы
    await _dropTables(db);
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    // Таблица фраз
    await db.execute('''
      CREATE TABLE statements (
        id TEXT,
        title TEXT NOT NULL,
        userId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        localId TEXT UNIQUE,
        PRIMARY KEY (id, localId)
      )
    ''');

    // Таблица категорий
    await db.execute('''
      CREATE TABLE categories (
        id TEXT,
        title TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'synced',
        localId TEXT UNIQUE,
        PRIMARY KEY (id, localId)
      )
    ''');

    // Таблица очереди синхронизации
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        data TEXT,
        createdAt INTEGER NOT NULL,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Индексы для оптимизации запросов
    await db
        .execute('CREATE INDEX idx_statements_userId ON statements(userId)');
    await db.execute(
        'CREATE INDEX idx_statements_categoryId ON statements(categoryId)');
    await db.execute(
        'CREATE INDEX idx_statements_syncStatus ON statements(syncStatus)');
    await db
        .execute('CREATE INDEX idx_categories_userId ON categories(userId)');
    await db.execute(
        'CREATE INDEX idx_categories_syncStatus ON categories(syncStatus)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_operation ON sync_queue(operation)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_tableName ON sync_queue(tableName)');
  }

  Future<void> _dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS sync_queue');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS statements');
  }

  // Методы для работы с фразами
  Future<List<LocalStatement>> getStatements(
      {String? categoryId, String? userId}) async {
    final db = await database;
    String whereClause = 'syncStatus != ?';
    List<String> whereArgs = ['deleted'];

    if (categoryId != null) {
      whereClause += ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (userId != null) {
      whereClause += ' AND userId = ?';
      whereArgs.add(userId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'statements',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => LocalStatement.fromJson(map)).toList();
  }

  Future<LocalStatement?> getStatement(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'statements',
      where: 'id = ? OR localId = ?',
      whereArgs: [id, id],
    );

    if (maps.isEmpty) return null;
    return LocalStatement.fromJson(maps.first);
  }

  Future<String> insertStatement(LocalStatement statement) async {
    final db = await database;
    final localId = statement.localId ?? _generateLocalId();

    await db.insert(
      'statements',
      {
        ...statement.toJson(),
        'localId': localId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return localId;
  }

  Future<void> updateStatement(LocalStatement statement) async {
    final db = await database;
    await db.update(
      'statements',
      statement.toJson(),
      where: 'id = ? OR localId = ?',
      whereArgs: [statement.id ?? '', statement.localId ?? ''],
    );
  }

  Future<void> deleteStatement(String id) async {
    final db = await database;
    await db.update(
      'statements',
      {'syncStatus': 'deleted'},
      where: 'id = ? OR localId = ?',
      whereArgs: [id, id],
    );
  }

  // Методы для работы с категориями
  Future<List<LocalCategory>> getCategories({String? userId}) async {
    final db = await database;
    String whereClause = 'syncStatus != ?';
    List<String> whereArgs = ['deleted'];

    if (userId != null) {
      whereClause += ' AND userId = ?';
      whereArgs.add(userId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => LocalCategory.fromJson(map)).toList();
  }

  Future<LocalCategory?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ? OR localId = ?',
      whereArgs: [id, id],
    );

    if (maps.isEmpty) return null;
    return LocalCategory.fromJson(maps.first);
  }

  Future<String> insertCategory(LocalCategory category) async {
    final db = await database;
    final localId = category.localId ?? _generateLocalId();

    await db.insert(
      'categories',
      {
        ...category.toJson(),
        'localId': localId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return localId;
  }

  Future<void> updateCategory(LocalCategory category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toJson(),
      where: 'id = ? OR localId = ?',
      whereArgs: [category.id ?? '', category.localId ?? ''],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.update(
      'categories',
      {'syncStatus': 'deleted'},
      where: 'id = ? OR localId = ?',
      whereArgs: [id, id],
    );
  }

  // Методы для работы с очередью синхронизации
  Future<List<SyncQueueItem>> getSyncQueueItems({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      orderBy: 'createdAt ASC',
      limit: limit,
    );

    return maps.map((map) => SyncQueueItem.fromJson(map)).toList();
  }

  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSyncQueueRetryCount(int id, int retryCount) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {'retryCount': retryCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Вспомогательные методы
  Future<int> getPendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sync_queue
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearOldDeletedRecords({int daysOld = 30}) async {
    final db = await database;
    final cutoffTime =
        DateTime.now().subtract(Duration(days: daysOld)).millisecondsSinceEpoch;

    await db.delete(
      'statements',
      where: 'syncStatus = ? AND updatedAt < ?',
      whereArgs: ['deleted', cutoffTime],
    );

    await db.delete(
      'categories',
      where: 'syncStatus = ? AND updatedAt < ?',
      whereArgs: ['deleted', cutoffTime],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await _dropTables(db);
    await _createTables(db);
  }

  // Очистка только пользовательских данных (без удаления структуры)
  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('statements');
    await db.delete('categories');
    await db.delete('sync_queue');
  }

  String _generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
