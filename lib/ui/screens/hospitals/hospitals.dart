import 'package:matrix_messages/providers/load_hospitals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_messages/features/authentication/providers/auth_provider.dart';
// import 'package:matrix_messages/ui/pages/qr/qr_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'widgets/hospital_tile.dart';

class Hospitals extends StatefulWidget {
  final Map<String, dynamic>? data;

  const Hospitals({super.key, this.data});

  @override
  HospitalsState createState() => HospitalsState();
}

class HospitalsState extends State<Hospitals> {
  String? userName;
  String? formattedUserName;

  @override
  void initState() {
    super.initState();
    _loadUserPreference();
  }

  Future<void> _loadUserPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color(0xFFF2F2F4),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height: screenHeight * 0.9,
              child: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.07,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05),
                  child: Column(children: [
                    Center(
                        child: Text(
                            userName == null
                                ? '¡Bienvenido/a!'
                                : '¡Bienvenido/a $userName!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: screenWidth * 0.12,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6600)))),
                    const SizedBox(height: 10),
                    // Question text
                    Center(
                        child: SizedBox(
                            width: screenWidth * 0.8,
                            child: Text('¿En qué establecimiento se encuentra?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: screenWidth * 0.05,
                                    color: const Color(0xFF4F4F69),
                                    fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 50),
                    Consumer<HospitalesProvider>(
                        builder: (context, hospitalesProvider, child) {
                      hospitalesProvider.cargarHospitales();
                      if (hospitalesProvider.hospitales.isEmpty) {
                        return Column(children: [
                          Center(
                              child: SvgPicture.asset(
                                  'lib/assets/bg_empty_grid.svg',
                                  width: screenWidth * 0.7,
                                  height: screenHeight * 0.3,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFDCDCDC), BlendMode.srcIn))),
                          const SizedBox(height: 15),
                          Center(
                              child: Column(children: [
                            Text('Para añadir un establecimiento',
                                style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: screenWidth * 0.05,
                                    color: const Color(0xFF87888A),
                                    fontWeight: FontWeight.bold)),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Text("Presione ",
                                  style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: screenWidth * 0.04,
                                      color: const Color(0xFF87888A))),
                              Icon(Icons.add_location_alt_outlined,
                                  color: const Color(0xFF87888A),
                                  size: screenWidth * 0.04),
                              Text(" en la barra inferior.",
                                  style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: screenWidth * 0.04,
                                      color: const Color(0xFF87888A)))
                            ])
                          ]))
                        ]);
                      } else {
                        return Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Padding(
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.05),
                                  child: Text('Establecimientos',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "Lato",
                                          fontSize: screenWidth * 0.05,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF6A6870)))),
                              Expanded(
                                  child: ListView.builder(
                                      itemCount:
                                          hospitalesProvider.hospitales.length,
                                      itemBuilder: (context, index) {
                                        final hospital = hospitalesProvider
                                            .hospitales[index];
                                        return Column(children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: HospitalTile(
                                                  icon: Icons.local_hospital,
                                                  name: hospital[
                                                          'nombre_hospital'] ??
                                                      'Hospital desconocido',
                                                  onTap: () async {
                                                    final String server = hospital[
                                                            'nombre_servidor_local'] ??
                                                        '';
                                                    final String username =
                                                        hospital[
                                                                'user_local'] ??
                                                            '';
                                                    final String pass =
                                                        hospital[
                                                                'pass_local'] ??
                                                            '';
                                                    final String hospitalName =
                                                        hospital[
                                                                'nombre_hospital'] ??
                                                            '';

                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await prefs.setString(
                                                        'username', username);
                                                    await prefs.setString(
                                                        'hospital_name',
                                                        hospitalName);

                                                    // Usamos el AuthProvider para manejar login
                                                    context
                                                        .read<AuthProvider>()
                                                        .login(server, username,
                                                            pass, context);
                                                  })),
                                          const SizedBox(height: 10.0)
                                        ]);
                                      }))
                            ]));
                      }
                    })
                  ]))),
          const Expanded(child: SizedBox()),
          const Divider(height: 0, thickness: 1, color: Color(0xFFDCDCDC)),
          SizedBox(
              height: screenHeight * 0.1,
              child: GestureDetector(
                  onTap: () {
                    // Navegar a otra página cuando se presione el ícono
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SizedBox()));
                  },
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.01),
                          child: Column(children: [
                            Icon(Icons.add_location_alt_outlined,
                                color: const Color(0xFF727287),
                                size: screenHeight * 0.04),
                            const SizedBox(height: 5),
                            Text('Añadir',
                                style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: screenHeight * 0.01,
                                    color: const Color(0xFF727287))),
                            Text('establecimiento',
                                style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: screenHeight * 0.01,
                                    color: const Color(0xFF727287)))
                          ])))))
        ]));
  }
}
