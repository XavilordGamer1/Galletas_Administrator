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
  @override
  void initState() {
    super.initState();
    // Carga las ventas de forma segura después de que el widget se construya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VentasProvider>(context, listen: false).loadVentas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventasProvider = Provider.of<VentasProvider>(context);
    final cookieProvider = Provider.of<CookieProvider>(context, listen: false);
    final ventas = ventasProvider.ventas;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Ventas"),
        backgroundColor: Colors.brown,
      ),
      body: ventas.isEmpty
          ? const Center(child: Text("No hay ventas registradas."))
          : ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (ctx, i) {
                final venta = ventas[i];
                // Busca la galleta por su código. Si no la encuentra, muestra un texto alternativo.
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

                // Construye el texto del subtítulo dinámicamente.
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
                    isThreeLine: true, // Permite más espacio para el subtítulo
                    trailing: esDeudaPendiente
                        // Si es una deuda pendiente, muestra el botón para saldar.
                        ? TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                            onPressed: () {
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
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Saldar"),
                          )
                        // Si no es deuda, muestra una etiqueta de "Pagado".
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
            ),
    );
  }
}
