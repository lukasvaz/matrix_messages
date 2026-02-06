import 'package:matrix_messages/domain/entities/task.dart';
import 'package:matrix_messages/utils/validations.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'dart:convert';

/// A service class to interact with the Matrix API.
///
/// This class provides methods to retrieve rooms, get room state events, set room state events, etc.
/// using a Matrix client and making HTTP requests to the Matrix server.
class MatrixService {
  /// Retrieves all rooms the client is joined within a given space.
  ///
  /// Takes a Matrix client and a space alias as parameters.
  List<Room>? getClientRoomsInSpace(Client client, String spaceAlias) {
    try {
      List<Room> spaceRooms = [];
      final spaceRoom = client.getRoomByAlias(spaceAlias);
      final space = spaceRoom?.spaceChildren;

      if (space == null) {
        return null;
      }

      for (final room in space) {
        final roomId = room.roomId;
        final thisRoom = client.getRoomById(roomId!);
        if (thisRoom != null && client.rooms.contains(thisRoom)) {
          spaceRooms.add(thisRoom);
        }
      }

      return spaceRooms;
    } catch (e) {
      return null;
    }
  }

  /// Get a certain state event of a room.
  ///
  /// Takes matrix room's roomId, client's accessToken and eventType (e.g. m.room.tarea) as parameters.
  Future<Map<String, dynamic>?> getRoomStateEvent(
      String roomId, String accessToken, String eventType) async {
    final String url =
        'https://matrix1.lahuen.health/_matrix/client/v3/rooms/$roomId/state/$eventType/?access_token=$accessToken';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.body;
        return jsonDecode(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Sets (creates or updates) a room's state event.
  ///
  /// Takes matrix room's roomId and client, the event type (e.g., m.room.tarea), and a JSON object representing the content to be set for the room's event.
  Future<String?> setRoomStateEvent(String roomId, Client client,
      String eventType, Map<String, dynamic> content) async {
    final accessToken = client.accessToken;
    final String url =
        'https://matrix1.lahuen.health/_matrix/client/v3/rooms/$roomId/state/$eventType/?access_token=$accessToken';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(content),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get client's tasks.
  ///
  /// Takes matrix client and the roomSpace from which tasks will be obtained (Tasks space), validating them.
  Future<List<Task>> getTasksFromRooms(
      Client client, String roomSpace) async {
    final rooms = getClientRoomsInSpace(client, roomSpace) ?? [];
    List<Task> tasks = [];

    for (final room in rooms) {
      final taskData =
          await getRoomStateEvent(room.id, client.accessToken!, 'm.room.tarea');
      if (taskData != null && isValidTask(taskData)) {
        Task task = Task(
            taskData['id'] ?? 0,
            taskData['titulo'],
            taskData['resumen'],
            taskData['descripcion'],
            taskData['estados'],
            taskData['fechaFinalizada'],
            taskData['asignacion'],
            taskData['etiquetas'],
            taskData['creador'],
            taskData['tiempos'],
            room.id);
        tasks.add(task);
      }
    }
    return tasks;
  }

  Future<Task> getTaskState(String roomId, String accessToken) async {
    final taskData =
        await getRoomStateEvent(roomId, accessToken, 'm.room.tarea');

    if (taskData != null && isValidTask(taskData)) {
      Task task = Task(
        taskData['id'] ?? 0,
        taskData['titulo'],
        taskData['resumen'],
        taskData['descripcion'],
        taskData['estados'],
        taskData['fechaFinalizada'],
        taskData['asignacion'],
        taskData['etiquetas'],
        taskData['creador'],
        taskData['tiempos'],
        roomId,
      );
      return task;
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }
}
