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
  String _currentCategoryId = 'shawarma';

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

// ── Order History (in-memory for admin dashboard) ──
final List<Map<String, dynamic>> orderHistory = [];

int get todayRevenue => _todayOrders.fold(0, (s, o) => s + (o['total'] as int));
int get todayOrderCount => _todayOrders.length;
int get todayItemsSold => _todayOrders.fold(0, (s, o) => s + (o['itemsCount'] as int));
double get avgOrderValue => todayOrderCount > 0 ? todayRevenue / todayOrderCount : 0;

List<Map<String, dynamic>> get _todayOrders => orderHistory.where((o) {
  final t = o['time'] as String;
  final now = DateTime.now();
  final todayPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return t.startsWith(todayPrefix);
}).toList();

final session = Session();
final kioskSession = KioskSession();
