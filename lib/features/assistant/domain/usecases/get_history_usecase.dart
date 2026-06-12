import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/assistant_repository.dart';

class GetHistoryUseCase {
  final AssistantRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call() async {
    return await repository.getHistory();
  }
}
