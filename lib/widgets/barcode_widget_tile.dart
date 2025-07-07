// lib/widgets/barcode_widget_tile.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// --- Se cambia el import al nuevo paquete ---
import 'package:gallery_saver/gallery_saver.dart';

class BarcodeWidgetTile extends StatelessWidget {
  final String data;
  final String label;

  const BarcodeWidgetTile({super.key, required this.data, required this.label});

  // --- Se actualiza toda la función para usar gallery_saver ---
  Future<void> _saveBarcodeToGallery(
      GlobalKey key, String filename, BuildContext context) async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List pngBytes = byteData!.buffer.asUint8List();

        // --- LÓGICA DE GUARDADO ACTUALIZADA ---
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$filename.png';
        final File file = await File(filePath).writeAsBytes(pngBytes);

        final bool? success = await GallerySaver.saveImage(file.path,
            albumName: 'CodigosDeGalletas');

        await file.delete();

        if (context.mounted) {
          if (success ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Guardado en la galería!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error: No se pudo guardar en la galería."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error al generar la imagen: $e")));
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permiso Requerido"),
            content: const Text(
                "Para guardar la imagen, la aplicación necesita acceso a tus fotos. Por favor, habilita el permiso en los ajustes."),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
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
    final key = GlobalKey();
    final filename = data.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RepaintBoundary(
            key: key,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: BarcodeWidget(
                data: data,
                barcode: Barcode.code128(),
                width: 250,
                height: 80,
                drawText: false,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(data, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text("Guardar en Galería"),
            onPressed: () => _saveBarcodeToGallery(key, filename, context),
          ),
        ],
      ),
    );
  }
}
