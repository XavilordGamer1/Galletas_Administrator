import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/ventas_provider.dart';
import '../providers/cookie_provider.dart';
import '../models/venta.dart';
import '../models/cookie.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.code128, BarcodeFormat.ean13],
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  // --- CAMBIO: Se usa un nuevo patrón para cargar los datos ---
  late Future<void> _loadCookiesFuture;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    // --- CAMBIO: La carga de datos se mueve a didChangeDependencies ---
    // Este método se llama cuando el widget se inserta en el árbol, asegurando
    // que los datos se carguen cada vez que se entra a la pantalla.
    if (_isInit) {
      _loadCookiesFuture =
          Provider.of<CookieProvider>(context, listen: false).loadCookies();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final String? codigo = capture.barcodes.first.rawValue;
    if (codigo == null) return;

    final cookieProvider = Provider.of<CookieProvider>(context, listen: false);

    try {
      // Busca la galleta cuyo nombre formateado coincida con el código escaneado
      final cookie = cookieProvider.cookies.firstWhere((c) {
        final expectedCode =
            "PRODUCTO-${c.nombre.toUpperCase().replaceAll(' ', '-')}";
        return expectedCode == codigo;
      });

      setState(() {
        _isProcessing = true;
      });
      controller.stop();
      _mostrarDialogoVenta(cookie);
    } catch (e) {
      // Se ejecuta si no se encuentra ninguna galleta que coincida.
      _showInvalidCodeError();
    }
  }

  void _showInvalidCodeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Código de galleta no reconocido."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    _resumeCamera();
  }

  void _mostrarDialogoVenta(Cookie cookie) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Venta: ${cookie.nombre}'),
        content: Text('Precio: \$${cookie.precio.toStringAsFixed(2)}'),
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
              final nuevaVenta = Venta(
                id: DateTime.now().toIso8601String(),
                codigoEscaneado: cookie.id,
                fecha: DateTime.now(),
                esFiado: false,
              );
              Provider.of<VentasProvider>(context, listen: false)
                  .addVenta(nuevaVenta);
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
              _mostrarDialogoFiar(cookie);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoFiar(Cookie cookie) {
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
              final nuevaVenta = Venta(
                id: DateTime.now().toIso8601String(),
                codigoEscaneado: cookie.id,
                fecha: DateTime.now(),
                esFiado: true,
                nombreDeudor: deudorController.text,
              );
              Provider.of<VentasProvider>(context, listen: false)
                  .addVenta(nuevaVenta);
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        controller.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear para Vender"),
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: "Linterna",
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadCookiesFuture,
        builder: (context, snapshot) {
          // Mientras los datos están cargando, muestra un spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Cargando datos de galletas..."),
                ],
              ),
            );
          }

          // Si hubo un error cargando, muéstralo.
          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar: ${snapshot.error}"));
          }

          // Cuando los datos están listos, muestra el escáner.
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
              ),
              CustomPaint(
                painter: ScannerOverlay(
                    scanWindow: Rect.fromCenter(
                  center: MediaQuery.of(context).size.center(Offset.zero),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.25,
                )),
              ),
            ],
          );
        },
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
