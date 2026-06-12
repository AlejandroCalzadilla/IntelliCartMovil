import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/assistant_cubit.dart';
import '../cubit/assistant_state.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSendPressed() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<AssistantCubit>().sendMessage(text);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Aura'),
      ),
      body: BlocConsumer<AssistantCubit, AssistantState>(
        listener: (context, state) {
          if (state is AssistantActiveChat) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          List<MessageEntity> messages = [];
          bool isSending = false;
          bool isRecording = false;
          String? audioPlayingId;

          if (state is AssistantActiveChat) {
            messages = state.messages;
            isSending = state.isSending;
            isRecording = state.isRecording;
            audioPlayingId = state.audioPlayingId;
          }

          final isAvatarActive = isSending || audioPlayingId != null;

          return Column(
            children: [
              // Avatar animado del encabezado
              _buildAvatarHeader(isAvatarActive, isSending),

              // Lista de mensajes
              Expanded(
                child: messages.isEmpty && !isSending
                    ? _buildWelcomeState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: messages.length + (isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return _buildTypingIndicator();
                          }
                          final message = messages[index];
                          final isPlaying = audioPlayingId == message.id;
                          return _buildChatBubble(message, isPlaying);
                        },
                      ),
              ),

              // Barra de entrada de texto y micrófono
              _buildInputBar(isRecording),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarHeader(bool isActive, bool isThinking) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withAlpha(150),
        border: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final double scale = isActive ? 1.0 + (_pulseController.value * 0.1) : 1.0;
              final double glow = isActive ? _pulseController.value * 8.0 : 0.0;
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isThinking ? AppTheme.primaryColor.withAlpha(150) : AppTheme.secondaryColor.withAlpha(150),
                      blurRadius: glow,
                      spreadRadius: glow / 2,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: scale,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(
                      isThinking ? Icons.hourglass_empty : (isActive ? Icons.volume_up : Icons.face),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aura',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimaryColor),
              ),
              Text(
                isThinking
                    ? 'Pensando respuesta...'
                    : (isActive ? 'Hablando...' : 'En línea (Esperando voz o texto)'),
                style: TextStyle(
                  fontSize: 12,
                  color: isThinking
                      ? AppTheme.primaryColor
                      : (isActive ? AppTheme.secondaryColor : AppTheme.textSecondaryColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 70, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo puedo ayudarte hoy?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(height: 12),
            const Text(
              'Podés preguntarme recomendaciones de productos en descuento, agregar cosas al carrito por voz o pedir ayuda con tu compra.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickActionChip('¿Qué ofertas hay hoy?'),
                _buildQuickActionChip('Recomendame café o chocolates'),
                _buildQuickActionChip('¿Cuánto llevo gastado en el carro?'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: AppTheme.surfaceColor,
      labelStyle: const TextStyle(color: AppTheme.textPrimaryColor, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.transparent),
      ),
      onPressed: () {
        context.read<AssistantCubit>().sendMessage(text);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TypingDot(delay: 0),
              _TypingDot(delay: 200),
              _TypingDot(delay: 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(MessageEntity message, bool isPlaying) {
    final isUser = message.role == MessageRole.user;

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.surfaceColor,
                child: Icon(Icons.face, size: 18, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textPrimaryColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (message.audioUrl != null) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (isPlaying) {
                            context.read<AssistantCubit>().stopAudio();
                          } else {
                            context.read<AssistantCubit>().playAudio(message.id);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                              color: AppTheme.secondaryColor,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPlaying ? 'Detener voz...' : 'Escuchar respuesta',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isUser && message.suggestedProducts.isNotEmpty)
          _buildSuggestedProductsCarousel(message.suggestedProducts),
      ],
    );
  }

  Widget _buildSuggestedProductsCarousel(List<ProductEntity> products) {
    return Container(
      height: 170,
      margin: const EdgeInsets.only(bottom: 16, left: 40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.backgroundColor,
                        child: const Icon(Icons.image_not_supported, size: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<CartCubit>().addProduct(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} agregado al carrito!'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppTheme.secondaryColor,
                                  ),
                                );
                              },
                              child: const Icon(Icons.add_shopping_cart, size: 16, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isRecording) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withAlpha(200),
        border: const Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double glow = isRecording ? _pulseController.value * 12.0 : 0.0;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withAlpha(150),
                        blurRadius: glow,
                        spreadRadius: glow / 3,
                      ),
                    ],
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'voice-btn',
                    backgroundColor: isRecording ? AppTheme.accentColor : AppTheme.primaryColor,
                    child: Icon(isRecording ? Icons.mic : Icons.mic_none, color: Colors.white),
                    onPressed: () {
                      context.read<AssistantCubit>().toggleRecording();
                    },
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Hablá o escribí un mensaje...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _onSendPressed(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.primaryColor),
              onPressed: _onSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.textSecondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
