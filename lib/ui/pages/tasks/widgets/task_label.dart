import 'package:flutter/material.dart';

class TaskLabel extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double fontSize;

  const TaskLabel({
    super.key,
    required this.label,
    this.backgroundColor = const Color(0xFFe8e5fd),
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return ChipTheme(
      data: ChipThemeData(
          backgroundColor: backgroundColor,
          shape: const StadiumBorder(
            side: BorderSide(color: Colors.transparent, width: 0),
          ),
          padding: padding),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontFamily: 'OpenSans',
              fontSize: fontSize),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
