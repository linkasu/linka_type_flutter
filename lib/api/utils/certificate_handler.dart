import 'dart:io';
import 'package:http/http.dart' as http;

class CertificateHandler {
  static void initialize() {
    // Настройка для игнорирования ошибок сертификата в development
    // В production следует использовать правильные сертификаты
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // В production это должно быть false и использоваться правильные сертификаты
        // Для development разрешаем самоподписанные сертификаты
        return true;
      };
  }
}
