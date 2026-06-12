import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.role,
    required super.content,
    super.audioUrl,
    required super.suggestedProducts,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString().toLowerCase() ?? 'user';
    final role = roleStr == 'assistant' ? MessageRole.assistant : MessageRole.user;

    final List suggestedList = json['suggested_products'] ?? json['products'] ?? [];
    final products = suggestedList.map((item) => ProductModel.fromJson(item)).toList();

    return MessageModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      role: role,
      content: json['content'] ?? '',
      audioUrl: json['audio_url'],
      suggestedProducts: products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role == MessageRole.assistant ? 'assistant' : 'user',
      'content': content,
      if (audioUrl != null) 'audio_url': audioUrl,
      'suggested_products': suggestedProducts.map((p) => (p as ProductModel).toJson()).toList(),
    };
  }
}
