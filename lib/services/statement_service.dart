import '../api/api.dart';
import '../api/models/statement.dart';

class BulkEditResult {
  final bool success;
  final int deletedCount;
  final int addedCount;
  final String? error;

  BulkEditResult({
    required this.success,
    required this.deletedCount,
    required this.addedCount,
    this.error,
  });
}

class BulkEditValidation {
  final bool isValid;
  final String? error;

  BulkEditValidation({
    required this.isValid,
    this.error,
  });
}

class StatementService {
  final DataService _dataService = DataService();

  BulkEditValidation validateBulkEditText(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();

    if (lines.isEmpty) {
      return BulkEditValidation(
        isValid: false,
        error: 'Текст не может быть пустым',
      );
    }

    return BulkEditValidation(isValid: true);
  }

  Future<BulkEditResult> bulkEditStatements(
    List<Statement> statements,
    String newText,
    String categoryId,
  ) async {
    try {
      final lines = newText.split('\n').map((line) => line.trim()).toList();

      // Удаляем все существующие фразы в категории
      for (final statement in statements) {
        await _dataService.deleteStatement(statement.id);
      }

      // Создаем новые фразы из непустых строк
      for (final line in lines) {
        if (line.isNotEmpty) {
          await _dataService.createStatement(line, categoryId);
        }
      }

      final addedCount = lines.where((line) => line.isNotEmpty).length;
      final deletedCount = statements.length;

      return BulkEditResult(
        success: true,
        deletedCount: deletedCount,
        addedCount: addedCount,
      );
    } catch (e) {
      return BulkEditResult(
        success: false,
        deletedCount: 0,
        addedCount: 0,
        error: e.toString(),
      );
    }
  }
}
