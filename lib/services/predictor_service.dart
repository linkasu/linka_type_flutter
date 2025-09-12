import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictorService {
  static const String _apiKey =
      'pdct.1.1.20171001T082116Z.f25e2b63fec6bfda.539464c0551ea8f6790d15ce6e78977d247d0804';
  static const String _baseUrl =
      'https://predictor.yandex.net/api/v1/predict.json/complete';

  static Future<PredictorResponse?> getPredictions(String query) async {
    if (query.trim().isEmpty) return null;

    try {
      final uri = Uri.parse(
          '$_baseUrl?key=$_apiKey&q=${Uri.encodeComponent(query)}&lang=ru&limit=5');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictorResponse.fromJson(data);
      }
    } catch (e) {
      // Игнорируем ошибки сети
    }
    return null;
  }
}

class PredictorResponse {
  final int pos;
  final List<String> text;

  PredictorResponse({
    required this.pos,
    required this.text,
  });

  factory PredictorResponse.fromJson(Map<String, dynamic> json) {
    return PredictorResponse(
      pos: json['pos'] ?? 0,
      text: List<String>.from(json['text'] ?? []),
    );
  }
}
