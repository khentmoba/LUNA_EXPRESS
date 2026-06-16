import 'package:flutter/material.dart';

class Session extends ChangeNotifier {
  String? _username;
  bool get isStaff => _username != null;
  String get username => _username ?? '';

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}

enum DiningMode { eatIn, takeOut }

class KioskSession extends ChangeNotifier {
  DiningMode? _diningMode;
  String _currentCategoryId = 'shawarma'; // Default to first category

  DiningMode? get diningMode => _diningMode;
  String get currentCategoryId => _currentCategoryId;

  void setDiningMode(DiningMode mode) {
    _diningMode = mode;
    notifyListeners();
  }

  void setCategory(String categoryId) {
    _currentCategoryId = categoryId;
    notifyListeners();
  }

  void reset() {
    _diningMode = null;
    _currentCategoryId = 'shawarma';
    notifyListeners();
  }
}

final session = Session();
final kioskSession = KioskSession();
