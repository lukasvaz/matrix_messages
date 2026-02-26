import 'package:matrix_messages/ui/screens/tasks/task_detail/task_detail.dart';
import 'package:matrix_messages/ui/screens/tasks/widgets/task_label.dart';
import 'package:matrix_messages/ui/screens/tasks/widgets/task_state.dart';
import 'package:matrix_messages/ui/screens/tasks/widgets/task_alert.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:matrix_messages/utils/utils.dart';
import 'package:matrix_messages/globals.dart';
import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.context,
    required this.task,
  });

  final BuildContext context;
  final Task task;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final tileTitle = task.titulo;
    final tileState = task.getCurrentState();
    final taskLabels = task.getTags();
    final taskPriority = taskLabels['priority'];
    final isFinished = tileState == 'Completada' || tileState == 'Suspendida';
    final tileEndDate = isFinished ? task.getLastUpdate() : null;

    num remainingTagsCount = taskLabels['extraTags'].length;
    Duration tileLastDifference = task.getDelayDuration();

    Color tileTextColor =
        isFinished ? completedTextColor : taskTextColor;

    String? formattedTime = tileLastDifference.inHours >= 24
        ? '${(tileLastDifference.inHours / 24).round()}d'
        : tileLastDifference.inHours >= 1
            ? '${tileLastDifference.inHours}h ${tileLastDifference.inMinutes.remainder(60)}m'
            : '${tileLastDifference.inMinutes.remainder(60)}m';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetail(task: task),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0.0,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.006),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.036, vertical: screenHeight * 0.005),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tileTitle.length > 20 ? '${tileTitle.substring(0, 19)}...' : tileTitle,
                          style: TextStyle(
                            color: tileTextColor,
                            fontWeight: FontWeight.w900,
                            fontSize: screenWidth * 0.05,
                            fontFamily: 'Lato',
                          ),
                        ),
                        if (task.isGroupTask())
                          Container(
                            width: screenWidth * 0.054,
                            height: screenWidth * 0.054,
                            margin: const EdgeInsets.only(top: 3.0),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: backgroundColor,
                            ),
                            child: Icon(
                              Icons.groups_rounded,
                              color: taskTextColor,
                              size: screenWidth * 0.042,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 1.0),
                    Row(
                      children: [
                        TaskState(
                          tileState: tileState,
                          iconSize: screenWidth * 0.052,
                          tileTextColor: tileTextColor,
                          fontSize: screenWidth * 0.031,
                        ), // State icon
                        if (isFinished) ...[
                          const SizedBox(width: 8.0),
                          Text(
                            taskDateFormat(tileEndDate!),
                            style: TextStyle(
                              color: tileTextColor,
                              fontSize: screenWidth * 0.026,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'OpenSans',
                            ),
                          )
                        ] else ...[
                          const SizedBox(width: 4.0),
                          TaskLabel(
                              label: taskPriority,
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.015),
                              fontSize:
                                  screenWidth * 0.031), // Chip de prioridad
                          const SizedBox(width: 4.0),
                          if (remainingTagsCount > 0)
                            TaskLabel(
                                label: '+$remainingTagsCount',
                                backgroundColor: backgroundColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                fontSize: screenWidth *
                                    0.031), // Chip de etiquetas restantes
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isFinished
                      ? const SizedBox(width: 0)
                      : TaskAlert(
                          task: task,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          formattedTime: formattedTime,
                          tileTextColor: tileTextColor),
                  SizedBox(
                      width: screenWidth * 0.05,
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: screenWidth * 0.06,
                          color: isFinished
                              ? completedTextColor
                              : const Color(0xFFA6A6A6))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}