import 'package:matrix_messages/ui/pages/tasks/task_detail/widgets/button_layout.dart';
import 'package:matrix_messages/ui/pages/tasks/widgets/task_label.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:matrix_messages/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class LowerCard extends StatelessWidget {
  const LowerCard({
    super.key,
    required this.task,
    required this.client,
    required this.screenHeight,
    required this.screenWidth,
  });

  final Task? task;
  final Client client;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final bool isGroupTask = task!.isGroupTask();
    final tags = task!.getTags();
    final taskPriority = tags['priority'];
    final extraTags = tags['extraTags'];

    return Card(
        color: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(6.0),
                bottomRight: Radius.circular(6.0))),
        child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                top: screenHeight * 0.024,
                right: screenWidth * 0.05,
                bottom: screenHeight * 0.016),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Tags Icon
              Row(children: [
                Icon(Icons.local_offer_rounded,
                    color: const Color(0xFF1A1A1A), size: screenWidth * 0.05),
                const SizedBox(width: 10),
                Text('Etiquetas',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'OpenSans',
                        color: const Color(0xFF1A1A1A),
                        fontSize: screenWidth * 0.036))
              ]),
              const SizedBox(height: 10),
              // Tags Container
              Wrap(spacing: 5.0, children: [
                TaskLabel(
                    label: taskPriority,
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    fontSize: screenWidth * 0.031),
                if (isGroupTask)
                  Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF2F2F2),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: const Color(0xFF1A1A1A),
                      size: screenWidth * 0.054,
                    ),
                  ),
                ...extraTags.map<Widget>((value) => TaskLabel(
                    label: value,
                    backgroundColor: const Color(0xFFF2F2F2),
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    fontSize: screenWidth * 0.031)),
              ]),
              const SizedBox(height: 30),
              // Buttons
              ButtonLayout(
                  task: task!,
                  isBlocked: task!.isBlockedTask(globals.endingTaskTime),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight)
            ])));
  }
}
