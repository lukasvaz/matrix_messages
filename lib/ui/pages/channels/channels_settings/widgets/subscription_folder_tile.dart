import 'package:frontend/ui/pages/channels/channels_settings/widgets/primary_channel_button.dart';
import 'package:frontend/ui/pages/channels/channels_settings/widgets/secondary_channel_button.dart';
import 'package:frontend/ui/pages/channels/channels_settings/widgets/subscription_room_tile.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class SubscriptionFolderTile extends StatefulWidget {
  final String title;
  final List<dynamic> subRooms;
  final Room folder;
  final Function(dynamic subRoom) onRoomTap;

  const SubscriptionFolderTile({
    super.key,
    required this.title,
    required this.subRooms,
    required this.folder,
    required this.onRoomTap,
  });

  void anyRoomSubscribed(List<dynamic> subRooms) {
    bool folderSubscribed = false;
    for (var room in subRooms) {
      if (room.tags.keys.contains('tlc.subscribed')) {
        folderSubscribed = true;
        break;
      }
    }
    if (folderSubscribed && !folder.tags.keys.contains('tlc.subscribed')) {
      folder.addTag('tlc.subscribed');
    }
    if (!folderSubscribed && folder.tags.keys.contains('tlc.subscribed')) {
      folder.removeTag('tlc.subscribed');
    }
  }

  @override
  SubscriptionFolderTileState createState() => SubscriptionFolderTileState();
}

bool allRoomsSubscribed(List<dynamic> subRooms) {
  for (var room in subRooms) {
    if (!room.tags.keys.contains('tlc.subscribed')) {
      return false;
    }
  }
  return true;
}

void unSubscribeAllRooms(List<dynamic> subRooms) {
  for (var room in subRooms) {
    room.removeTag('tlc.subscribed');
  }
}

void subscribeAllRooms(List<dynamic> subRooms) {
  for (var room in subRooms) {
    room.addTag('tlc.subscribed');
  }
}

class SubscriptionFolderTileState extends State<SubscriptionFolderTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    widget.anyRoomSubscribed(widget.subRooms);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: const Color(0xFFDCDCDC),
        width: 1.0,
      )),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: const Color(0xFF6A6870),
            size: 32,
          ),
          showTrailingIcon: false,
          title: Row(
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      color: Color(0xFF6A6870),
                      fontFamily: 'OpenSans',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500)),
              const Spacer(
                flex: 1,
              ),
              allRoomsSubscribed(widget.subRooms)
                  ? SecondaryChannelButton(
                      room: widget.subRooms.first,
                      title: "Salir de Todos",
                      width: 100,
                      height: 25,
                      fontsize: 12,
                      onPressed: () => unSubscribeAllRooms(widget.subRooms),
                    )
                  : PrimaryChannelButton(
                      room: widget.subRooms.first,
                      title: "Unirse a Todos",
                      width: 100,
                      height: 25,
                      fontsize: 12,
                      onPressed: () => subscribeAllRooms(widget.subRooms))
            ],
          ),
          children: widget.subRooms.map((subRoom) {
            return SubscriptionRoomTile(
              key: Key(subRoom.id),
              room: subRoom,
            );
          }).toList(),
          onExpansionChanged: (expanded) {
            if (widget.subRooms.isEmpty) {
              return;
            }
            setState(() {
              isExpanded = expanded;
            });
          },
        ),
      ),
    );
  }
}
