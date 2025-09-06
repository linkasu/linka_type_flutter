class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://type-backend.linka.su/api';
  static const String wsUrl = 'wss://type-backend.linka.su/api/ws';

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordVerify = '/reset-password/verify';
  static const String resetPasswordConfirm = '/reset-password/confirm';

  static const String statements = '/statements';
  static const String categories = '/categories';
  static const String websocket = '/ws';

  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // WebSocket message types
  static const String categoryCreated = 'category_created';
  static const String categoryUpdated = 'category_updated';
  static const String categoryDeleted = 'category_deleted';
  static const String statementCreated = 'statement_created';
  static const String statementUpdated = 'statement_updated';
  static const String statementDeleted = 'statement_deleted';

  // HTTP status codes
  static const int ok = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;

  // Error messages
  static const String networkError = 'Ошибка сети';
  static const String unauthorizedError = 'Не авторизован';
  static const String serverError = 'Ошибка сервера';
  static const String unknownError = 'Неизвестная ошибка';
}
