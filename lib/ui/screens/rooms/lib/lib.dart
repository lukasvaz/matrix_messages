import 'package:matrix/matrix.dart';

/// Return rooms whose name contains [query]
List<Room> searchRoomsByQuery(String query, List<Room> rooms) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return rooms;
  return rooms.where((r) {
    final name = (r.name).toLowerCase();
    return name.contains(q);
  }).toList();
}