import 'package:flutter/material.dart';

class TertiaryButton extends StatefulWidget {
  final String string;
  final void Function() onPressed;
  final Color? color;
  final Color textColor;
  final Color outlineColor;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isBlocked;

  const TertiaryButton({
    super.key,
    required this.string,
    required this.onPressed,
    this.color = const Color(0xffffffff),
    this.textColor = const Color(0xff676767),
    this.outlineColor = const Color(0xff676767),
    this.width = 100,
    this.height = 20,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0.0),
    this.isBlocked = false,
  });

  @override
  State<TertiaryButton> createState() => TertiaryButtonState();
}

class TertiaryButtonState extends State<TertiaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius)),
          side: BorderSide(
              color: widget.isBlocked
                  ? const Color(0xffe2e2e2)
                  : widget.outlineColor,
              width: 3.0),
          foregroundColor:
              widget.isBlocked ? const Color(0xffe2e2e2) : widget.textColor,
          fixedSize: Size(widget.width, widget.height),
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
