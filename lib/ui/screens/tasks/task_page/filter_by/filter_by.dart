import 'package:matrix_messages/ui/screens/tasks/task_page/filter_by/widgets/subpanel_view.dart';
import 'package:matrix_messages/ui/screens/tasks/task_page/filter_by/widgets/panel_view.dart';
import 'package:matrix_messages/domain/entities/task.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class FilterBy extends StatefulWidget {
  final List<Task>? tasks;
  final List<Task>? searchedTasks;
  final List<Task>? shownTasks;
  final List<String> selectedFilter;
  final List<String> selectedValues;
  final List<String> etiquetas;
  final double screenWidth;
  final double screenHeight;
  final Function(List<String>, List<String>) setSelectedFilter;
  final void Function(Client) updateTasksByFilter;

  const FilterBy({
    super.key,
    required this.tasks,
    required this.searchedTasks,
    required this.shownTasks,
    required this.selectedFilter,
    required this.selectedValues,
    required this.etiquetas,
    required this.screenWidth,
    required this.screenHeight,
    required this.setSelectedFilter,
    required this.updateTasksByFilter,
  });

  @override
  FilterByState createState() => FilterByState();
}

class FilterByState extends State<FilterBy> {
  late List<String> localSelectedValues;
  List<String> localSelectedFilter = [];
  Map<String, dynamic> etiquetaValues = {};
  bool showCheckboxes = false;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    localSelectedValues = List.from(widget.selectedValues);
  }

  void updateLabelValues() {
    if (widget.tasks != null) {
      for (String etiqueta in widget.etiquetas) {
        if (etiqueta == 'Estado') {
          etiquetaValues[etiqueta] = widget.tasks!
              .map((task) => task.getCurrentState())
              .toSet()
              .where((estado) => estado.isNotEmpty)
              .toList();
        } else {
          etiquetaValues[etiqueta] = widget.tasks!
              .map((task) {
                final tags = task.etiquetas[etiqueta];
                return (tags != null && tags.isNotEmpty) ? tags.first : null;
              })
              .toSet()
              .where((element) => element != null && element.isNotEmpty)
              .toList();
        }
        etiquetaValues[etiqueta]!.sort((a, b) =>
            a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
      }
    }
  }

  List<Task>? applyNotIndexFilters(
      List<String> selectedFilter, List<Task>? tasks) {
    if (selectedFilter.isEmpty || tasks == null) {
      return tasks;
    }

    return tasks.where((task) {
      List<bool> filterResults = [];

      for (String filter in selectedFilter) {
        if (filter == 'Estado') {
          final taskState =
              task.estados.isNotEmpty ? task.estados.first['estado'] : '';
          filterResults.add(localSelectedValues.contains(taskState));
        } else {
          bool matchesValue = localSelectedValues.any((value) {
            return task.etiquetas[filter]?.contains(value) == true;
          });
          filterResults.add(matchesValue);
        }
      }

      return filterResults.every((result) => result);
    }).toList();
  }

  int subfilterTaskCount(String subFilter, int selectedIndex) {
    if (widget.shownTasks == null) {
      return 0;
    }

    List<String> filterList = List.from(localSelectedFilter);
    if (filterList.contains(widget.etiquetas[selectedIndex])) {
      filterList.remove(widget.etiquetas[selectedIndex]);
    }

    List<Task>? tasksToFilter =
        widget.searchedTasks?.length != widget.tasks?.length
            ? widget.searchedTasks
            : widget.tasks;

    List<Task>? filteredTasks = applyNotIndexFilters(filterList, tasksToFilter);

    return filteredTasks!.where((task) {
      if (widget.etiquetas[selectedIndex] == 'Estado') {
        return task.getCurrentState() == subFilter;
      } else {
        return task.etiquetas[widget.etiquetas[selectedIndex]]
                ?.contains(subFilter) ==
            true;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    Client client = Provider.of<Client>(context, listen: false);
    updateLabelValues();

    return Container(
      width: widget.screenHeight * 0.064,
      height: widget.screenHeight * 0.064,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: widget.selectedFilter.isEmpty
            ? const Color(0xFFE5E5EB)
            : const Color(0xFF727287),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          if (widget.tasks == null) {
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            barrierColor: const Color.fromARGB(128, 0, 0, 0),
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setModalState) {
                return !showCheckboxes
                    ? PanelView(
                        etiquetas: widget.etiquetas,
                        selectedFilter: localSelectedFilter,
                        screenHeight: widget.screenHeight,
                        screenWidth: widget.screenWidth,
                        onTap: (index) {
                          setModalState(() {
                            selectedIndex = index;
                            showCheckboxes = true;
                          });
                        },
                        onClearFilters: () {
                          setModalState(() {
                            widget.selectedFilter.clear();
                            widget.selectedValues.clear();
                            localSelectedFilter.clear();
                            localSelectedValues.clear();
                            widget.updateTasksByFilter(client);
                          });
                        },
                        onApplyFilters: () {
                          widget.setSelectedFilter(
                              localSelectedFilter, localSelectedValues);
                          widget.updateTasksByFilter(client);

                          Navigator.pop(context);
                        },
                      )
                    : SubPanelView(
                        etiquetaValues:
                            etiquetaValues[widget.etiquetas[selectedIndex]],
                        localSelectedValues: localSelectedValues,
                        etiquetas: widget.etiquetas,
                        selectedIndex: selectedIndex,
                        screenHeight: widget.screenHeight,
                        screenWidth: widget.screenWidth,
                        subfilterTaskCount: subfilterTaskCount,
                        onValueChanged: (value) {
                          setModalState(() {
                            if (localSelectedValues.contains(value)) {
                              localSelectedValues.remove(value);
                              for (final filter in widget.etiquetas) {
                                if (etiquetaValues[filter].every((thisValue) =>
                                    !localSelectedValues.contains(thisValue))) {
                                  localSelectedFilter.remove(filter);
                                }
                              }
                            } else {
                              localSelectedValues.add(value);
                              if (!localSelectedFilter
                                  .contains(widget.etiquetas[selectedIndex])) {
                                localSelectedFilter
                                    .add(widget.etiquetas[selectedIndex]);
                              }
                            }
                            if (localSelectedValues.isEmpty) {
                              localSelectedFilter.clear();
                            }
                          });
                        },
                        onBack: () {
                          setModalState(() {
                            showCheckboxes = false;
                          });
                        },
                      );
              });
            },
          ).then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                showCheckboxes = false;
                localSelectedValues = List.from(widget.selectedValues);
                localSelectedFilter = List.from(widget.selectedFilter);
              });
            });
          });
        },
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.filter_list_rounded,
          color: widget.selectedFilter.isEmpty
              ? const Color(0xFF727287)
              : const Color(0xFFF2F2F4),
          size: widget.screenHeight * 0.045,
        ),
        tooltip: 'Filtrar',
      ),
    );
  }
}
