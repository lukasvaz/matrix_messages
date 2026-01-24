import 'package:flutter/material.dart';

class TaskState extends StatelessWidget {
  final String tileState;
  final double iconSize;
  final Color? iconColor;
  final Color tileTextColor;
  final double fontSize;

  const TaskState(
      {super.key,
      required this.tileState,
      this.iconSize = 24,
      this.iconColor,
      this.tileTextColor = const Color(0xFF1A1A1A),
      this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    IconData? icon;

    switch (tileState) {
      case 'Asignada':
        icon = Icons.account_circle_outlined;
        break;
      case 'En Curso':
        icon = Icons.pending_outlined;
        break;
      case 'Completada':
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'Suspendida':
        icon = Icons.highlight_off_rounded;
        break;
      default:
        icon = null;
        break;
    }

    if (icon == null) {
      return const SizedBox.shrink();
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: iconColor ?? _getIconColor(), size: iconSize),
      Text(
        tileState,
        style: TextStyle(
            color: tileTextColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: 'OpenSans'),
      )
    ]);
  }

  Color _getIconColor() {
    switch (tileState) {
      case 'Asignada':
        return const Color(0xFF666666);
      case 'En Curso':
        return const Color(0xFF666666);
      case 'Completada':
        return const Color(0xFF999999);
      case 'Suspendida':
        return const Color(0xFF999999);
      default:
        return const Color(0xFF666666);
    }
  }
}
