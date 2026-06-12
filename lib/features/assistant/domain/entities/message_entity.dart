import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product_entity.dart';

enum MessageRole { user, assistant }

class MessageEntity extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final String? audioUrl;
  final List<ProductEntity> suggestedProducts;

  const MessageEntity({
    required this.id,
    required this.role,
    required this.content,
    this.audioUrl,
    required this.suggestedProducts,
  });

  @override
  List<Object?> get props => [id, role, content, audioUrl, suggestedProducts];
}
