/// Validation on tarea's format, returns true if the data is valid, false otherwise.
bool isValidTask(Map<String, dynamic>? taskData) {
  if (taskData == null) {
    return false;
  }
  final idType = taskData['id'] != null && taskData['id'] is int;
  final tituloType =
      taskData['titulo'] != null && taskData['titulo'] is String;
  final resumenType =
      taskData['resumen'] != null && taskData['resumen'] is String;
  final descripcionType =
      taskData['descripcion'] != null && taskData['descripcion'] is String;
  final estadosType =
      taskData['estados'] != null && taskData['estados'] is List;
  final fechaFinalizadaType = taskData['fechaFinalizada'] == null ||
      taskData['fechaFinalizada'] is String;
  final asignacionType =
      taskData['asignacion'] != null && taskData['asignacion'] is Map;
  final etiquetasType =
      taskData['etiquetas'] != null && taskData['etiquetas'] is Map;
  final creadorType =
      taskData['creador'] != null && taskData['creador'] is String;
  final tiemposType =
      taskData['tiempos'] != null && taskData['tiempos'] is Map;
  return idType &&
      tituloType &&
      resumenType &&
      descripcionType &&
      estadosType &&
      fechaFinalizadaType &&
      asignacionType &&
      etiquetasType &&
      creadorType &&
      tiemposType;
}
