import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Configure your Flask server URL
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.7.36:5000', // Change to your server IP/domain
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  // Send transcript to the API
  static Future<Map<String, dynamic>> sendVoiceQuery(String transcript) async {
    try {
      debugPrint('Sending transcript to API: $transcript');

      // POST the transcript to your endpoint
      final response = await _dio.post(
        '/api/voice', // Your Flask endpoint
        data: {
          'transcript': transcript,
          'timestamp': DateTime.now().toIso8601String(),
          'user_id': 'app_user', // Optional - for tracking
        },
      );

      // Return the response data
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error sending voice query: $e');

      if (e is DioException) {
        debugPrint('Status code: ${e.response?.statusCode}');
        debugPrint('Response data: ${e.response?.data}');
      }

      throw Exception('API error: $e');
    }
  }
}
