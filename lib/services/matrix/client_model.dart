import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

Future<Client> initializeMatrixClient() async {
  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/database.sqlite';
      final db = MatrixSdkDatabase(
        'MatrixExampleDB',
        database: await sqlite.openDatabase(path),
      );
      await db.open();
      return db;
    },
  );
  await client.init();
  return client;
}
