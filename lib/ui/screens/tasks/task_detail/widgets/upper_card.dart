import 'package:matrix_messages/ui/screens/tasks/widgets/task_alert.dart';
import 'package:matrix_messages/ui/screens/tasks/widgets/task_state.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:matrix_messages/utils/utils.dart';
import 'package:flutter/material.dart';

class UpperCard extends StatelessWidget {
  const UpperCard(
      {super.key,
      required this.task,
      required this.screenWidth,
      required this.screenHeight});

  final Task task;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    final tileTitle = task.titulo;
    final tileState = task.getCurrentState();
    final isFinished = tileState == 'Completada' || tileState == 'Suspendida';
    final tileEndDate = isFinished ? task.getLastUpdate() : null;

    Duration tileLastDifference = task.getDelayDuration();
    String? formattedTime = tileLastDifference.inHours >= 24
        ? '${(tileLastDifference.inHours / 24).round()}d'
        : tileLastDifference.inHours >= 1
            ? '${tileLastDifference.inHours}h ${tileLastDifference.inMinutes.remainder(60)}m'
            : '${tileLastDifference.inMinutes.remainder(60)}m';

    Color tileTextColor = const Color(0xFF1A1A1A);

    return Card(
        color: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6.0),
                topRight: Radius.circular(6.0),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0))),
        child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                top: screenHeight * 0.016,
                right: screenWidth * 0.06,
                bottom: screenHeight * 0.03),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // title
              Text(tileTitle,
                  style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                      color: const Color(0xFF1A1A1A))),
              // Icon Row
              Row(children: [
                TaskState(
                  tileState: tileState,
                  iconSize: screenWidth * 0.052,
                  iconColor: const Color(0xFF666666),
                  tileTextColor: const Color(0xFF1A1A1A),
                  fontSize: screenWidth * 0.031,
                ),
                const SizedBox(width: 10),
                isFinished
                    ? Text(
                        taskDateFormat(tileEndDate!),
                        style: TextStyle(
                          color: tileTextColor,
                          fontSize: screenWidth * 0.026,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'OpenSans',
                        ),
                      )
                    : TaskAlert(
                        task: task,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        formattedTime: formattedTime,
                        tileTextColor: tileTextColor)
              ]),
              const SizedBox(height: 10),
              Text(task.resumen),
            ])));
  }
}
