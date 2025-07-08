// lib/widgets/barcode_widget_tile.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class BarcodeWidgetTile extends StatelessWidget {
  final String data;
  final String label;

  const BarcodeWidgetTile({super.key, required this.data, required this.label});

  // --- FUNCIÓN DE GUARDADO CON LÓGICA DE PERMISOS MEJORADA ---
  Future<void> _saveBarcodeToGallery(
      GlobalKey key, String filename, BuildContext context) async {
    // 1. Solicitar permiso para acceder a la galería.
    // Este código le pide al usuario permiso para acceder a las fotos.
    // IMPORTANTE: Esto solo funciona si el permiso está declarado primero
    // en el archivo AndroidManifest.xml. Si no está declarado, el sistema
    // operativo denegará la solicitud automáticamente.
    final status = await Permission.photos.request();

    // 2. Evaluar la respuesta del usuario.
    if (status.isGranted) {
      // --- PERMISO CONCEDIDO ---
      // El usuario aceptó, por lo que procedemos a guardar la imagen.
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$filename.png';
        final File file = await File(filePath).writeAsBytes(pngBytes);

        await Gal.putImage(file.path, album: 'CodigosDeGalletas');

        await file.delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Guardado en la galería!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al guardar la imagen: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // --- PERMISO DENEGADO PERMANENTEMENTE ---
      // El usuario ha denegado el permiso varias veces y marcó "No volver a preguntar".
      // La única forma de habilitarlo ahora es manualmente desde los ajustes.
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permiso Requerido"),
            content: const Text(
                "Para guardar la imagen, la aplicación necesita acceso a tus fotos. Por favor, habilita el permiso en los ajustes del sistema."),
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
    } else if (status.isDenied) {
      // --- PERMISO DENEGADO ---
      // El usuario denegó el permiso esta vez, pero podría volver a pedirlo.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Permiso denegado. Es necesario para guardar la imagen."),
            backgroundColor: Colors.orange,
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








/*// lib/widgets/barcode_widget_tile.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

// --- Se cambia el import al nuevo paquete ---
import 'package:gal/gal.dart';

class BarcodeWidgetTile extends StatelessWidget {
  final String data;
  final String label;

  const BarcodeWidgetTile({super.key, required this.data, required this.label});

  // --- FUNCIÓN DE GUARDADO CORREGIDA ---
  Future<void> _saveBarcodeToGallery(
      GlobalKey key, String filename, BuildContext context) async {
    // 1. Solicitar permiso para acceder a la galería
    final status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        // 2. Capturar el widget como una imagen
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // 3. Guardar la imagen en un archivo temporal
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$filename.png';
        final File file = await File(filePath).writeAsBytes(pngBytes);

        // 4. Usar el paquete 'gal' para guardar el archivo en la galería
        // Se corrige el nombre del parámetro a 'album' y se elimina la asignación de resultado.
        await Gal.putImage(file.path, album: 'CodigosDeGalletas');

        // 5. Borrar el archivo temporal
        await file.delete();

        // 6. Si todo sale bien, mostrar mensaje de éxito
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Guardado en la galería!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // 7. Si ocurre un error en cualquier paso, mostrar un mensaje de error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al guardar la imagen: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // 8. Si el permiso es denegado, mostrar un diálogo para ir a los ajustes
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
*/


/*// lib/widgets/barcode_widget_tile.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class BarcodeWidgetTile extends StatelessWidget {
  final String data;
  final String label;

  const BarcodeWidgetTile({super.key, required this.data, required this.label});

  // --- FUNCIÓN DE GUARDADO CON LÓGICA DE PERMISOS MEJORADA ---
  Future<void> _saveBarcodeToGallery(
      GlobalKey key, String filename, BuildContext context) async {
    // 1. Solicitar permiso para acceder a la galería
    final status = await Permission.photos.request();

    // 2. Evaluar el estado del permiso
    if (status.isGranted) {
      // --- El permiso fue concedido, proceder a guardar ---
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$filename.png';
        final File file = await File(filePath).writeAsBytes(pngBytes);

        await Gal.putImage(file.path, album: 'CodigosDeGalletas');

        await file.delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Guardado en la galería!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al guardar la imagen: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // --- El permiso fue denegado permanentemente, enviar a ajustes ---
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permiso Requerido"),
            content: const Text(
                "Para guardar la imagen, la aplicación necesita acceso a tus fotos. Por favor, habilita el permiso en los ajustes del sistema."),
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
    } else if (status.isDenied) {
      // --- El permiso fue denegado, pero no permanentemente ---
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permiso denegado. Es necesario para guardar la imagen."),
            backgroundColor: Colors.orange,
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
}*/