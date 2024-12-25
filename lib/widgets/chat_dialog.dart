import 'package:flutter/cupertino.dart';
import 'package:hello_flutter_llm/services/chat_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ChatDialog extends StatefulWidget {
  const ChatDialog({super.key});

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String _currentStreamMessage = '';

  List<ChatMessage> get _messages {
    final appState = context.read<AppState>();
    return appState.chatService.messageHistory;
  }

  void _handleSubmit() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      final appState = context.read<AppState>();
      
      setState(() {
        _messageController.clear();
        _isLoading = true;
        _currentStreamMessage = '';
      });

      try {
        await for (final chunk in appState.chatService.streamMessage(message)) {
          setState(() {
            _currentStreamMessage += chunk;
          });
        }
      } catch (e) {
        // Error handling
      } finally {
        setState(() {
          _isLoading = false;
          _currentStreamMessage = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = appState.theme;
    final messages = _messages;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width > 700 ? 700 : MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          minWidth: 300,
          maxHeight: 800,
        ),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.cardColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'پاراڭبوت',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'UKIJ',
                        color: theme.textColor,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.xmark, color: theme.textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (_currentStreamMessage.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < messages.length) {
                    return ChatBubble(message: messages[index]);
                  } else {
                    return ChatBubble(
                      message: ChatMessage(
                        content: _currentStreamMessage,
                        role: ChatMessageRole.assistant,
                        isLoading: true,
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.cardColor,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'سوئال يېزىڭ...',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: TextStyle(color: theme.textColor),
                      placeholderStyle: TextStyle(
                        color: theme.textColor.withOpacity(0.5),
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.all(12),
                    child: Icon(CupertinoIcons.arrow_up, color: theme.backgroundColor),
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatMessageRole.user;
    final theme = context.watch<AppState>().theme;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? theme.accentColor : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? theme.backgroundColor : theme.textColor,
                  fontFamily: 'UKIJ',
                ),
              ),
            ),
            if (message.isLoading) ...[
              const SizedBox(width: 8),
              CupertinoActivityIndicator(
                color: theme.textColor,
                radius: 8,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 