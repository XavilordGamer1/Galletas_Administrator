import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ventas_provider.dart';
import '../providers/cookie_provider.dart';
import '../models/cookie.dart';
import '../models/venta.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // CAMBIO: Se crea un Future para controlar el estado de carga.
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    // CAMBIO: Se asigna el Future que cargará ambos providers.
    // listen:false aquí es crucial para no causar reconstrucciones innecesarias.
    _loadDataFuture = _loadData(context);
  }

  // CAMBIO: Nueva función para agrupar las cargas de datos.
  Future<void> _loadData(BuildContext context) async {
    // Usamos Future.wait para esperar a que ambas cargas terminen.
    await Future.wait([
      Provider.of<VentasProvider>(context, listen: false).loadVentas(),
      Provider.of<CookieProvider>(context, listen: false).loadCookies(),
    ]);
  }

  void _showSaldarDeudaDialog(
      BuildContext context, Venta venta, Cookie cookie) {
    final ventasProvider = Provider.of<VentasProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text("Confirmar Pago"),
        content: Text(
            "¿Confirmas que la deuda de ${cookie.nombre} (${venta.nombreDeudor ?? 'N/A'}) ha sido pagada?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(dCtx).pop(),
          ),
          ElevatedButton(
            child: const Text("Sí, Saldar"),
            onPressed: () {
              ventasProvider.saldarDeuda(venta.id);
              Navigator.of(dCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deuda saldada con éxito.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Ventas"),
        backgroundColor: Colors.brown,
      ),
      // CAMBIO: Se envuelve el cuerpo en un FutureBuilder.
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          // Mientras los datos cargan, muestra un indicador de progreso.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hay un error, lo muestra.
          if (snapshot.hasError) {
            return Center(
                child: Text("Error al cargar los datos: ${snapshot.error}"));
          }

          // Cuando los datos están listos, construye la lista.
          // Se usa un Consumer para que la lista se actualice si hay cambios (ej: al saldar).
          return Consumer<VentasProvider>(
            builder: (ctx, ventasProvider, child) {
              final cookieProvider =
                  Provider.of<CookieProvider>(ctx, listen: false);
              final ventas = ventasProvider.ventas;

              if (ventas.isEmpty) {
                return const Center(child: Text("No hay ventas registradas."));
              }

              return ListView.builder(
                itemCount: ventas.length,
                itemBuilder: (ctx, i) {
                  final venta = ventas[i];
                  final cookie = cookieProvider.cookies.firstWhere(
                    (c) => c.id == venta.codigoEscaneado,
                    orElse: () => Cookie(
                        id: 'not-found',
                        nombre: 'Galleta no encontrada',
                        precio: 0.0,
                        descripcion: ''),
                  );

                  final bool esDeudaPendiente = venta.esFiado;
                  final Color colorVenta = esDeudaPendiente
                      ? Colors.orange.shade700
                      : Colors.green.shade700;

                  String subtitleText =
                      'Venta: ${DateFormat('dd/MM/yyyy - hh:mm a').format(venta.fecha)}';
                  if (venta.nombreDeudor != null &&
                      venta.nombreDeudor!.isNotEmpty) {
                    subtitleText += '\nDeudor: ${venta.nombreDeudor}';
                  }
                  if (!esDeudaPendiente && venta.fechaPago != null) {
                    subtitleText +=
                        '\nPagado: ${DateFormat('dd/MM/yyyy - hh:mm a').format(venta.fechaPago!)}';
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorVenta,
                        child: Icon(
                            esDeudaPendiente
                                ? Icons.credit_score
                                : Icons.price_check,
                            color: Colors.white),
                      ),
                      title: Text(
                        cookie.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(subtitleText),
                      isThreeLine: true,
                      trailing: esDeudaPendiente
                          ? TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                              ),
                              onPressed: () => _showSaldarDeudaDialog(
                                  context, venta, cookie),
                              child: const Text("Saldar"),
                            )
                          : const Chip(
                              label: Text(
                                "Pagado",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
