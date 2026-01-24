import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class ChannelsSearchedNone extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ChannelsSearchedNone(
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
      Text("No se encontraron resultados",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenProportion * 11,
              fontFamily: 'Lato',
              color: const Color(0xFF87888A))),
      const SizedBox(height: 8),
      Text("Modifique los criterios y vuelva a intentarlo",
          style: TextStyle(
              fontSize: screenProportion * 8,
              fontFamily: 'Lato',
              color: const Color(0xFF87888A)))
    ]);
  }
}