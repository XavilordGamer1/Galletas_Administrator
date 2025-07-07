// lib/providers/cookie_provider.dart

import 'package:flutter/material.dart';
import '../models/cookie.dart';

class CookieProvider with ChangeNotifier {
  final List<Cookie> _cookies = [];
  List<Cookie> get cookies => [..._cookies];

  void addCookie(Cookie cookie) {
    _cookies.add(cookie);
    notifyListeners();
  }

  void removeCookie(String id) {
    _cookies.removeWhere((cookie) => cookie.id == id);
    notifyListeners();
  }
}
