import 'package:flutter/material.dart';

class ChatInformation extends StatelessWidget implements PreferredSizeWidget {
  final String roomName;
  final int memberCount;
  final double screenWidth;
  final double screenHeight;

  const ChatInformation(
      {super.key,
      required this.roomName,
      required this.memberCount,
      required this.screenWidth,
      required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final screenProportion = screenHeight / screenWidth;

    return Container(
        padding: EdgeInsets.only(top: screenProportion * 3),
        decoration: const BoxDecoration(
            color: Color(0xFFF2F2F4),
            border: Border(bottom: BorderSide(color: Color(0xFFDCDCDC)))),
        child: AppBar(
            backgroundColor: const Color(0xFFF2F2F4),
            titleSpacing: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: screenProportion * 12),
                color: const Color(0xFF4F4F69),
                tooltip: 'Volver',
                onPressed: () {
                  Navigator.pop(context);
                }),
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#$roomName',
                  style: TextStyle(
                      fontSize: screenProportion * 8.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F4F69))),
              Text('$memberCount miembros',
                  style: TextStyle(
                      fontSize: screenProportion * 6.5,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'OpenSans',
                      color: const Color(0xFF4F4F69)))
            ])));
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight / screenWidth * 30);
}