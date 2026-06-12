import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:intellicart_movil/core/network/api_client.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'assistant_state.dart';

class AssistantCubit extends Cubit<AssistantState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetHistoryUseCase getHistoryUseCase;
  final ApiClient apiClient;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  
  bool _speechEnabled = false;
  String _lastWords = "";

  AssistantCubit({
    required this.sendMessageUseCase,
    required this.getHistoryUseCase,
    required this.apiClient,
  }) : super(AssistantInitial()) {
    _initTts();
    _initSpeech();
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage("es-MX");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        final currentState = state;
        if (currentState is AssistantActiveChat) {
          emit(currentState.copyWith(clearAudioPlaying: true));
        }
      });

      _flutterTts.setErrorHandler((msg) {
        print("AssistantCubit: Local TTS error: $msg");
        final currentState = state;
        if (currentState is AssistantActiveChat) {
          emit(currentState.copyWith(clearAudioPlaying: true));
        }
      });
    } catch (e) {
      print('AssistantCubit: Error al inicializar TTS local: $e');
    }
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) => print('AssistantCubit: SpeechToText error: $val'),
        onStatus: (val) => print('AssistantCubit: SpeechToText status: $val'),
      );
    } catch (e) {
      print('AssistantCubit: Error al inicializar SpeechToText: $e');
    }
  }

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
        
        // Auto-reproducir la respuesta del asistente (remota o local)
        playAudio(responseMessage.id);
      },
    );
  }

  void toggleRecording() async {
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      final isNowRecording = !currentState.isRecording;
      
      if (isNowRecording) {
        if (!_speechEnabled) {
          _speechEnabled = await _speechToText.initialize();
        }
        
        if (_speechEnabled) {
          emit(currentState.copyWith(isRecording: true));
          _lastWords = "";
          try {
            await _speechToText.listen(
              onResult: (result) {
                _lastWords = result.recognizedWords;
                print('AssistantCubit: Transcripción de voz parcial/final: $_lastWords');
              },
              localeId: "es-MX",
            );
          } catch (e) {
            print('AssistantCubit: Error al iniciar escucha SpeechToText: $e');
          }
        } else {
          print('AssistantCubit: Reconocimiento de voz no inicializado o denegado.');
        }
      } else {
        try {
          await _speechToText.stop();
        } catch (e) {}
        
        emit(currentState.copyWith(isRecording: false));
        
        // Esperamos un breve instante para asegurar que capturemos el resultado final
        Future.delayed(const Duration(milliseconds: 400), () {
          final textToSend = _lastWords.trim();
          if (textToSend.isNotEmpty) {
            sendMessage(textToSend);
          } else {
            // Fallback genérico amigable si no se detectó audio
            sendMessage("Recomendame algún café premium o chocolates con descuento");
          }
        });
      }
    }
  }

  void playAudio(String messageId) async {
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      final message = currentState.messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => MessageEntity(id: '', role: MessageRole.user, content: '', suggestedProducts: const []),
      );

      if (message.content.isEmpty) return;

      // Detener cualquier reproducción previa (tanto de audioplayers como de flutter_tts)
      await _audioPlayer.stop();
      await _flutterTts.stop();

      emit(currentState.copyWith(audioPlayingId: messageId));

      // Si hay una URL de audio válida del backend, intentar reproducirla
      if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
        // Construir la URL absoluta usando el host base del ApiClient
        String url = message.audioUrl!;
        if (!url.startsWith('http')) {
          final baseHost = apiClient.baseUrl.replaceFirst('/api', '');
          url = '$baseHost$url';
        }

        print('AssistantCubit: Reproduciendo audio remoto: $url');

        try {
          await _audioPlayer.play(UrlSource(url));
          
          // Escuchar cuando finalice la reproducción remota
          _audioPlayer.onPlayerComplete.first.then((_) {
            final stateAfterPlay = state;
            if (stateAfterPlay is AssistantActiveChat && stateAfterPlay.audioPlayingId == messageId) {
              emit(stateAfterPlay.copyWith(clearAudioPlaying: true));
            }
          });
          return;
        } catch (e) {
          print('AssistantCubit: Falló reproducción remota, usando fallback local TTS: $e');
        }
      }

      // Fallback local: si no hay audioUrl o la reproducción remota falló
      print('AssistantCubit: Reproduciendo voz localmente (TTS Fallback)');
      try {
        await _flutterTts.speak(message.content);
      } catch (e) {
        print('AssistantCubit: Error al hablar localmente: $e');
        emit(currentState.copyWith(clearAudioPlaying: true));
      }
    }
  }

  void stopAudio() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
    final currentState = state;
    if (currentState is AssistantActiveChat) {
      emit(currentState.copyWith(clearAudioPlaying: true));
    }
  }

  @override
  Future<void> close() async {
    await _audioPlayer.dispose();
    await _flutterTts.stop();
    try {
      await _speechToText.stop();
    } catch (e) {}
    return super.close();
  }
}
