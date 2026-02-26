import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class PrimaryChannelButton extends StatelessWidget {
  final Room room;
  final String title;
  final double width;
  final double height;
  final double fontsize;
  final Function onPressed;

  const PrimaryChannelButton({
    super.key,
    required this.room,
    required this.width,
    required this.height,
    required this.fontsize,
    required this.title,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        backgroundColor: const Color(0xff4f4f69),
        foregroundColor: const Color(0xffffffff),
        minimumSize: Size(width, height),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: Color(0xff4f4f69), width: 1.5),
      ),
      child: Text(title, style: TextStyle(fontSize: fontsize)),
    );
  }
}
