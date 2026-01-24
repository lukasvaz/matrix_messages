import 'package:frontend/ui/pages/tasks/task_page/widgets/grouped_list_view.dart';
import 'package:frontend/ui/pages/tasks/task_page/filter_by/filter_by.dart';
import 'package:frontend/ui/pages/tasks/task_page/widgets/search_by.dart';
import 'package:frontend/ui/pages/tasks/task_page/widgets/group_by.dart';
import 'package:frontend/ui/pages/widgets/bottom_nav_bar_widget.dart';
import 'package:frontend/ui/pages/widgets/appbar_with_settings.dart';
import 'package:frontend/services/matrix/matrix_service.dart';
import 'package:frontend/domain/entities/task.dart';
import 'package:provider/provider.dart';
import 'package:frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';


class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  final MatrixService matrixService = MatrixService();
  List<String> etiquetas = ['No agrupar', 'Estado'];
  late List<String> selectedFilter;
  late List<String> selectedValues;
  late String selectedGroup;
  List<Task>? _tasks;
  List<Task>? _filteredTasks;
  List<Task>? _searchedTasks;
  List<Task>? _shownTasks;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedGroup = 'No agrupar';
    selectedFilter = [];
    selectedValues = [];
  }

  void setSelectedGroup(String group) {
    setState(() {
      selectedGroup = group;
    });
  }

  void setSelectedFilter(List<String> filters, List<String> values) {
    setState(() {
      selectedFilter = filters;
      selectedValues = values;
    });
  }

  void updateEtiquetas(List<Task>? tasks) {
    etiquetas = ['No agrupar', 'Estado'];
    if (tasks != null) {
      for (Task task in tasks) {
        for (String etiqueta in task.etiquetas.keys) {
          if (!etiquetas.contains(etiqueta)) {
            etiquetas.add(etiqueta);
          }
        }
      }
    }
    etiquetas = [
      'No agrupar',
      ...etiquetas.where((e) => e != 'No agrupar').toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))
    ];
  }

  bool isRenderTile(Task task, Client client) {
    if (task.isGroupTask() &&
        task.getAssignedUser() != "" &&
        task.getAssignedUser() != client.userID) {
      return false;
    }
    if (task.isBlockedTask(endingTaskTime)) {
      return false;
    }
    return true;
  }

  List<Task>? applyFilters(List<Task>? tasks) {
    if (selectedFilter.isEmpty || tasks == null) {
      return tasks;
    }

    return tasks.where((task) {
      List<bool> filterResults = [];

      for (String filter in selectedFilter) {
        if (filter == 'Estado') {
          final taskState =
              task.estados.isNotEmpty ? task.estados.first['estado'] : '';
          filterResults.add(selectedValues.contains(taskState));
        } else {
          bool matchesValue = selectedValues.any((value) {
            return task.etiquetas[filter]?.contains(value) == true;
          });
          filterResults.add(matchesValue);
        }
      }

      return filterResults.every((result) => result);
    }).toList();
  }

  void updateFiltersByTasks() {
    for (int i = selectedFilter.length - 1; i >= 0; i--) {
      final filter = selectedFilter[i];
      final value = selectedValues[i];

      bool existValueInTasks = _tasks!.any((task) {
        if (filter == 'Estado') {
          return task.getCurrentState() == value;
        } else {
          final etiquetaValor = task.etiquetas[filter];
          return etiquetaValor != null && etiquetaValor.contains(value);
        }
      });

      if (!existValueInTasks) {
        selectedValues.removeAt(i);
        selectedFilter.removeAt(i);
      }
    }
  }

  void updateTasksBySearch() {
    if (_filteredTasks == null) {
      _shownTasks = _filteredTasks;
      return;
    }

    _searchedTasks = _tasks?.where((task) {
      final titleMatches =
          task.titulo.toLowerCase().contains(_searchText.toLowerCase());
      final descriptionMatches =
          task.descripcion.toLowerCase().contains(_searchText.toLowerCase());
      final resumenMatches =
          task.resumen.toLowerCase().contains(_searchText.toLowerCase());
      return titleMatches || descriptionMatches || resumenMatches;
    }).toList();

    _shownTasks = _filteredTasks?.where((task) {
      final titleMatches =
          task.titulo.toLowerCase().contains(_searchText.toLowerCase());
      final descriptionMatches =
          task.descripcion.toLowerCase().contains(_searchText.toLowerCase());
      final resumenMatches =
          task.resumen.toLowerCase().contains(_searchText.toLowerCase());
      return titleMatches || descriptionMatches || resumenMatches;
    }).toList();
  }

  void updateTasksByFilter(Client client) {
    List<Task>? filteredTasks = applyFilters(_tasks);
    setState(() {
      _filteredTasks = filteredTasks;
      updateTasksBySearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBarWithSettings(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          title: 'Mis tareas'),
      body: Column(children: [
        const Divider(color: Color(0xFFE5E5EB), thickness: 2, height: 2),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.008),
            child: Row(children: [
              SearchBy(
                  controller: _searchController,
                  searchText: _searchText,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                      updateTasksBySearch();
                    });
                  }),
              const SizedBox(width: 8.0),
              FilterBy(
                  tasks: _tasks,
                  searchedTasks: _searchedTasks,
                  shownTasks: _shownTasks,
                  selectedFilter: selectedFilter,
                  selectedValues: selectedValues,
                  etiquetas: etiquetas
                      .where((etiqueta) => etiqueta != 'No agrupar')
                      .toList(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  setSelectedFilter: setSelectedFilter,
                  updateTasksByFilter: updateTasksByFilter),
              const SizedBox(width: 8.0),
              GroupBy(
                  selectedGroup: selectedGroup,
                  etiquetas: etiquetas,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  setSelectedGroup: setSelectedGroup)
            ])),
        const Divider(color: Color(0xFFE5E5EB), thickness: 2, height: 2),
        const SizedBox(height: 6.0),
        Expanded(
            child: StreamBuilder(
                stream: client.onSync.stream,
                builder: (context, _) {
                  return FutureBuilder<List<Task>>(
                      future: matrixService.getTasksFromRooms(
                          client, '#Tareas:matrix1.lahuen.health'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          if (_tasks != null) {
                            return GroupedListView(
                                tasks: _shownTasks ?? _tasks!,
                                selectedGroup: selectedGroup);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4F4F69))));
                          }
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text(
                            'Error al cargar las tareas',
                            style: TextStyle(
                              color: Color(0xFF4F4F69),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lato',
                            ),
                            textAlign: TextAlign.center,
                          ));
                        } else if (snapshot.hasData) {
                          final actualTasks = _tasks?.toString();
                          _tasks = snapshot.data
                              ?.where((task) => isRenderTile(task, client))
                              .toList();

                          // When tasks change, update labels, filtered and searched tasks, to show new tasks or states
                          // tasks may change because of new or removed tasks, or because of a task's metadata change
                          if ((_tasks != null &&
                              (actualTasks == null ||
                                  _tasks.toString() != actualTasks))) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                updateEtiquetas(_tasks);
                                updateFiltersByTasks();
                                final filteredTasks = applyFilters(_tasks);
                                _filteredTasks = filteredTasks;
                                updateTasksBySearch();
                              });
                            });
                          }
                          return GroupedListView(
                              tasks: _shownTasks ?? _tasks!,
                              selectedGroup: selectedGroup);
                        } else {
                          return const Center(
                              child: Text(
                            'Sin información de tareas',
                            style: TextStyle(
                              color: Color(0xFF4F4F69),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Lato',
                            ),
                            textAlign: TextAlign.center,
                          ));
                        }
                      });
                }))
      ]),
      bottomNavigationBar: BottomNavBarWidget(
          screenWidth: screenWidth, screenHeight: screenHeight, section: 1),
    );
  }
}
