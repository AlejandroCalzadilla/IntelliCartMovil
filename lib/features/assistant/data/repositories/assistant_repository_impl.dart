import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../models/message_model.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final ApiClient apiClient;

  AssistantRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(String message) async {
    try {
      final response = await apiClient.post(
        '/assistant/message',
        body: {'message': message},
      );
      final data = jsonDecode(response.body);
      final messageModel = MessageModel.fromJson(data);
      return Right(messageModel);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error al enviar el mensaje al asistente.'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getHistory() async {
    try {
      final response = await apiClient.get('/assistant/history');
      final data = jsonDecode(response.body);
      final List list = data is Map ? (data['data'] ?? data['messages'] ?? []) : data;
      return Right(list.map((item) => MessageModel.fromJson(item)).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error al obtener el historial de chat.'));
    }
  }
}
