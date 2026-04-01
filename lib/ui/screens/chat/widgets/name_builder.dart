import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';

class NameBuilder extends StatelessWidget {
  final types.Message message;
  final double screenHeight;
  final double screenWidth;
  final Color Function(String) generateColorFromUserId;

  const NameBuilder({
    super.key,
    required this.message,
    required this.screenHeight,
    required this.screenWidth,
    required this.generateColorFromUserId,
  });

  String formatTimestampToTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(message.author.firstName!,
              style: TextStyle(
                  color: generateColorFromUserId(message.author.id),
                  fontSize: screenHeight / screenWidth * 7,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans')),
          const SizedBox(width: 8),
          Text(formatTimestampToTime(message.createdAt!),
              style: TextStyle(
                  color: const Color.fromARGB(178, 158, 158, 158),
                  fontSize: screenHeight / screenWidth * 6.5,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'OpenSans'))
        ]);
  }
}
