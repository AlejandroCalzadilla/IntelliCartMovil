import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      final user = result.$1;
      final token = result.$2;
      
      await localDataSource.cacheToken(token);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error inesperado al iniciar sesión.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Incluso si falla en el servidor, limpiamos localmente la sesión.
    } finally {
      await localDataSource.clearSession();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getCachedToken();
      if (token != null && token.isNotEmpty) {
        return const Right(true);
      }
      return const Right(false);
    } catch (_) {
      return const Right(false);
    }
  }
}
