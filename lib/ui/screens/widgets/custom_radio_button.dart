import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String value;
  final String groupValue;
  final Function(String) onChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final double size;
  final Duration animationDuration;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.selectedColor = const Color(0xFF8787A3),
    this.unselectedColor = const Color(0xFFC3C3D1),
    this.size = 22.0,
    this.animationDuration = const Duration(milliseconds: 200)
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onChanged(value);
        }
      },
      child: AnimatedContainer(
        duration: animationDuration,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: unselectedColor,
            width: 2.0
          )
        ),
        child: Center(
          child: AnimatedContainer(
            duration: animationDuration,
            width: isSelected ? size * 0.6 : 0,
            height: isSelected ? size * 0.6 : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? selectedColor : Colors.transparent
            )
          )
        )
      )
    );
  }
}