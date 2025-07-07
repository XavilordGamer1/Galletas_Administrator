import 'package:flutter/material.dart';
// --- CORRECCIÓN APLICADA AQUÍ ---
// Se cambió la ruta del import para que sea relativa, ya que ambos
// archivos están en la misma carpeta 'screens'.
import '../screens/scan_screen.dart';
import '../services/barcode_service.dart';

// 1. Clase con el nombre corregido a "MenuCardData"
class MenuCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  MenuCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Actualiza el tipo de la lista
    final List<MenuCardData> cardData = [
      // 3. Actualiza el nombre del constructor
      MenuCardData(
        title: 'Ver Códigos Generados',
        subtitle: 'Visualiza y gestiona los códigos de barras de tus galletas',
        icon: Icons.view_list,
        onTap: () {
          // Lógica para ver códigos generados
        },
      ),
      MenuCardData(
        title: 'Escanear Código',
        subtitle: 'Escanea un código de barras para identificar una galleta',
        icon: Icons.qr_code_scanner,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ScanScreen(),
          ));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Códigos de Barras'),
      ),
      body: ListView.builder(
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          final card = cardData[index];
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(card.icon, size: 40, color: Colors.brown),
              title: Text(card.title),
              subtitle: Text(card.subtitle),
              onTap: card.onTap,
            ),
          );
        },
      ),
    );
  }
}
