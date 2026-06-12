import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(UserModel, String)> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<(UserModel, String)> login(String email, String password) async {
    final response = await apiClient.post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);
    
    // Mapea la estructura típica de Laravel Sanctum: { "user": {...}, "token": "..." }
    final userJson = data['user'] ?? data;
    final String token = (data['token'] ?? data['access_token'] ?? '').toString();
    
    final user = UserModel.fromJson(userJson);
    return (user, token);
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/logout');
  }
}
