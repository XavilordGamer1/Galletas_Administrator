import 'package:flutter/foundation.dart';
import '../models/venta.dart';
import '../helpers/db_helper.dart';

class VentasProvider with ChangeNotifier {
  List<Venta> _ventas = [];

  List<Venta> get ventas {
    // Ordena las ventas de la más reciente a la más antigua.
    _ventas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return [..._ventas];
  }

  /// Registra una nueva venta en la lista y en la base de datos.
  Future<void> addVenta(Venta newVenta) async {
    _ventas.add(newVenta);
    notifyListeners();
    await DBHelper.insert('ventas', {
      'id': newVenta.id,
      'codigoEscaneado': newVenta.codigoEscaneado,
      'fecha': newVenta.fecha.toIso8601String(),
      'esFiado':
          newVenta.esFiado ? 1 : 0, // SQLite usa 1 para true, 0 para false
      'nombreDeudor': newVenta.nombreDeudor,
      'fechaPago': newVenta.fechaPago?.toIso8601String(), // Puede ser nulo
    });
  }

  /// Carga todas las ventas desde la base de datos.
  Future<void> loadVentas() async {
    final dataList = await DBHelper.getData('ventas');
    _ventas = dataList
        .map(
          (item) => Venta(
            id: item['id'],
            codigoEscaneado: item['codigoEscaneado'],
            fecha: DateTime.parse(item['fecha']),
            esFiado:
                item['esFiado'] == 1, // Convierte el entero de la BD a booleano
            nombreDeudor: item['nombreDeudor'],
            fechaPago: item['fechaPago'] != null
                ? DateTime.parse(item['fechaPago'])
                : null,
          ),
        )
        .toList();
    notifyListeners();
  }

  /// Cambia el estado de una venta a "pagado" y guarda la fecha del pago.
  Future<void> saldarDeuda(String ventaId) async {
    final ventaIndex = _ventas.indexWhere((venta) => venta.id == ventaId);
    if (ventaIndex >= 0) {
      final now = DateTime.now();
      _ventas[ventaIndex].esFiado = false;
      _ventas[ventaIndex].fechaPago = now;
      notifyListeners();

      // Actualiza solo los campos necesarios en la base de datos.
      await DBHelper.update('ventas', ventaId, {
        'esFiado': 0,
        'fechaPago': now.toIso8601String(),
      });
    }
  }
}
