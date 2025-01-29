import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomAuthService {
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Supabase URL or Key not found in environment variables');
    }

    final response = await http.post(
      Uri.parse('$supabaseUrl/auth/v1/signup'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'data': {'username': username},
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }
}
