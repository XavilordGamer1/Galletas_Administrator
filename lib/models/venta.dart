// lib/models/venta.dart

class Venta {
  final String id;
  final String codigoEscaneado;
  final DateTime fecha;
  final bool esFiado;
  final String? nombreDeudor;

  Venta({
    required this.id,
    required this.codigoEscaneado,
    required this.fecha,
    this.esFiado = false,
    this.nombreDeudor,
  });
}
