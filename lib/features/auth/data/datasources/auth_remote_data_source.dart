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
    print('AuthRemoteDataSourceImpl: Starting login for email: $email');
    try {
      final response = await apiClient.post(
        '/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);
      print('AuthRemoteDataSourceImpl: Decoded response JSON: $data');
      
      final userJson = data['user'] ?? data;
      final String token = (data['token'] ?? data['access_token'] ?? '').toString();
      
      print('AuthRemoteDataSourceImpl: Token extracted: "$token"');
      
      final user = UserModel.fromJson(userJson);
      print('AuthRemoteDataSourceImpl: UserModel successfully instantiated. User: ${user.name}');
      return (user, token);
    } catch (e) {
      print('AuthRemoteDataSourceImpl: Error occurred during login process: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/logout');
  }
}
