import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class ChannelsEmpty extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ChannelsEmpty(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final screenProportion = screenHeight / screenWidth;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Center(
          child: SvgPicture.asset('lib/assets/bg_empty_grid.svg',
              width: screenWidth * 0.5,
              height: screenHeight * 0.3,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFDCDCDC), BlendMode.srcIn))),
      const SizedBox(height: 16),
      Column(children: [
        Text("Para unirse a un canal",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenProportion * 12,
                fontFamily: 'Lato',
                color: const Color(0xFF87888A))),
        RichText(
            text: TextSpan(
                style: TextStyle(
                    fontSize: screenProportion * 8,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Lato',
                    color: const Color(0xFF87888A)),
                children: [
              const TextSpan(text: "presione "),
              WidgetSpan(
                  child: Icon(Icons.settings_outlined,
                      color: const Color(0xFF87888A),
                      size: screenProportion * 9)),
              const TextSpan(text: " en la barra superior.")
            ]))
      ])
    ]);
  }
}