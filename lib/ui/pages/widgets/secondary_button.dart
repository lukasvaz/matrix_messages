import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
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

  const SecondaryButton({
    super.key,
    required this.string,
    required this.onPressed,
    this.color = const Color(0xffffffff),
    this.textColor = const Color(0xff4f4f69),
    this.outlineColor = const Color(0xff4f4f69),
    this.width = 100,
    this.height = 20,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 18.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 0.0),
  });

  @override
  State<SecondaryButton> createState() => SecondaryButtonState();
}

class SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius)),
          side: BorderSide(color: widget.outlineColor, width: 4.0),
          foregroundColor: widget.textColor,
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
