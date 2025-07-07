// lib/screens/scan_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/ventas_provider.dart';
import '../providers/cookie_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Simplemente eliminamos el parámetro "resolution" que causaba el error.
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.code128, BarcodeFormat.ean13],
  );

  bool isProcessing = false;
  bool isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final String? codigo = capture.barcodes.first.rawValue;
    if (codigo == null) return;

    final validCodes = _getValidProductCodes(context);

    if (validCodes.contains(codigo)) {
      setState(() {
        isProcessing = true;
      });
      controller.stop();
      _mostrarDialogoVenta(codigo);
    } else {
      _showInvalidCodeError();
    }
  }

  List<String> _getValidProductCodes(BuildContext context) {
    final cookieProvider = Provider.of<CookieProvider>(context, listen: false);
    return cookieProvider.cookies.map((cookie) {
      return "PRODUCTO-${cookie.nombre.toUpperCase().replaceAll(' ', '-')}";
    }).toList();
  }

  void _showInvalidCodeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Código no reconocido."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _mostrarDialogoVenta(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Venta'),
        content: Text('Código escaneado:\n$codigo'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeCamera();
            },
          ),
          ElevatedButton(
            child: const Text('De Contado'),
            onPressed: () {
              Provider.of<VentasProvider>(context, listen: false)
                  .registrarVenta(codigo);
              Navigator.of(ctx).pop();
              _showSuccessAndResume('Venta de contado registrada.');
            },
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
            child: const Text('Fiar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _mostrarDialogoFiar(codigo);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoFiar(String codigo) {
    final deudorController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Venta Fiada'),
        content: TextField(
          controller: deudorController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del cliente'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeCamera();
            },
          ),
          ElevatedButton(
            child: const Text('Guardar Deuda'),
            onPressed: () {
              if (deudorController.text.isEmpty) return;
              Provider.of<VentasProvider>(context, listen: false)
                  .registrarVenta(
                codigo,
                esFiado: true,
                deudor: deudorController.text,
              );
              Navigator.of(ctx).pop();
              _showSuccessAndResume(
                  'Venta fiada a ${deudorController.text} registrada.');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessAndResume(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    _resumeCamera();
  }

  void _resumeCamera() {
    setState(() {
      isProcessing = false;
    });
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanWindow = Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: screenSize.width * 0.9,
      height: screenSize.height * 0.25,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear para Vender"),
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                isTorchOn = !isTorchOn;
              });
            },
            icon: Icon(isTorchOn ? Icons.flash_off : Icons.flash_on),
            tooltip: "Linterna",
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),
          CustomPaint(
            painter: ScannerOverlay(scanWindow: scanWindow),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({required this.scanWindow});

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(
            RRect.fromRectAndRadius(scanWindow, const Radius.circular(8)))
        ..close(),
    );
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(backgroundPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(8)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
