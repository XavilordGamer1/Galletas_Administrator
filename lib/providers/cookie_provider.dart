import 'package:flutter/foundation.dart';
import '../models/cookie.dart';
import '../helpers/db_helper.dart';

class CookieProvider with ChangeNotifier {
  List<Cookie> _cookies = [];

  List<Cookie> get cookies {
    return [..._cookies];
  }

  Future<void> addCookie(Cookie newCookie) async {
    _cookies.add(newCookie);
    notifyListeners();
    await DBHelper.insert('cookies', {
      'id': newCookie.id,
      'nombre': newCookie.nombre,
      'descripcion': newCookie.descripcion,
      'precio': newCookie.precio,
    });
  }

  Future<void> removeCookie(String id) async {
    _cookies.removeWhere((cookie) => cookie.id == id);
    notifyListeners();
    await DBHelper.delete('cookies', id);
  }

  /// --- NUEVO MÉTODO PARA ACTUALIZAR ---
  /// Actualiza una galleta en la lista y en la base de datos.
  Future<void> updateCookie(String id, Cookie updatedCookie) async {
    final cookieIndex = _cookies.indexWhere((cookie) => cookie.id == id);
    if (cookieIndex >= 0) {
      _cookies[cookieIndex] = updatedCookie;
      notifyListeners();
      await DBHelper.update('cookies', id, {
        'id': updatedCookie.id,
        'nombre': updatedCookie.nombre,
        'descripcion': updatedCookie.descripcion,
        'precio': updatedCookie.precio,
      });
    }
  }

  Future<void> loadCookies() async {
    final dataList = await DBHelper.getData('cookies');
    _cookies = dataList
        .map(
          (item) => Cookie(
            id: item['id'],
            nombre: item['nombre'],
            descripcion: item['descripcion'],
            precio: item['precio'],
          ),
        )
        .toList();
    notifyListeners();
  }
}
