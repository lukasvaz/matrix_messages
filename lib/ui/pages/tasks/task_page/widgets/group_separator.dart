import 'package:frontend/ui/pages/tasks/task_page/widgets/task_tile.dart';
import 'package:frontend/domain/entities/task.dart';
import 'package:flutter/material.dart';

class GroupSeparator extends StatefulWidget {
  final String groupName;
  final List<Task> tasksDelGrupo;

  const GroupSeparator({
    super.key,
    required this.groupName,
    required this.tasksDelGrupo,
  });

  @override
  GroupSeparatorState createState() => GroupSeparatorState();
}

class GroupSeparatorState extends State<GroupSeparator> {
  bool isExpanded = false;

  @override
  void didUpdateWidget(covariant GroupSeparator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupName != oldWidget.groupName) {
      setState(() {
        isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            cardTheme: const CardTheme(margin: EdgeInsets.all(0))),
        child: Column(children: [
          ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.064),
              dense: true,
              title: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${widget.groupName} (${widget.tasksDelGrupo.length})',
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A6870),
                        fontSize: screenWidth * 0.048)),
                SizedBox(
                    height: screenWidth * 0.07,
                    child: Transform.translate(
                        offset:
                            Offset(-screenWidth * 0.04, -screenWidth * 0.04),
                        child: Icon(
                            isExpanded
                                ? Icons.arrow_drop_down_rounded
                                : Icons.arrow_right_rounded,
                            size: screenWidth * 0.15,
                            color: const Color(0xFF6A6870))))
              ]),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }),
          AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                  children: widget.tasksDelGrupo
                      .map((task) => TaskTile(context: context, task: task))
                      .toList()),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200))
        ]));
  }
}
