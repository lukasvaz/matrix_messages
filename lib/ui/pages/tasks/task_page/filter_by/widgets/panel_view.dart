import 'package:frontend/ui/pages/widgets/secondary_button.dart';
import 'package:frontend/ui/pages/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class PanelView extends StatelessWidget {
  final List<String> etiquetas;
  final List<String> selectedFilter;
  final double screenWidth;
  final double screenHeight;
  final Function(int) onTap;
  final Function() onClearFilters;
  final Function() onApplyFilters;

  const PanelView(
      {super.key,
      required this.etiquetas,
      required this.selectedFilter,
      required this.screenWidth,
      required this.screenHeight,
      required this.onTap,
      required this.onClearFilters,
      required this.onApplyFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.012, bottom: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (selectedFilter.isEmpty)
                      SizedBox(width: screenWidth * 0.16),
                    if (selectedFilter.isNotEmpty)
                      SizedBox(
                          width: screenWidth * 0.18,
                          child: TextButton(
                              onPressed: onClearFilters,
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.all<EdgeInsets>(
                                      EdgeInsets.zero),
                                  minimumSize:
                                      WidgetStateProperty.all<Size>(Size.zero),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape:
                                      WidgetStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)))),
                              child: Text('Limpiar',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.043,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'OpenSans',
                                      color: const Color(0xFF4F4F69))))),
                    SizedBox(
                        width: screenWidth * 0.56,
                        child: Center(
                            child: Text('Filtros',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.055,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Lato',
                                    color: const Color(0xFF4F4F69))))),
                    SizedBox(width: screenWidth * 0.18)
                  ])),
          const Divider(thickness: 1.5, color: Color(0xFFDCDCDC)),
          SizedBox(height: screenHeight * 0.008),
          etiquetas.length > 5
              ? SizedBox(
                  height: screenHeight * 0.316,
                  child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all<Color>(
                              const Color(0xFFCCCCCC)),
                          radius: const Radius.circular(20)),
                      child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 6.0,
                          child: SingleChildScrollView(
                              child: Column(
                                  children: _buildFilterList(
                                      screenWidth, screenHeight))))))
              : Column(children: _buildFilterList(screenWidth, screenHeight)),
          Column(children: [
            SizedBox(height: screenHeight * 0.036),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SecondaryButton(
                  string: 'Cerrar',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  textColor: const Color(0xFF676767),
                  outlineColor: const Color(0xFF676767),
                  width: screenWidth * 0.44,
                  height: screenHeight * 0.054,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w800),
              PrimaryButton(
                  string: 'Aplicar filtros',
                  onPressed: onApplyFilters,
                  width: screenWidth * 0.44,
                  height: screenHeight * 0.054,
                  fontSize: screenWidth * 0.038)
            ]),
            SizedBox(height: screenHeight * 0.018)
          ])
        ]));
  }

  List<Widget> _buildFilterList(double screenWidth, double screenHeight) {
    return List.generate(etiquetas.length, (index) {
      return Column(children: [
        InkWell(
            onTap: () => onTap(index),
            splashColor: const Color(0xFFA6A6A6).withOpacity(0.3),
            highlightColor: const Color(0xFFA6A6A6).withOpacity(0.15),
            child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        border: Border.all(
                            color: const Color(0xFFE4E4EA), width: 2.0)),
                    clipBehavior: Clip.hardEdge,
                    child: Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.04),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(etiquetas[index],
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.043,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'OpenSans',
                                            color: const Color(0xFF6A6870))),
                                    const SizedBox(width: 6),
                                    selectedFilter.contains(etiquetas[index])
                                        ? Container(
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFF4A14C),
                                                shape: BoxShape.circle),
                                            width: screenHeight * 0.02,
                                            height: screenHeight * 0.02)
                                        : const SizedBox.shrink()
                                  ]),
                              Container(
                                  width: screenHeight * 0.06,
                                  height: screenHeight * 0.06,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE4E4EB),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              screenWidth * 0.04),
                                          bottomLeft: Radius.circular(
                                              screenWidth * 0.04))),
                                  child: Icon(Icons.arrow_forward_ios_rounded,
                                      color: const Color(0xFFA6A6A6),
                                      size: screenWidth * 0.05,
                                      weight: 6.0))
                            ]))))),
        if (index != etiquetas.length - 1)
          SizedBox(height: screenHeight * 0.004)
      ]);
    });
  }
}
