import 'package:flutter/material.dart';
import 'package:matrix_messages/ui/screens/widgets/profile_image.dart';
import 'package:provider/provider.dart';
import 'package:matrix/matrix.dart';
import 'dart:async';

class RoomsSection extends StatefulWidget {
  const RoomsSection({super.key});

  @override
  State<RoomsSection> createState() => _RoomsSectionState();
}

class _RoomsSectionState extends State<RoomsSection> {
  late final Client _client;
  StreamSubscription<SyncUpdate>? _syncSub;
  StreamSubscription<SyncStatusUpdate>? _syncStatusSub;

  @override
  void initState() {
    super.initState();
    _client = context.read<Client>();    
    _syncStatusSub = _client.onSyncStatus.stream.listen((status) {
      if (status.status == SyncStatus.finished) {
        if (mounted) setState(() {});
      }
    });
    _syncSub = _client.onSync.stream.listen((sync) {
      final hasRoomChanges = (sync.rooms?.join?.isNotEmpty ?? false) ||
          (sync.rooms?.invite?.isNotEmpty ?? false) ||
          (sync.rooms?.leave?.isNotEmpty ?? false) ||
          (sync.rooms?.knock?.isNotEmpty ?? false);
      if (hasRoomChanges && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    _syncStatusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joinedRooms = _client.rooms;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: const ProfileImage(),
        title: const Text('Rooms', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            itemBuilder: (c) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'help', child: Text('Help')),
            ],
            onSelected: (_) {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // top search area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.black45),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Search rooms, people...', style: TextStyle(color: Colors.black45)),
                    ),
                    Icon(Icons.filter_list, color: Colors.black45),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),

                  // Rooms list - render joined rooms from the client
                  if (joinedRooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No joined rooms yet', style: TextStyle(color: Colors.black54)),
                    )
                  else
                    ...joinedRooms.map((room) {
                      final title = room.name;
                      final subtitle = room.topic;
                      final avatarLetter = title.isNotEmpty ? title.substring(0, 1) : '?';
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blueGrey,
                              child: Text(avatarLetter, style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 6),
                              ],
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    }),

                  const SizedBox(height: 80), // bottom padding
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

