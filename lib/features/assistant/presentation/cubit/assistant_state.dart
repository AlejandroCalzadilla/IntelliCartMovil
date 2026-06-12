import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class AssistantState extends Equatable {
  const AssistantState();

  @override
  List<Object?> get props => [];
}

class AssistantInitial extends AssistantState {}

class AssistantLoading extends AssistantState {}

class AssistantHistoryLoaded extends AssistantState {
  final List<MessageEntity> messages;
  const AssistantHistoryLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class AssistantActiveChat extends AssistantState {
  final List<MessageEntity> messages;
  final bool isSending;
  final bool isRecording;
  final String? audioPlayingId;

  const AssistantActiveChat({
    required this.messages,
    this.isSending = false,
    this.isRecording = false,
    this.audioPlayingId,
  });

  AssistantActiveChat copyWith({
    List<MessageEntity>? messages,
    bool? isSending,
    bool? isRecording,
    String? audioPlayingId,
    bool clearAudioPlaying = false,
  }) {
    return AssistantActiveChat(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isRecording: isRecording ?? this.isRecording,
      audioPlayingId: clearAudioPlaying ? null : (audioPlayingId ?? this.audioPlayingId),
    );
  }

  @override
  List<Object?> get props => [messages, isSending, isRecording, audioPlayingId];
}

class AssistantError extends AssistantState {
  final String message;
  const AssistantError(this.message);

  @override
  List<Object?> get props => [message];
}
