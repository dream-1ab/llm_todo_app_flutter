import 'package:flutter/cupertino.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'chat_dialog.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> {
  Offset _position = Offset.zero; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _position = const Offset(20, 200); // Position in top left with some padding
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: _buildButton(),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _position = details.offset;
          });
        },
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: () {
        showCupertinoDialog(
          context: context,
          builder: (context) => const ChatDialog(),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: context.watch<AppState>().theme.accentColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.chat_bubble_fill,
          color: CupertinoColors.white,
          size: 30,
        ),
      ),
    );
  }
}
