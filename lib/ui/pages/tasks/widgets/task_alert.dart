import 'package:frontend/domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:frontend/globals.dart';

class TaskAlert extends StatelessWidget {
  final Task task;
  final double screenWidth;
  final double screenHeight;
  final String formattedTime;
  final Color tileTextColor;
  const TaskAlert(
      {super.key,
      required this.task,
      required this.screenWidth,
      required this.screenHeight,
      required this.formattedTime,
      required this.tileTextColor});

  @override
  Widget build(BuildContext context) {
    List<Color> colorOption = [
      Colors.transparent,
      alertColorGray,
      alertColorYellow,
      alertColorRed
    ];
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(
        backgroundColor: colorOption[task.getAlarmState()],
        radius: 8,
      ),
      const SizedBox(width: 3.0),
      SizedBox(
        width: screenWidth * 0.16,
        child: Text(formattedTime,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: tileTextColor,
                fontSize: screenWidth * 0.036,
                fontFamily: 'OpenSans')),
      ),
    ]);
  }
}
