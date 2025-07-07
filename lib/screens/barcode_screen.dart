// lib/screens/barcode_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cookie_provider.dart';
import '../widgets/barcode_widget_tile.dart';

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cookies = Provider.of<CookieProvider>(context).cookies;

    return Scaffold(
      appBar: AppBar(title: const Text("Generar Códigos de Barras")),
      body: cookies.isEmpty
          ? const Center(child: Text("Primero agrega un tipo de galleta."))
          : ListView.builder(
              itemCount: cookies.length,
              itemBuilder: (ctx, i) {
                final galleta = cookies[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.cookie,
                            size: 40,
                            color: Colors.brown,
                          ),
                          title: Text(
                            galleta.nombre,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          subtitle: Text(galleta.descripcion),
                        ),
                        const Divider(),
                        BarcodeWidgetTile(
                          data:
                              "PRODUCTO-${galleta.nombre.toUpperCase().replaceAll(' ', '-')}",
                          label: "Código General del Producto",
                        ),
                        BarcodeWidgetTile(
                          data:
                              "LOTE-${galleta.nombre.toUpperCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}",
                          label: "Código Único de Lote (Ejemplo)",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
