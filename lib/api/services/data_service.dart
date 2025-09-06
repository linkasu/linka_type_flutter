import '../models/category.dart';
import '../models/statement.dart';
import '../models/data_models.dart';
import 'api_client.dart';

class DataService {
  final ApiClient _apiClient = ApiClient();

  // Statements
  Future<List<Statement>> getStatements() async {
    try {
      final response = await _apiClient.get('/statements');
      final List<dynamic> statementsJson = response['statements'] ?? [];
      final statements =
          statementsJson.map((json) => Statement.fromJson(json)).toList();
      return statements;
    } catch (e) {
      rethrow;
    }
  }

  Future<Statement> getStatement(String id) async {
    try {
      final response = await _apiClient.get('/statements/$id');
      return Statement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Statement> createStatement(String title, String categoryId) async {
    try {
      final request = CreateStatementRequest(
        title: title,
        categoryId: categoryId,
      );
      final response = await _apiClient.post(
        '/statements',
        body: request.toJson(),
      );
      return Statement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Statement> updateStatement(
    String id,
    String title,
    String categoryId,
  ) async {
    try {
      final request = UpdateStatementRequest(
        title: title,
        categoryId: categoryId,
      );
      final response = await _apiClient.put(
        '/statements/$id',
        body: request.toJson(),
      );
      return Statement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStatement(String id) async {
    try {
      await _apiClient.delete('/statements/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final List<dynamic> categoriesJson = response['categories'] ?? [];
      final categories =
          categoriesJson.map((json) => Category.fromJson(json)).toList();
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> getCategory(String id) async {
    try {
      final response = await _apiClient.get('/categories/$id');
      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> createCategory(String title) async {
    try {
      final request = CreateCategoryRequest(title: title);
      final response = await _apiClient.post(
        '/categories',
        body: request.toJson(),
      );
      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> updateCategory(String id, String title) async {
    try {
      final request = UpdateCategoryRequest(title: title);
      final response = await _apiClient.put(
        '/categories/$id',
        body: request.toJson(),
      );
      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } catch (e) {
      rethrow;
    }
  }
}
