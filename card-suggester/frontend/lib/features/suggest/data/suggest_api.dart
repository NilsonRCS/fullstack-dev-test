import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SuggestApi {
  final String _baseUrl;
  final http.Client _client;

  SuggestApi({http.Client? client})
      : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3132',
        _client = client ?? http.Client();

  /// Envia occasion e relationship ao backend e retorna as sugestões.
  /// Lança [Exception] em caso de erro de rede ou resposta inesperada.
  Future<({List<String> suggestions, bool isFallback})> getSuggestions({
    required String occasion,
    required String relationship,
  }) async {
    final uri = Uri.parse('$_baseUrl/suggest');

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'occasion': occasion,
            'relationship': relationship,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Erro do servidor: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final suggestions = (body['suggestions'] as List).cast<String>();
    final isFallback = body['fallback'] == true;

    return (suggestions: suggestions, isFallback: isFallback);
  }
}
