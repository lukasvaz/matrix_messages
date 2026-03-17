import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matrix_messages/features/authentication/providers/auth_provider.dart';
import 'package:matrix_messages/ui/screens/rooms/rooms.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverCtrl = TextEditingController(text: 'localhost:8008');
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _serverCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;
    final server = _serverCtrl.text.trim();

    // Capture client synchronously from the tree
    final client = context.read<Client>();
    try {
      // Ensure homeserver is validated and set on the client
      try {
        await client.checkHomeserver(Uri.http(server));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid homeserver: ${e.toString()}')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final keyPrefix = '$user@${server}';

      final storedToken = prefs.getString('${keyPrefix}_accessToken');
      // If a stored access token exists, initialize the client from stored credentials
      if (storedToken != null && storedToken.isNotEmpty) {
        print("Found stored token for $keyPrefix, initializing client from stored credentials");
        final storedRefresh = prefs.getString('${keyPrefix}_refreshToken');
        final storedUserId = prefs.getString('${keyPrefix}_userId');
        final storedDeviceId = prefs.getString('${keyPrefix}_deviceId');
        final storedDeviceName = prefs.getString('${keyPrefix}_deviceName') ?? '';
        final expiresIso = prefs.getString('${keyPrefix}_accessTokenExpiresAt');
        DateTime? expiresAt;
        if (expiresIso != null && expiresIso.isNotEmpty) {
          try {
            expiresAt = DateTime.parse(expiresIso);
          } catch (_) {
            expiresAt = null;
          }
        }

        await client.init(
          newToken: storedToken,
          newTokenExpiresAt: expiresAt,
          newRefreshToken: storedRefresh,
          newUserID: storedUserId,
          newHomeserver: client.homeserver,
          newDeviceName: storedDeviceName,
          newDeviceID: storedDeviceId,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoomsSection()),
        );
        return;
      }

      // No stored token -> perform password login and persist result
      print("No stored token for $keyPrefix, performing password login");
      final loginResponse = await client.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: user),
        password: pass,
      );
      print("Login response: $loginResponse");
      // Persist relevant attributes into SharedPreferences
      await prefs.setString('${keyPrefix}_accessToken', loginResponse.accessToken);
      if (loginResponse.refreshToken != null) {
        await prefs.setString('${keyPrefix}_refreshToken', loginResponse.refreshToken!);
      }
      await prefs.setString('${keyPrefix}_userId', loginResponse.userId);
      await prefs.setString('${keyPrefix}_deviceId', loginResponse.deviceId);
      await prefs.setString('${keyPrefix}_deviceName', client.deviceName ?? '');

      if (loginResponse.expiresInMs != null) {
        final dt = DateTime.now().add(Duration(milliseconds: loginResponse.expiresInMs!));
        await prefs.setString('${keyPrefix}_accessTokenExpiresAt', dt.toIso8601String());
      }

      // If the widget was disposed while awaiting login, bail out.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoomsSection()),
      );
    } catch (e) {
      // Only show UI feedback if still mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((p) => p.loadingLogin);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _serverCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Homeserver (host)',
                    hintText: 'localhost:8008',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Homeserver required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username (localpart)',
                    hintText: 'lukas',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Username required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign in'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}