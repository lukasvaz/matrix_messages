import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:frontend/ui/pages/channels/channel_chat/widgets/mention_text.dart';

class SendMessage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final Function(String) onSend;
  final Room room; 

  const SendMessage({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.onSend,
    required this.room, 
  });

  @override
  SendMessageState createState() => SendMessageState();
}

class SendMessageState extends State<SendMessage> {
  final TextEditingController _sendController = TextEditingController();
  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _sendController.addListener(() {
      _hasText.value = _sendController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _sendController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenProportion = widget.screenHeight / widget.screenWidth;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F4),
        border: Border(top: BorderSide(color: Color(0xffdcdcdc))),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: screenProportion * 5, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: MentionTextField(
              room: widget.room,
              controller: _sendController,
              onMentionSelected: (mentionText) {
                setState(() {
                  _sendController.text += '$mentionText ';
                  _sendController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _sendController.text.length),
                  );
                });
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _hasText,
            builder: (context, hasText, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: hasText
                    ? Container(
                        key: const ValueKey('sendButton'),
                        width: 52,
                        height: 38,
                        padding: const EdgeInsets.only(left: 6),
                        alignment: Alignment.center,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6600),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded),
                            iconSize: 28,
                            color: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(0),
                            onPressed: () {
                              widget.onSend(_sendController.text.trim());
                              _sendController.clear();
                            },
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('emptySpace')),
              );
            },
          ),
        ],
      ),
    );
  }
}
