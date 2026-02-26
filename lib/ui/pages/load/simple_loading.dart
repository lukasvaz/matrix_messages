// import 'dart:nativewrappers/_internal/vm_shared/lib/null_patch.dart';
import 'package:matrix_messages/providers/load_hospitals_provider.dart';
// import 'package:matrix_messages/ui/pages/hospitals/hospitals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_messages/ui/pages/profile/profile.dart';
import 'package:matrix_messages/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LoadLahuen extends StatefulWidget {
  const LoadLahuen({super.key});

  @override
  LoadLahuenState createState() => LoadLahuenState();
}

class LoadLahuenState extends State<LoadLahuen> {
  @override
  void initState() {
    super.initState();
    // Llamamos a la función para cargar los hospitales y navegar según el número de hospitales
    _loadHospitalsAndNavigate();
  }

  // Función para cargar hospitales y redirigir dependiendo de la cantidad
  Future<void> _loadHospitalsAndNavigate() async {
    // Llamamos al LoadHospitalsProvider para cargar los hospitales
    await context.read<HospitalesProvider>().cargarHospitales();

    if (mounted) {
      // Verificamos la cantidad de hospitales cargados
      final hospitalesProvider = context.read<HospitalesProvider>();
      if (hospitalesProvider.hospitales.length == 1) {
        // Si hay un solo hospital ingresamos directamente a él
        Future.delayed(const Duration(seconds: 2), () async {
          final hospital = hospitalesProvider.hospitales[0];
          final String server = hospital['nombre_servidor_local'] ?? '';
          final String username = hospital['user_local'] ?? '';
          final String pass = hospital['pass_local'] ?? '';
          final String hospitalName = hospital['nombre_hospital'] ?? '';

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'username', username); // Guardar el nombre de usuario
          await prefs.setString('hospital_name', hospitalName);

          if (mounted) {
            // Realizamos el login con las credenciales del hospital
            await context
                .read<AuthProvider>()
                .login(server, username, pass, context);
          }

          // Navegamos a ProfilePage después del login
          _navigateToProfile();
        });
      } 
    }
  }

  // Función para navegar directamente a ProfilePage
  void _navigateToProfile() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF2F2F4),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Image.asset('lib/assets/logo-lahuen.png', width: 250)
            ])));
  }
}
