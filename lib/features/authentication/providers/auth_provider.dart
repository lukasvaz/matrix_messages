import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart'; // Importa la biblioteca Matrix
import 'package:provider/provider.dart';
import 'package:matrix_messages/ui/screens/profile/profile.dart';
import 'package:matrix_messages/ui/screens/error/error_page.dart';

class AuthProvider extends ChangeNotifier {
  bool _loadingLogin = false;
  bool _loadingLogout = false;

  bool get loadingLogin => _loadingLogin;
  bool get loadingLogout => _loadingLogout;

  // Función para iniciar sesión
  Future<void> login(String server, String user, String pass, BuildContext context) async {
    _loadingLogin = true;
    notifyListeners();
    try {
      final client = context.read<Client>();    
      if (client.isLogged()) {
        _loadingLogin = false;
        notifyListeners();
        _changePage(context);
        return;
      }
      await client.checkHomeserver(Uri.http(server));
      await client.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: user),
        password: pass,
      );

      // Si la autenticación es exitosa, navegamos a la siguiente página
      if (_loadingLogin) {
        _loadingLogin = false;
        notifyListeners();
        _changePage(context);
      }
    } catch (e) {
      _loadingLogin = false;
      notifyListeners();
      _showError(context, e.toString());
    }
  }

  // Función para cerrar sesión
  Future<void> logout(BuildContext context) async {
    _loadingLogout = true;
    notifyListeners();

    final client = context.read<Client>();
    if (!client.isLogged()) {
      _loadingLogout = false;
      notifyListeners();
      return;
    }

    await client.logout();

    _loadingLogout = false;
    notifyListeners();
  }

  // Navegar a la página de perfil
  void _changePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  // Mostrar error en la página de error
  void _showError(BuildContext context, String error) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorPage(data: error),
      ),
    );
  }
}
