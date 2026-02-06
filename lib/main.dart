import 'package:matrix_messages/providers/load_hospitals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_messages/ui/pages/load/load_lahuen.dart';
import 'package:matrix_messages/ui/pages/profile/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/matrix/client_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'package:matrix/matrix.dart';

main() async {
  // await dotenv.load(fileName: ".env");
  final client = await initializeMatrixClient();
  final user = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getString('username'));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp(client: client, user: user));
  });
}

class MyApp extends StatelessWidget {
  final Client client;
  final String? user;
  const MyApp({required this.client, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<Client>(create: (context) => client),
          Provider<String?>(create: (context) => user),
          ChangeNotifierProvider(create: (context) => HospitalesProvider()),
          ChangeNotifierProvider(create: (context) => AuthProvider())
        ],
        child: MaterialApp(
            builder: (context, child) => child!,
            debugShowCheckedModeBanner: false,
            home: const ProfilePage()));
  }
}
