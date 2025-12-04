import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserId => _currentUser?.id;

  bool login(String username, String password) {
    final user = MockDataService.validateLogin(username, password);

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
