import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  static OpenAIService? _instance;
  static OpenAIService get instance => _instance ??= OpenAIService._();

  OpenAIService._();

  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  bool get isConfigured {
    final hasKey = (_apiKey != null && _apiKey!.isNotEmpty);
    if (!hasKey) {
      print('OpenAI Service: API Key is MISSING or EMPTY');
    } else {
      // print('OpenAI Service: API Key found (ends with ${_apiKey!.substring(_apiKey!.length - 4)})');
    }
    return hasKey;
  }

  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    String model = 'gpt-4o-mini',
    int maxTokens = 400,
    double temperature = 0.7,
  }) async {
    print('OpenAI Service: generateText called with model $model');

    if (!isConfigured) {
      throw Exception(
          'OpenAI API key not configured. Set OPENAI_API_KEY in .env');
    }

    final uri = Uri.parse(_endpoint);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_apiKey!}',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      print('OpenAI Service: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        if (content is String) {
          print('OpenAI Service: Success, content length: ${content.length}');
          return content.trim();
        }
        if (content is List) {
          final textParts = content
              .whereType<Map>()
              .map((m) => m['text'])
              .whereType<String>()
              .toList();
          if (textParts.isNotEmpty) return textParts.join('\n').trim();
        }
        return content.toString();
      } else {
        print('OpenAI Service: Failed with body: ${response.body}');
        throw Exception(
            'OpenAI error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('OpenAI Service: Exception: $e');
      rethrow;
    }
  }
}
