import 'package:frontend/ui/pages/channels/channels_page/widgets/room_tile.dart';
import 'package:flutter/material.dart';

class FolderTile extends StatefulWidget {
  final String title;
  final List<dynamic> subRooms;

  const FolderTile({super.key, required this.title, required this.subRooms});

  @override
  FolderTileState createState() => FolderTileState();
}

class FolderTileState extends State<FolderTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCDCDC), width: 1.0)),
        child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
                leading: Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: const Color(0xFF6A6870),
                    size: 32),
                showTrailingIcon: false,
                title: Text(widget.title,
                    style: const TextStyle(
                        color: Color(0xFF6A6870),
                        fontFamily: 'OpenSans',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
                children: widget.subRooms.map((subRoom) {
                  return RoomTile(room: subRoom, isExpanded: isExpanded);
                }).toList(),
                onExpansionChanged: (expanded) {
                  if (widget.subRooms.isEmpty) {
                    return;
                  }
                  setState(() {
                    isExpanded = expanded;
                  });
                })));
  }
}
