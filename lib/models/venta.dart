/// Representa una única transacción de venta con el nuevo modelo.
class Venta {
  final String id;
  final String codigoEscaneado;
  final DateTime fecha;
  bool
      esFiado; // CAMBIO: Se quitó 'final' para poder modificarlo al saldar la deuda.
  final String? nombreDeudor;
  DateTime? fechaPago; // NUEVO: Almacena la fecha en que se pagó la deuda.

  Venta({
    required this.id,
    required this.codigoEscaneado,
    required this.fecha,
    this.esFiado = false,
    this.nombreDeudor,
    this.fechaPago, // Se añade al constructor.
  });
}
