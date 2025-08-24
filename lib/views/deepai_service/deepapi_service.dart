import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepAIService {
  static const _apiKey = '8c762394-bd7b-4041-a273-a594981cba01'; // Replace with your real key
  static const _endpoint = 'https://api.deepai.org/api/text2img';

  /// Generates an image URL from a given prompt (e.g., bedtime story title)
  static Future<String?> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Api-Key': _apiKey,
        },
        body: {
          'text': prompt,
        },
      );

      print('DeepAI response status: ${response.statusCode}');
      print('DeepAI response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['output_url'] as String?;
      } else {
        print('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      print('Image generation error: $e');
    }
    return null;
  }
}
