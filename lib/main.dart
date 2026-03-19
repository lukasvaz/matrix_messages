import 'package:path_provider/path_provider.dart';
import 'package:matrix_messages/ui/screens/login/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'features/init/init.dart';
import 'ui/screens/rooms/rooms.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbDirectory = await getApplicationSupportDirectory();
  final client= Client('matrix client', database: await MatrixSdkDatabase.init(
      "Matrix SDK database",
      database:
          await sqlite.openDatabase("${dbDirectory.path}/matrix_sdk.db"),
    ), );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp(client: client));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.client});
  final Client client;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<Client>(create: (context) => client)],
        child: MaterialApp(
            builder: (context, child) => child!,
            debugShowCheckedModeBanner: false,
            home: 
            // dispatching matrix init logic
            FutureBuilder(future: initializeFromPreferences(client),
             builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: SnackBar(content: Text('Error initializing client: ${snapshot.error}')),
                );
              } else if (snapshot.data == true || client.isLogged()) {
                return const RoomsSection();
              } else {
                return const LoginPage();
              }
            })));
  }
}
