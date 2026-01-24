import 'package:frontend/ui/pages/channels/channel_chat/channel_chat.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class RoomTile extends StatefulWidget {
  final Room room;
  final bool isExpanded;

  const RoomTile({
    super.key,
    required this.room,
    this.isExpanded = false,
  });

  @override
  RoomTileState createState() => RoomTileState();
}

class RoomTileState extends State<RoomTile> with TickerProviderStateMixin {
  late final SlidableController _slidableController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    _animation = _slidableController.animation;
  }

  bool isRenderTile(Room room) {
    return room.tags.keys.contains("tlc.subscribed") ? true : false;
  }

  // Método para unirse a una sala
  void join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    if (mounted) {
      room.setReadMarker(room.lastEvent?.eventId,
          mRead: room.lastEvent?.eventId, public: true);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChannelChat(room: room)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isRenderTile(widget.room)
        ? Stack(children: [
            ListTile(
                leading: const Icon(Icons.tag_rounded),
                title: Text(widget.room.getLocalizedDisplayname(),
                    style: const TextStyle(
                        color: Color(0xFF6A6870),
                        fontFamily: 'OpenSans',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500))),
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final opacity = (_animation.value * 255 * 2).toInt();
                  return Slidable(
                      controller: _slidableController,
                      endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          children: [
                            SlidableAction(
                                onPressed: (context) {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    widget.room.removeTag('tlc.subscribed');
                                  });
                                },
                                backgroundColor: const Color(0xFFFF5757),
                                foregroundColor: Colors.white,
                                icon: Icons.logout_rounded,
                                label: 'Salir')
                          ]),
                      child: ListTile(
                          leading: null,
                          title: null,
                          tileColor: widget.isExpanded
                              ? Color.fromARGB(opacity, 0, 0, 0)
                              : Colors.transparent,
                          onTap: () => join(widget.room)));
                })
          ])
        : const SizedBox();
  }
}