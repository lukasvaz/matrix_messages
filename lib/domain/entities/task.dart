import 'package:matrix_messages/services/matrix/matrix_service.dart';
import 'package:matrix/matrix.dart';
import 'dart:math';

class Task implements Comparable<Task> {
  int id;
  String titulo;
  String resumen;
  String descripcion;
  List<dynamic> estados;
  String? fechaFinalizada;
  Map<String, dynamic> asignacion;
  Map<String, dynamic> etiquetas;
  String creador;
  String matrixroomid;
  Map<String, dynamic> tiempos;

  Task(
      this.id,
      this.titulo,
      this.resumen,
      this.descripcion,
      this.estados,
      this.fechaFinalizada,
      this.asignacion,
      this.etiquetas,
      this.creador,
      this.tiempos,
      this.matrixroomid);

  static List<String> getPossibleStates() {
    return ['Creada', 'Asignada', 'En Curso', 'Completada', 'Suspendida'];
  }

  Future<Task> toNextState(Client client) async {
    List<String> possibleStates = Task.getPossibleStates().sublist(1, 4);
    estados.insert(0, {
      'estado': possibleStates[min(
          (possibleStates.indexOf(getCurrentState()) + 1),
          possibleStates.length - 1)],
      'fecha': DateTime.now().toIso8601String(),
      'eta': null,
    });
    MatrixService matrixService = MatrixService();
    await matrixService.setRoomStateEvent(
        matrixroomid, client, 'm.room.tarea', toJson());

    return this;
  }

  Future<Task> toPreviousState(Client client) async {
    List<String> possibleStates = Task.getPossibleStates().sublist(1, 4);
    estados.insert(0, {
      'estado': possibleStates[
          max((possibleStates.indexOf(getCurrentState()) - 1), 0)],
      'fecha': DateTime.now().toIso8601String(),
      'eta': null,
    });
    MatrixService matrixService = MatrixService();
    await matrixService.setRoomStateEvent(
        matrixroomid, client, 'm.room.tarea', toJson());

    return this;
  }

  String getCreationString() {
    return estados[estados.length - 1]['fecha'];
  }

  Future<Task> takeGroupTask(Client client) async {
    String? userId = client.userID;
    if (isGroupTask() && getCurrentState() == 'Creada' && userId != null) {
      asignacion['asignado'] = userId;
      estados.insert(0, {
        'estado': 'Asignada',
        'fecha': DateTime.now().toIso8601String(),
        'eta': null,
      });
    }
    MatrixService matrixService = MatrixService();
    await matrixService.setRoomStateEvent(
        matrixroomid, client, 'm.room.tarea', toJson());
    return this;
  }

  Future<Task> dropGroupTask(Client client) async {
    if (isGroupTask() && getCurrentState() == 'Asignada') {
      asignacion['asignado'] = "";
      estados.insert(0, {
        'estado': 'Creada',
        'fecha': DateTime.now().toIso8601String(),
        'eta': null,
      });
    }
    MatrixService matrixService = MatrixService();
    await matrixService.setRoomStateEvent(
        matrixroomid, client, 'm.room.tarea', toJson());
    return this;
  }

  bool isGroupTask() {
    return asignacion['esGrupo'];
  }

  String? getAssignedUser() {
    return asignacion['asignado'];
  }

  String getCurrentState() {
    return estados[0]['estado'];
  }

  DateTime getLastUpdate() {
    return DateTime.parse(estados[0]['fecha']);
  }

  Duration getDelayDuration() {
    // older implementation

    // finds the older  state that is equal to the current state
    // then returns the difference between the current time and that state Datetime
    // completed task shows the delay from current State
    // if (getCurrentState() != 'Completada') {
    //   for (var estado in estados.reversed) {
    //     if (estado['estado'] == getCurrentState()) {
    //       return DateTime.now().difference(DateTime.parse(estado['fecha']));
    //     }
    //   }
    // } else {
    // return fromLastUpdate();
    // }
    // return Duration.zero;

    return fromLastUpdate();
  }

  Map<String, dynamic> getTags() {
    List<String> extraTags = [];
    String? priority;

    for (final tag in etiquetas.entries) {
      if (tag.value.isEmpty) continue;

      if (tag.key == 'prioridad') {
        priority = tag.value.first;
      } else {
        extraTags.add(tag.value.first);
      }
    }

    extraTags.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return {
      'priority': priority,
      'extraTags': extraTags,
    };
  }

  Duration fromLastUpdate() {
    Duration difference = DateTime.now().difference(getLastUpdate());
    return difference;
  }

  bool isBlockedTask(Duration endingTaskTime) {
    // setting endingtime as zero  will not block the task
    if (endingTaskTime == Duration.zero) {
      return false;
    }
    return getCurrentState() == 'Completada' &&
        fromLastUpdate() >= endingTaskTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'resumen': resumen,
      'descripcion': descripcion,
      'estados': estados,
      'tiempos': tiempos,
      'fechaFinalizada': fechaFinalizada,
      'asignacion': asignacion,
      'etiquetas': etiquetas,
      'creador': creador
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, titulo: $titulo, resumen: $resumen, descripcion: $descripcion, estados: $estados,tiempos $tiempos , fechaFinalizada: $fechaFinalizada, asignacion: $asignacion, etiquetas: $etiquetas, creador: $creador, matrixroomid: $matrixroomid}';
  }

  @override
  int compareTo(Task other) {
    // compares tasks, first by state ('Completadas' at the end), then by alarm state, then by delay duration
    if (getCurrentState() == 'Completada' &&
        other.getCurrentState() != 'Completada') {
      return 1;
    } else if (getCurrentState() != 'Completada' &&
        other.getCurrentState() == 'Completada') {
      return -1;
    } else if (getAlarmState() != other.getAlarmState()) {
      return other.getAlarmState() - getAlarmState();
    } else {
      return other.getDelayDuration().compareTo(getDelayDuration());
    }
  }

  Duration? getCurrentEta() {
    final etaMinutes = tiempos[getCurrentState()]?['eta'];
    return etaMinutes != null ? Duration(minutes: etaMinutes) : null;
  }

  Duration? getCurrentAlert() {
    final estadoActual = getCurrentState();
    final alertaMinutes = tiempos[estadoActual]?['alerta'];
    return alertaMinutes != null ? Duration(minutes: alertaMinutes) : null;
  }

  int getAlarmState() {
    //Returns alert states encoded as integers 0:completed task(no alert), 1: normal alert, 2: yellow alert, 3: red alert
    if (getCurrentEta() != null && getCurrentAlert() != null) {
      // in available 'tiempos'  in json
      Duration etaDuration = getCurrentEta()!;
      Duration proximo = getCurrentEta()! - getCurrentAlert()!;
      final Duration delayDuration = getDelayDuration();
      if (delayDuration >= etaDuration) {
        return 3;
      } else if (delayDuration >= proximo) {
        return 2;
      }
      return 1;
    }
    return 0;
  }
}
