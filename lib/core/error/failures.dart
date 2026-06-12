import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché local.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Credenciales inválidas o sesión expirada.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}
