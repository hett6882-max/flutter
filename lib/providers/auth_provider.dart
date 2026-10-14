import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  User? _currentUser;
  bool _isLoading = true;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(AppConstants.keyCurrentUserId);
      if (id != null) {
        _currentUser = await _repo.findById(id);
        if (_currentUser == null) {
          await prefs.remove(AppConstants.keyCurrentUserId);
        }
      }
    } catch (_) {
      _currentUser = null;
    }
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _error = null;
    final user = await _repo.findByUsername(username);
    if (user == null) {
      _error = 'User not found';
      notifyListeners();
      return false;
    }
    final ok = await _repo.verifyPassword(user, password);
    if (!ok) {
      _error = 'Invalid password';
      notifyListeners();
      return false;
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentUserId, user.id);
    notifyListeners();
    return true;
  }

  Future<bool> signup(String username, String password, {String role = 'user'}) async {
    _error = null;
    final existing = await _repo.findByUsername(username);
    if (existing != null) {
      _error = 'Username already taken';
      notifyListeners();
      return false;
    }
    final user = await _repo.createUser(
        username: username, password: password, role: role);
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentUserId, user.id);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyCurrentUserId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
