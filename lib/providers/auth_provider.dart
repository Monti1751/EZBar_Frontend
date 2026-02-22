import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String _roleKey = 'user_role';
  String _role = 'usuario'; // Default a usuario normal por seguridad

  String get role => _role;
  bool get isAdmin =>
      _role.toLowerCase() == 'admin' || _role.toLowerCase() == 'administrador';

  AuthProvider() {
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString(_roleKey) ?? 'usuario';
    notifyListeners();
  }

  Future<void> setRole(String newRole) async {
    _role = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, _role);
    notifyListeners();
  }

  Future<void> logout() async {
    _role = 'usuario';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    notifyListeners();
  }
}
