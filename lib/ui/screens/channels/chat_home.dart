import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_messages/services/matrix/matrix_service.dart';

/// Lightweight model for directory entries (not full SDK Room)
class DirectoryRoom {
  final String roomId;
  final String? alias;
  final String? name;
  final String? topic;
  final String? roomType;

  DirectoryRoom({
    required this.roomId,
    this.alias,
    this.name,
    this.topic,
    this.roomType,
  });
}

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final MatrixService _service = MatrixService();
  List<DirectoryRoom> _directory = [];
  List<String> _joinedRoomIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final client = Provider.of<Client>(context, listen: false);
    final chunk = await _service.discoverPublicRoomsRaw(client);

    final directory = <DirectoryRoom>[];
    for (final e in chunk) {
      final roomId = (e['room_id'] ?? e['roomId']) as String?;
      if (roomId == null) continue;
      directory.add(DirectoryRoom(
        roomId: roomId,
        alias: e['canonical_alias'] as String?,
        name: e['name'] as String?,
        topic: e['topic'] as String?,
        roomType: e['room_type'] as String?,
      ));
    }

    // build joined list from client cache
    final clientRooms = Provider.of<Client>(context, listen: false).rooms;
    final joinedIds = clientRooms.map((r) => r.id).toSet();

    setState(() {
      _directory = directory;
      _joinedRoomIds = joinedIds.toList();
      _loading = false;
    });
  }

  Future<void> _joinRoom(String roomId) async {
    final client = Provider.of<Client>(context, listen: false);
    try {
      print('Joining room $roomId...');
      await client.joinRoomById(roomId);
      // give the SDK a short moment to process sync/state
      await Future.delayed(const Duration(milliseconds: 500));
      await _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Join failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Public rooms')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  ListTile(title: Text('Joined')),
                  ..._joinedRoomIds.map((id) => ListTile(
                        title: Text(id),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/channels'),
                      )),
                  Divider(),
                  ListTile(title: Text('Directory')),
                  ..._directory.map((r) => ListTile(
                        title: Text(r.name ?? r.alias ?? r.roomId),
                        subtitle: r.topic != null ? Text(r.topic!) : null,
                        trailing: _joinedRoomIds.contains(r.roomId)
                            ? Text('Joined')
                            : ElevatedButton(
                                child: Text('Join'),
                                onPressed: () => _joinRoom(r.roomId),
                              ),
                      )),
                ],
              ),
            ),
    );
  }
}
