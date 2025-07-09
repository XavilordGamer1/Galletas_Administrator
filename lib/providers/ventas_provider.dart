import 'package:flutter/material.dart';
import '../models/venta.dart';
import '../helpers/db_helper.dart';
import '../services/notification_service.dart'; // <-- AÑADIDO

class VentasProvider with ChangeNotifier {
  List<Venta> _ventas = [];
  final NotificationService _notificationService =
      NotificationService(); // <-- AÑADIDO

  List<Venta> get ventas {
    _ventas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return [..._ventas];
  }

  /// Registra una nueva venta y actualiza las notificaciones.
  Future<void> addVenta(Venta newVenta) async {
    _ventas.add(newVenta);
    notifyListeners();
    await DBHelper.insert('ventas', {
      'id': newVenta.id,
      'codigoEscaneado': newVenta.codigoEscaneado,
      'fecha': newVenta.fecha.toIso8601String(),
      'esFiado': newVenta.esFiado ? 1 : 0,
      'nombreDeudor': newVenta.nombreDeudor,
      'fechaPago': newVenta.fechaPago?.toIso8601String(),
    });
    // CAMBIO: Vuelve a programar las notificaciones si se añade una nueva deuda.
    await scheduleDebtNotifications();
  }

  /// Carga las ventas y programa las notificaciones para las deudas pendientes.
  Future<void> loadVentas() async {
    final dataList = await DBHelper.getData('ventas');
    _ventas = dataList
        .map(
          (item) => Venta(
            id: item['id'],
            codigoEscaneado: item['codigoEscaneado'],
            fecha: DateTime.parse(item['fecha']),
            esFiado: item['esFiado'] == 1,
            nombreDeudor: item['nombreDeudor'],
            fechaPago: item['fechaPago'] != null
                ? DateTime.parse(item['fechaPago'])
                : null,
          ),
        )
        .toList();
    notifyListeners();
    // CAMBIO: Programa las notificaciones para las deudas cargadas.
    await scheduleDebtNotifications();
  }

  /// Cambia el estado de una venta a "pagado" y cancela su notificación.
  Future<void> saldarDeuda(String ventaId) async {
    final ventaIndex = _ventas.indexWhere((venta) => venta.id == ventaId);
    if (ventaIndex >= 0) {
      final now = DateTime.now();
      _ventas[ventaIndex].esFiado = false;
      _ventas[ventaIndex].fechaPago = now;
      notifyListeners();

      // CAMBIO: Cancela la notificación específica de esta deuda.
      // Se usa el hashCode del ID de la venta para tener un ID de notificación único.
      await _notificationService.cancelNotification(ventaId.hashCode);

      await DBHelper.update('ventas', ventaId, {
        'esFiado': 0,
        'fechaPago': now.toIso8601String(),
      });
    }
  }

  /// (NUEVO) Revisa todas las deudas pendientes y programa un recordatorio diario para cada una.
  Future<void> scheduleDebtNotifications() async {
    // Primero, cancela todas las notificaciones existentes para evitar duplicados.
    await _notificationService.cancelAllNotifications();

    // Filtra para obtener solo las deudas pendientes.
    final pendingDebts = _ventas.where((venta) => venta.esFiado).toList();

    for (final debt in pendingDebts) {
      await _notificationService.scheduleDailyNotification(
        // Se usa el hashCode del ID de la venta para que cada notificación tenga un ID entero único.
        id: debt.id.hashCode,
        title: 'Recordatorio de Cobro',
        body:
            'Recuerda cobrar la deuda a ${debt.nombreDeudor ?? "un cliente"}.',
        // La notificación se enviará todos los días a las 9:00 AM.
        time: const TimeOfDay(hour: 9, minute: 0),
      );
    }
  }
}
