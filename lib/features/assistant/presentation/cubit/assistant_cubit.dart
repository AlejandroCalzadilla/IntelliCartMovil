import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'assistant_state.dart';

class AssistantCubit extends Cubit<AssistantState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetHistoryUseCase getHistoryUseCase;

  AssistantCubit({
    required this.sendMessageUseCase,
    required this.getHistoryUseCase,
  }) : super(AssistantInitial());

  Future<void> loadChat() async {
    emit(AssistantLoading());
    final result = await getHistoryUseCase();
    result.fold(
      (failure) {
        emit(const AssistantActiveChat(messages: []));
      },
      (messages) {
        emit(AssistantActiveChat(messages: messages));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final currentState = state;
    List<MessageEntity> currentMessages = [];
    if (currentState is AssistantActiveChat) {
      currentMessages = List<MessageEntity>.from(currentState.messages);
    }

    final userMessage = MessageEntity(
      id: 'temp-user-${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: text,
      suggestedProducts: const [],
    );

    currentMessages.add(userMessage);
    emit(AssistantActiveChat(messages: currentMessages, isSending: true));

    final result = await sendMessageUseCase(text);
    result.fold(
      (failure) => emit(AssistantError(failure.message)),
      (responseMessage) {
        final updatedMessages = List<MessageEntity>.from(currentMessages)..add(responseMessage);
        emit(AssistantActiveChat(messages: updatedMessages, isSending: false));
        
        if (responseMessage.audioUrl != null && responseMessage.audioUrl!.isNotEmpty) {
          playAudio(responseMessage.id);
        }
      },
    );
  }

  void toggleRecording() async {
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      final isNowRecording = !currentState.isRecording;
      emit(currentState.copyWith(isRecording: isNowRecording));
      
      if (!isNowRecording) {
        sendMessage("Recomendame algún café premium o chocolates con descuento");
      }
    }
  }

  void playAudio(String messageId) {
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      emit(currentState.copyWith(audioPlayingId: messageId));
      
      Future.delayed(const Duration(seconds: 4), () {
        final stateAfterPlay = state;
        if (stateAfterPlay is AssistantActiveChat && stateAfterPlay.audioPlayingId == messageId) {
          emit(stateAfterPlay.copyWith(clearAudioPlaying: true));
        }
      });
    }
  }

  void stopAudio() {
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      emit(currentState.copyWith(clearAudioPlaying: true));
    }
  }
}
