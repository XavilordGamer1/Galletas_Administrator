import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'cookie_screen.dart'; // La de solo lectura
import 'manage_cookies_screen.dart'; // La nueva pantalla para editar
import 'barcode_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Control"),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
        label: const Text('Escanear'),
        icon: const Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _HomeCard(
            icon: Icons.cookie,
            label: "Tipos de Galleta",
            // Navega a la pantalla de SOLO LECTURA
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CookieScreen()),
            ),
          ),
          _HomeCard(
            icon: Icons.qr_code_2,
            label: "Generar Códigos",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BarcodeScreen()),
            ),
          ),
          _HomeCard(
            icon: Icons.assessment,
            label: "Reporte de Ventas",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
          ),
          _HomeCard(
            icon: Icons.settings,
            label: "Configuración",
            // Navega a la nueva pantalla para GESTIONAR y EDITAR
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCookiesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.brown.shade700),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
