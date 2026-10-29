import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final String? code;
  final String? message;

  ApiEnvelope({required this.success, this.data, this.code, this.message});
}

/// Thin wrapper over the citizen-facing backend endpoints. Holds the citizen JWT in
/// SharedPreferences (device-local storage) and attaches it to every request.
class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://steys.unye.bel.tr',
  );

  static const _requestTimeout = Duration(seconds: 15);

  static const _tokenKey = 'citizen_access_token';

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> get isLoggedIn async => (await _loadToken()) != null;

  Future<String?> get currentToken async => _loadToken();

  Future<Map<String, String>> _headers() async {
    final token = await _loadToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiEnvelope<T>> get<T>(String path, T Function(dynamic json) parse) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(_requestTimeout);
      return _decode(response, parse);
    } catch (_) {
      return ApiEnvelope<T>(success: false, message: 'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(dynamic json) parse,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
      return _decode(response, parse);
    } catch (_) {
      return ApiEnvelope<T>(success: false, message: 'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    }
  }

  ApiEnvelope<T> _decode<T>(http.Response response, T Function(dynamic json) parse) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      if (!success) {
        final error = body['error'] as Map<String, dynamic>?;
        return ApiEnvelope<T>(
          success: false,
          code: error?['code'] as String?,
          message: error?['message'] as String? ?? 'İşlem gerçekleştirilemedi.',
        );
      }
      return ApiEnvelope<T>(success: true, data: parse(body['data']));
    } catch (_) {
      return ApiEnvelope<T>(success: false, message: 'Sunucuya ulaşılamadı.');
    }
  }
}
