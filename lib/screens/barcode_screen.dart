// lib/screens/barcode_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // 1. Importar el paquete de permisos
import '../providers/cookie_provider.dart';
import '../widgets/barcode_widget_tile.dart';

// 2. Convertir el widget a StatefulWidget para tener acceso al ciclo de vida (initState)
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  // 3. Usar initState para ejecutar código en cuanto la pantalla se crea
  @override
  void initState() {
    super.initState();
    // Se llama a la función para solicitar el permiso al iniciar la pantalla
    _requestStoragePermissionOnLoad();
  }

  // 4. Crear la función que pide el permiso de forma inteligente
  Future<void> _requestStoragePermissionOnLoad() async {
    // Primero, se comprueba el estado actual del permiso
    final status = await Permission.photos.status;

    // Si el permiso está denegado, pero no permanentemente, se pide al usuario.
    // Esta es la única situación donde el sistema mostrará el diálogo emergente.
    if (status.isDenied) {
      await Permission.photos.request();
    }
    // Si el permiso fue denegado permanentemente, se informa al usuario.
    else if (status.isPermanentlyDenied) {
      // Usamos 'mounted' para asegurarnos de que el widget todavía existe
      // antes de mostrar un diálogo.
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permiso Denegado Permanentemente"),
            content: const Text(
                "Has denegado el permiso para acceder a las fotos y seleccionado 'No volver a preguntar'.\n\nPara usar esta función, debes habilitar el permiso manualmente. Presiona 'Ir a Ajustes', busca la sección 'Permisos' y activa el acceso a 'Fotos y videos'."),
            actions: [
              TextButton(
                child: const Text("Entendido"),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text("Ir a Ajustes"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
    }
  }

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
