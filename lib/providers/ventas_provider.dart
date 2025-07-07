// lib/providers/ventas_provider.dart

import 'package:flutter/material.dart';
import '../models/venta.dart';

class VentasProvider with ChangeNotifier {
  final List<Venta> _ventas = [];
  List<Venta> get ventas => [..._ventas];

  void registrarVenta(String codigo, {bool esFiado = false, String? deudor}) {
    final nuevaVenta = Venta(
      id: DateTime.now().toIso8601String(),
      codigoEscaneado: codigo,
      fecha: DateTime.now(),
      esFiado: esFiado,
      nombreDeudor: deudor,
    );
    _ventas.add(nuevaVenta);
    notifyListeners();
  }
}
