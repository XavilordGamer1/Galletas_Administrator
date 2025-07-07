// lib/screens/report_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ventas_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ventas = Provider.of<VentasProvider>(context).ventas;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Ventas del Día"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            onPressed: () {
              // TODO: Implementar lógica para exportar a Excel/CSV
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("La exportación se implementará pronto."),
                ),
              );
            },
          ),
        ],
      ),
      body: ventas.isEmpty
          ? const Center(child: Text("No se han registrado ventas hoy."))
          : ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (ctx, i) {
                final venta = ventas[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  color: venta.esFiado ? Colors.orange[100] : Colors.green[100],
                  child: ListTile(
                    leading: Icon(
                      venta.esFiado ? Icons.person_pin : Icons.paid,
                      size: 30,
                    ),
                    title: Text(
                      venta.esFiado
                          ? "Fiado a: ${venta.nombreDeudor}"
                          : "Venta de Contado",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Código: ${venta.codigoEscaneado}"),
                    trailing: Text(
                      "${venta.fecha.hour}:${venta.fecha.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
