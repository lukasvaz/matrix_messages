import 'package:matrix_messages/providers/load_hospitals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_messages/ui/screens/load/load_lahuen.dart';
import 'package:matrix_messages/ui/screens/login/login.dart';
import 'package:matrix_messages/ui/screens/profile/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:matrix_messages/features/authentication/providers/auth_provider.dart';
import 'package:matrix/matrix.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<Client>(create: (context) => Client('matrix client')),
          ChangeNotifierProvider<HospitalesProvider>(create: (context) => HospitalesProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider())
        ],
        child: MaterialApp(
            builder: (context, child) => child!,
            debugShowCheckedModeBanner: false,
            home: const LoginPage()));
  }
}
