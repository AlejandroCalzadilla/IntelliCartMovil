import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/assistant_repository.dart';

class SendMessageUseCase {
  final AssistantRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call(String message) async {
    return await repository.sendMessage(message);
  }
}
