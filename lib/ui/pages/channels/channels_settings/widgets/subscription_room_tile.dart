import 'package:flutter/material.dart';
import 'package:frontend/ui/pages/channels/channels_settings/widgets/secondary_channel_button.dart';
import 'package:frontend/ui/pages/channels/channels_settings/widgets/primary_channel_button.dart';
import 'package:matrix/matrix.dart';

class SubscriptionRoomTile extends StatelessWidget {
  final dynamic room;

  const SubscriptionRoomTile({
    super.key,
    required this.room,
  });

  void updateRoomToSubscribed(Room room) {
    room.addTag('tlc.subscribed');
  }

  void updateRoomToUnsubscribed(Room room) {
    room.removeTag('tlc.subscribed');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.tag),
      title: Row(
        children: [
          Text(
            room.getLocalizedDisplayname(),
            style: const TextStyle(
              color: Color(0xFF6A6870),
              fontFamily: 'OpenSans',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          room.tags.keys.contains('tlc.subscribed')
              ? SecondaryChannelButton(
                  room: room,
                  title: "Salir",
                  width: 100,
                  height: 25,
                  fontsize: 12,
                  onPressed: () => updateRoomToUnsubscribed(room),
                )
              : PrimaryChannelButton(
                  room: room,
                  title: "Unirse",
                  width: 100,
                  height: 25,
                  fontsize: 12,
                  onPressed: () => updateRoomToSubscribed(room),
                ),
        ],
      ),
    );
  }
}
