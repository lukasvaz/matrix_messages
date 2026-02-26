import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color checkColor;
  final Color borderColor;
  final double size;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFFFFFFFF),
    this.checkColor = const Color(0xFF8787A3),
    this.borderColor = const Color(0xFFC3C3D1),
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.transparent,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: value
            ? Icon(
                Icons.check,
                color: checkColor,
                size: size * 0.8,
              )
            : null,
      ),
    );
  }
}
