import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('cached_user', jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = sharedPreferences.getString('cached_user');
    if (jsonString != null) {
      return UserModel.fromJson(jsonDecode(jsonString));
    } else {
      throw const CacheFailure('No hay usuario en caché.');
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString('auth_token', token);
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<void> clearSession() async {
    await sharedPreferences.remove('auth_token');
    await sharedPreferences.remove('cached_user');
  }
}
