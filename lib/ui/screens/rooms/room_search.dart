import 'dart:async';
import 'package:matrix_messages/ui/screens/rooms/lib/lib.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';


class RoomSearch extends StatefulWidget {
  final List<Room> rooms;
  final void Function(Room room) onRoomTap;
  final String initialQuery;

  const RoomSearch({
    Key? key,
    required this.rooms,
    required this.onRoomTap,
    this.initialQuery = '',
  }) : super(key: key);

  @override
  State<RoomSearch> createState() => _RoomSearchState();
}

class _RoomSearchState extends State<RoomSearch> {
  late TextEditingController _controller;
  Timer? _debounce;
  late List<Room> _filtered;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _filtered = searchRoomsByQuery(widget.initialQuery, widget.rooms);
    _controller.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant RoomSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the rooms list changed externally, re-run filter
    if (oldWidget.rooms != widget.rooms) {
      _applyFilter(_controller.text);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _applyFilter(_controller.text);
    });
  }

  void _applyFilter(String q) {
    final results = searchRoomsByQuery(q, widget.rooms);
    setState(() => _filtered = results);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black45),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Search rooms, people...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black45),
                      onPressed: () {
                        _controller.clear();
                      },
                    ),
                ],
              ),
            ),
          ),
      
          // Results list
          Expanded(
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No matching rooms', style: TextStyle(color: Colors.black54)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final room = _filtered[index];
                      final title = room.name.isNotEmpty ? room.name : room.id;
                      final subtitle = room.topic ?? '';
                      final avatarLetter = title.isNotEmpty ? title[0] : '?';
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blueGrey,
                          child: Text(avatarLetter, style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: subtitle.isNotEmpty ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                        onTap: () => widget.onRoomTap(room),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
