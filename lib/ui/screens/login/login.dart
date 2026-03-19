import 'package:flutter/material.dart';
import 'package:matrix_messages/features/init/stored_keys.dart';
import 'package:matrix_messages/ui/screens/rooms/rooms.dart';
import 'package:provider/provider.dart';
import 'package:matrix_messages/features/authentication/providers/auth_provider.dart';
import 'package:matrix/matrix.dart';

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
  late final Client _client = context.read<Client>();

  bool _obscure = true;

  @override
  void dispose() {
    _serverCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      final user = _userCtrl.text.trim();
      final pass = _passCtrl.text;
      final server = _serverCtrl.text.trim();

      try {
        await _client.checkHomeserver(Uri.http(server));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid homeserver: ${e.toString()}')),
        );
        return;
      }
      // No stored token -> perform password login and persist result
      final loginResponse = await _client.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: user),
        password: pass,
      );
      // Persist relevant attributes into SharedPreferences
      final prefKeys = StoredKeys(
        localpart: user, 
        homeserverHost: server,
        accessToken: loginResponse.accessToken, 
        refreshToken:loginResponse.refreshToken, 
        userId: loginResponse.userId,
        deviceId: loginResponse.deviceId,
        deviceName: _client.deviceName ?? '',
        expiresAt: loginResponse.expiresInMs != null ? DateTime.now().add(Duration(milliseconds: loginResponse.expiresInMs!)) : null,
      );
      await prefKeys.store();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const RoomsSection()),
      );
    }
    catch (e) {
      // Only show UI feedback if still mounted
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _client.isLogged() ? () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  const RoomsSection()),
                    );
                  } : _submit,
                  child: const Text('Sign in'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
 }
}