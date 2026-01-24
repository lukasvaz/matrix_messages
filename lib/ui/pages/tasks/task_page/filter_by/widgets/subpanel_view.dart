import 'package:frontend/ui/pages/widgets/custom_checkbox.dart';
import 'package:frontend/ui/pages/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class SubPanelView extends StatelessWidget {
  final List<dynamic> etiquetaValues;
  final List<String> localSelectedValues;
  final List<String> etiquetas;
  final double screenHeight;
  final double screenWidth;
  final int selectedIndex;
  final Function(String, int) subfilterTaskCount;
  final Function(String) onValueChanged;
  final Function() onBack;

  const SubPanelView({
    super.key,
    required this.etiquetaValues,
    required this.localSelectedValues,
    required this.etiquetas,
    required this.screenHeight,
    required this.screenWidth,
    required this.selectedIndex,
    required this.subfilterTaskCount,
    required this.onValueChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: screenHeight * 0.012, bottom: screenHeight * 0.012),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.92,
                  child: Center(
                    child: Text(
                      etiquetas[selectedIndex],
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lato',
                        color: const Color(0xFF4F4F69),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2.5, height: 0, color: Color(0xFFDCDCDC)),
          etiquetaValues.length > 5
              ? SizedBox(
                  height: screenHeight * 0.35,
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
                          children: _buildSubfilterList(screenWidth, screenHeight),
                        ),
                      ),
                    ),
                  ))
              : Column(
                  children: _buildSubfilterList(screenWidth, screenHeight),
                ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.024),
              PrimaryButton(
                string: 'Volver',
                onPressed: onBack,
                width: screenWidth * 0.92,
                height: screenHeight * 0.054,
                fontSize: screenWidth * 0.038,
              ),
              SizedBox(height: screenHeight * 0.012),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubfilterList(double screenWidth, double screenHeight) {
    return List.generate(etiquetaValues.length, (i) {
      String value = etiquetaValues[i];
      return Column(
        children: [
          InkWell(
            onTap: () => onValueChanged(value),
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.07,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Row(
                children: [
                  CustomCheckbox(
                    value: localSelectedValues.contains(value),
                    onChanged: (bool? isChecked) {
                      onValueChanged(value);
                    },
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    '$value (${subfilterTaskCount(value, selectedIndex)})',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'OpenSans',
                      color: const Color(0xFF6A6870),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 2.5, height: 0, color: Color(0xFFDCDCDC)),
        ],
      );
    });
  }
}
