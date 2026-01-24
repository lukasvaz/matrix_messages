import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double screenWidth;
  final double screenHeight;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.screenWidth,
      required this.screenHeight,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double screenProportion = screenHeight / screenWidth;
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.symmetric(
                vertical: screenProportion *
                    4, // Aumenta el padding cuando está seleccionado
                horizontal: screenProportion * 8),
            decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFe4e4ee) : Colors.transparent,
                borderRadius: BorderRadius.circular(8)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: screenProportion * 14, color: const Color(0xFF727287)),
              Text(label,
                  style: TextStyle(
                      fontSize: screenProportion * 4.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF727287),
                      fontFamily: 'OpenSans'))
            ])));
  }
}
