import 'package:matrix/matrix.dart';
import 'stored_keys.dart';

/// Try to initialize the provided [client] from stored keys. Returns bool
Future<bool> initializeFromPreferences(Client client) async {
  final keys = await getStoredKeys();
  if (keys == null) return false;
  try {
    final homeserverUri = Uri.http(keys.homeserverHost);

    client.checkHomeserver(homeserverUri);
    await client.init(
      newDeviceID: keys.deviceId,
      newToken: keys.accessToken,
      newRefreshToken: keys.refreshToken,
      newDeviceName: keys.deviceName,
      newHomeserver: homeserverUri
    );
    print("Initialized client from stored keys succesfull: ${keys.toString()}");
    return true;
  } catch (e) {
    print("Failed to initialize client from stored keys: ${e.toString()}");
    return false;
  }
}
