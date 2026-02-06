import 'package:matrix_messages/ui/pages/widgets/custom_radio_button.dart';
import 'package:matrix_messages/ui/pages/widgets/secondary_button.dart';
import 'package:matrix_messages/ui/pages/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class GroupBy extends StatefulWidget {
  final String selectedGroup;
  final List<String> etiquetas;
  final double screenWidth;
  final double screenHeight;
  final Function(String) setSelectedGroup;

  const GroupBy(
      {super.key,
      required this.selectedGroup,
      required this.etiquetas,
      required this.screenWidth,
      required this.screenHeight,
      required this.setSelectedGroup});

  @override
  GroupByState createState() => GroupByState();
}

class GroupByState extends State<GroupBy> {
  late String localSelectedGroup;

  @override
  void initState() {
    super.initState();
    localSelectedGroup = widget.selectedGroup;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        width: widget.screenHeight * 0.058,
        height: widget.screenHeight * 0.058,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
            color: Color(0xFFE5E5EB), shape: BoxShape.circle),
        child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  barrierColor: const Color.fromARGB(140, 0, 0, 0),
                  builder: (BuildContext context) {
                    return Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: widget.screenHeight * 0.028),
                            child: Center(
                              child: Text('Grupos',
                                  style: TextStyle(
                                      color: const Color(0xFF4F4F69),
                                      fontSize: widget.screenWidth * 0.055,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Lato')),
                            ),
                          ),
                          StatefulBuilder(builder: (context, setModalState) {
                            return Column(children: <Widget>[
                              const Divider(
                                  thickness: 2.5,
                                  height: 0,
                                  color: Color(0xFFDCDCDC)),
                              widget.etiquetas.length > 5
                                  ? SizedBox(
                                      height: widget.screenHeight * 0.35,
                                      child: ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                            thumbColor:
                                                WidgetStateProperty.all<Color>(
                                                    const Color(0xFFCCCCCC)),
                                            radius: const Radius.circular(20)),
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          thickness: 6.0,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: _buildLabelsList(
                                                  widget.screenWidth,
                                                  widget.screenHeight,
                                                  setModalState),
                                            ),
                                          ),
                                        ),
                                      ))
                                  : Column(
                                      children: _buildLabelsList(widget.screenWidth,
                                          widget.screenHeight, setModalState),
                                    ),
                              SizedBox(height: widget.screenHeight * 0.032),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SecondaryButton(
                                        string: 'Cerrar',
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        width: widget.screenWidth * 0.45,
                                        height: widget.screenHeight * 0.054,
                                        fontSize: widget.screenWidth * 0.04,
                                        fontWeight: FontWeight.w800,
                                        textColor: const Color(0xFF80809C),
                                        outlineColor: const Color(0xFF80809C)),
                                    PrimaryButton(
                                      string: 'Aplicar cambios',
                                      onPressed: () {
                                        widget.setSelectedGroup(
                                            localSelectedGroup);
                                        Navigator.pop(context);
                                      },
                                      width: widget.screenWidth * 0.45,
                                      height: widget.screenHeight * 0.054,
                                      fontSize: widget.screenWidth * 0.04,
                                      fontWeight: FontWeight.w800,
                                    )
                                  ]),
                              SizedBox(height: widget.screenHeight * 0.018)
                            ]);
                          })
                        ]));
                  }).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    localSelectedGroup = widget.selectedGroup;
                  });
                });
              });
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.view_agenda_outlined,
                color: const Color(0xFF727287), size: widget.screenHeight * 0.036),
            tooltip: 'Agrupar'));
  }

  List<Widget> _buildLabelsList(double screenWidth, double screenHeight,
      void Function(void Function()) setModalState) {
    return List.generate(widget.etiquetas.length, (index) {
      return Column(
        children: [
          InkWell(
              onTap: () {
                setModalState(() {
                  localSelectedGroup = widget.etiquetas[index];
                });
              },
              child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomRadioButton(
                            value: widget.etiquetas[index],
                            groupValue: localSelectedGroup,
                            selectedColor: const Color(0xFF8787A3),
                            unselectedColor: const Color(0xFFC3C3D1),
                            onChanged: (val) {
                              if (localSelectedGroup == val) return;
                              setModalState(() {
                                localSelectedGroup = val;
                              });
                            },
                            size: screenWidth * 0.056),
                        SizedBox(width: screenWidth * 0.02),
                        Text(widget.etiquetas[index],
                            style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'OpenSans',
                                color: const Color(0xFF6A6870)))
                      ]))),
          const Divider(thickness: 2.5, height: 0, color: Color(0xFFDCDCDC))
        ],
      );
    });
  }
}
