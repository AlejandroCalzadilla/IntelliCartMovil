import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../error/failures.dart';

class ApiClient {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  
  // URL base configurable. 10.0.2.2 apunta al localhost de la máquina desde el emulador de Android.
  String baseUrl = 'http://192.168.1.5:8000/api';

  ApiClient({required this.client, required this.sharedPreferences});

  Future<Map<String, String>> _getHeaders() async {
    final token = sharedPreferences.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('HTTP GET Request -> URL: $url');
    try {
      final headers = await _getHeaders();
      print('HTTP GET Request -> Headers: $headers');
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      print('HTTP GET Response <- Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('HTTP GET Request Failed: $e');
      if (e is Failure) rethrow;
      throw const ServerFailure('Error de conexión con el servidor.');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = '$baseUrl$endpoint';
    print('HTTP POST Request -> URL: $url');
    print('HTTP POST Request -> Body: $body');
    try {
      final headers = await _getHeaders();
      print('HTTP POST Request -> Headers: $headers');
      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      print('HTTP POST Response <- Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('HTTP POST Request Failed: $e');
      if (e is Failure) rethrow;
      throw const ServerFailure('Error de conexión con el servidor.');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('HTTP DELETE Request -> URL: $url');
    try {
      final headers = await _getHeaders();
      print('HTTP DELETE Request -> Headers: $headers');
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      print('HTTP DELETE Response <- Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('HTTP DELETE Request Failed: $e');
      if (e is Failure) rethrow;
      throw const ServerFailure('Error de conexión con el servidor.');
    }
  }

  http.Response _handleResponse(http.Response response) {
    print('HTTP Response Details -> Status: ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      print('HTTP Auth Error -> 401 Unauthorized');
      throw const AuthFailure('Sesión expirada o no autorizado.');
    } else {
      final message = _extractErrorMessage(response);
      print('HTTP Server Error -> Status: ${response.statusCode}, Msg: $message');
      throw ServerFailure(message);
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Error del servidor (${response.statusCode})';
    } catch (_) {
      return 'Error del servidor (${response.statusCode})';
    }
  }
}
