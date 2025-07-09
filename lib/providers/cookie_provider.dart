import 'package:flutter/foundation.dart';
import '../models/cookie.dart';
import '../helpers/db_helper.dart';

class CookieProvider with ChangeNotifier {
  List<Cookie> _cookies = [];

  List<Cookie> get cookies {
    return [..._cookies];
  }

  /// Añade una galleta a la lista y la guarda en la base de datos.
  Future<void> addCookie(Cookie newCookie) async {
    _cookies.add(newCookie);
    // Notifica a los widgets para que se redibujen inmediatamente.
    notifyListeners();

    // Guarda el cambio en la base de datos en segundo plano.
    await DBHelper.insert('cookies', {
      'id': newCookie.id,
      'nombre': newCookie.nombre,
      'descripcion': newCookie.descripcion,
      'precio': newCookie.precio,
    });
  }

  /// Elimina una galleta de la lista y de la base de datos.
  Future<void> removeCookie(String id) async {
    _cookies.removeWhere((cookie) => cookie.id == id);
    notifyListeners();
    await DBHelper.delete('cookies', id);
  }

  /// Carga todas las galletas desde la base de datos al iniciar la app.
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
