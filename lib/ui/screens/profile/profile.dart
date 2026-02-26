import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_messages/ui/screens/hospitals/hospitals.dart';
import 'package:matrix_messages/ui/screens/widgets/bottom_nav_bar_widget.dart';
import 'package:matrix_messages/features/authentication/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? hospitalName;

  @override
  void initState() {
    super.initState();
    _loadHospitalPreference();
  }

  Future<void> _loadHospitalPreference() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hospitalName = 'hospitalName'; //prefs.getString('hospital_name');
    });
  }

  // Lista de prefijos conocidos
  final List<String> hospitalPrefixes = [
    'Hospital',
    'Clínica',
    'Centro de Salud',
    // Agrega más prefijos aquí en el futuro si es necesario
  ];

  // Función para obtener el tipo de hospital
  String getHospitalType(String? hospitalName) {
    if (hospitalName == null || hospitalName.isEmpty) {
      return 'Centro de Salud'; // Valor predeterminado
    }

    for (String prefix in hospitalPrefixes) {
      if (hospitalName.toLowerCase().startsWith(prefix.toLowerCase())) {
        return prefix;
      }
    }

    return 'Centro de Salud'; // Predeterminado si no coincide con ningún prefijo
  }

  // Función para obtener el nombre sin el tipo de hospital
  String getHospitalNameWithoutType(String? hospitalName) {
    if (hospitalName == null || hospitalName.isEmpty) {
      return 'Sin Nombre';
    }

    for (String prefix in hospitalPrefixes) {
      if (hospitalName.toLowerCase().startsWith(prefix.toLowerCase())) {
        return hospitalName.substring(prefix.length).trim(); // Elimina el prefijo
      }
    }

    return hospitalName; // Si no tiene prefijo conocido, devuelve todo
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final hospitalType = getHospitalType(hospitalName);
    final hospitalNameWithoutType = getHospitalNameWithoutType(hospitalName);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        leading: const SizedBox(),
        leadingWidth: 0,
        titleSpacing: screenWidth * 0.06,
        toolbarHeight: screenHeight * 0.092,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidth * 0.55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Muestra el tipo de hospital
                  Text(
                    hospitalType,
                    style: TextStyle(
                      color: const Color(0xFF4F4F69),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Lato",
                    ),
                  ),
                  // Muestra el resto del nombre
                  Text(
                    hospitalNameWithoutType,
                    style: TextStyle(
                      color: const Color(0xFF4F4F69),
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Lato",
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
                backgroundColor: const Color(0xFF80809C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () async {
                await context.read<AuthProvider>().logout(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Hospitals()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: screenWidth * 0.048,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Cambiar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.01),
          const Divider(color: Color(0xffdcdcdc), height: 0, thickness: 1),
          const Expanded(child: Center()),
        ],
      ),
      bottomNavigationBar: BottomNavBarWidget(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        section: 0
      ),
    );
  }
}
