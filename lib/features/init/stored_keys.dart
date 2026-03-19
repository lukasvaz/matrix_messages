import 'package:shared_preferences/shared_preferences.dart';

/// A small value object representing the stored session keys in SharedPreferences.
class StoredKeys {
  final String localpart; 
  final String homeserverHost;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String userId; 
  final String deviceId;
  final String deviceName;

  StoredKeys({
    required this.localpart,
    required this.homeserverHost,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    required this.userId,
    required this.deviceId,
    this.deviceName = '',
  });

  String get keyPrefix => '$localpart@$homeserverHost';

  /// Persist this StoredKeys into SharedPreferences under namespaced keys.
  Future<void> store() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${keyPrefix}_accessToken', accessToken);
    if (refreshToken != null) await prefs.setString('${keyPrefix}_refreshToken', refreshToken!);
    await prefs.setString('${keyPrefix}_userId', userId);
    await prefs.setString('${keyPrefix}_deviceId', deviceId);
    await prefs.setString('${keyPrefix}_deviceName', deviceName);
    await prefs.setString('${keyPrefix}_homeserverHost', homeserverHost);
    await prefs.setString('${keyPrefix}_localpart', localpart);
    if (expiresAt != null) await prefs.setString('${keyPrefix}_accessTokenExpiresAt', expiresAt!.toIso8601String());
  }

  /// Remove persisted keys for this prefix.
  Future<void> remove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${keyPrefix}_accessToken');
    await prefs.remove('${keyPrefix}_refreshToken');
    await prefs.remove('${keyPrefix}_expiresAt');
    await prefs.remove('${keyPrefix}_userId');
    await prefs.remove('${keyPrefix}_deviceId');
    await prefs.remove('${keyPrefix}_deviceName');
  }

  @override
  String toString() => 'StoredKeys($keyPrefix)';
}

/// Returns true if any stored access token key exists in SharedPreferences.
Future<bool> hasStoredKeys() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getKeys().any((k) => k.endsWith('_accessToken'));
}

/// Reads the first stored keys entry from SharedPreferences and returns a
/// [StoredKeys] instance or null if none found.
Future<StoredKeys?> getStoredKeys() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final tokenKey = keys.firstWhere((k) => k.endsWith('_accessToken'), orElse: () => '');
  if (tokenKey.isEmpty) return null;
  final keyPrefix = tokenKey.replaceFirst('_accessToken', '');
  final parts = keyPrefix.split('@');
  if (parts.length < 2) return null;
  final localpart = parts.first;
  final host = parts.sublist(1).join('@');

  final accessToken = prefs.getString('${keyPrefix}_accessToken');
  final refreshToken = prefs.getString('${keyPrefix}_refreshToken');
  final userId = prefs.getString('${keyPrefix}_userId');
  final deviceId = prefs.getString('${keyPrefix}_deviceId');
  final deviceName = prefs.getString('${keyPrefix}_deviceName') ?? '';
  final expiresAt = prefs.getString('${keyPrefix}_accessTokenExpiresAt') != null
      ? DateTime.parse(prefs.getString('${keyPrefix}_accessTokenExpiresAt')!)
      : null;
      
  if (accessToken == null || userId == null || deviceId == null) return null;

  return StoredKeys(
    localpart: localpart,
    homeserverHost: host,
    accessToken: accessToken,
    refreshToken: refreshToken,
    userId: userId,
    deviceId: deviceId,
    deviceName: deviceName,
    expiresAt: expiresAt,
  );
}

/// Persist a StoredKeys instance into preferences.
Future<void> storeKeys(StoredKeys keys) => keys.store();

/// Overwrite any existing stored keys for the same prefix with the provided keys.
/// This removes previous values for the prefix and writes the new values.
Future<void> overwriteStoredKeys(StoredKeys keys) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('${keys.keyPrefix}_accessToken');
  await prefs.remove('${keys.keyPrefix}_refreshToken');
  await prefs.remove('${keys.keyPrefix}_userId');
  await prefs.remove('${keys.keyPrefix}_deviceId');
  await prefs.remove('${keys.keyPrefix}_deviceName');
  await prefs.remove('${keys.keyPrefix}_expiresAt');
  // Now store the new keys
  await keys.store();
}

