import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String string;
  final void Function() onPressed;
  final Color? color;
  final Color textColor;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.string,
    required this.onPressed,
    this.color = const Color(0xffff6600),
    this.textColor = const Color(0xffffffff),
    this.width = 100,
    this.height = 20,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 18.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0.0),
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: widget.textColor,
          fixedSize: Size(widget.width, widget.height),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius)),
          padding: widget.padding),
      child: Text(
        widget.string,
        style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            fontFamily: 'OpenSans'),
      ),
    );
  }
}
