import 'package:flutter/material.dart';

class AppBarWithSettings extends StatelessWidget
    implements PreferredSizeWidget {
  final double screenHeight;
  final double screenWidth;
  final String title;
  final Widget? redirection;
  final double? fontSize;
  final bool hasBackArrow;

  const AppBarWithSettings({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.title,
    this.redirection,
    this.fontSize,
    this.hasBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F2),
      padding: EdgeInsets.only(
        left: screenWidth * 0.02,
        top: screenHeight * 0.056,
        right: screenWidth * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hasBackArrow
              ? SizedBox(
                  width: screenWidth * 0.13,
                  height: screenHeight * 0.09,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: const Color(0xFF4F4F69),
                      size: screenWidth * 0.065,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              : SizedBox(
                  width: screenWidth * 0.13,
                  height: screenHeight * 0.09,
                ),
          SizedBox(
            width: screenWidth * 0.7,
            height: screenHeight * 0.09,
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF4F4F69),
                  fontSize: fontSize ?? screenWidth * 0.09,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Lato',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          redirection != null
              ? SizedBox(
                  width: screenWidth * 0.13,
                  height: screenHeight * 0.09,
                  child: IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: const Color(0xFF4F4F69),
                      size: screenWidth * 0.08,
                    ),
                    onPressed: () {
                      if (redirection != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => redirection!),
                        );
                      }
                    },
                  ),
                )
              : SizedBox(
                  width: screenWidth * 0.13,
                  height: screenHeight * 0.09,
                )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.09);
}
