import 'package:matrix_messages/ui/pages/tasks/task_page/widgets/group_separator.dart';
import 'package:matrix_messages/ui/pages/tasks/task_page/widgets/task_tile.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:flutter/material.dart';

class GroupedListView extends StatelessWidget {
  final List<Task> tasks;
  final String selectedGroup;

  const GroupedListView(
      {super.key, required this.tasks, required this.selectedGroup});

  String? getGroupSeparator(Task task) {
    String? groupSeparator;

    if (selectedGroup == 'No agrupar') {
      groupSeparator = null;
    } else if (selectedGroup == 'Estado') {
      groupSeparator = task.getCurrentState();
    } else {
      final tags = task.getTags();
      if (selectedGroup == 'prioridad' && tags['priority'] != null) {
        groupSeparator = tags['priority'];
      } else if (tags['extraTags'].isNotEmpty) {
        groupSeparator = task.etiquetas[selectedGroup].first;
      } else {
        groupSeparator = 'Sin agrupar';
      }
    }
    return groupSeparator;
  }

  @override
  Widget build(BuildContext context) {
    tasks.sort();

    if (selectedGroup == 'No agrupar') {
      return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskTile(context: context, task: tasks[index]);
          });
    } else {
      final groups = tasks
          .map((task) => getGroupSeparator(task) ?? 'Sin agrupar')
          .toSet()
          .toList();

      groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      groups.sort((a, b) {
        if (a == 'Sin agrupar') return 1;
        if (b == 'Sin agrupar') return -1;
        return 0;
      });

      return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final groupName = groups[index];
            final tasksDelGrupo = tasks
                .where((task) => getGroupSeparator(task) == groupName)
                .toList();

            return GroupSeparator(
                groupName: groupName, tasksDelGrupo: tasksDelGrupo);
          });
    }
  }
}
