import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';

abstract class AssistantRepository {
  Future<Either<Failure, MessageEntity>> sendMessage(String message);
  Future<Either<Failure, List<MessageEntity>>> getHistory();
}
