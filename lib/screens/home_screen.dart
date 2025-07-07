// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'cookie_screen.dart';
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
      // --- CAMBIO: El botón de escanear ahora es un FloatingActionButton ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
        label: const Text('Escanear'),
        icon: const Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.brown[700],
        // --- CAMBIO: Se establece el color del texto y del icono a blanco ---
        foregroundColor: Colors.white,
      ),
      // --- CAMBIO: Se posiciona el botón en la esquina inferior derecha ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          // --- CAMBIO: Se eliminó la tarjeta "Vender" ---
          _HomeCard(
            icon: Icons.cookie,
            label: "Tipos de Galleta",
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
          // --- CAMBIO: Se agregó la tarjeta "Configuración" ---
          _HomeCard(
            icon: Icons.settings,
            label: "Configuración",
            onTap: () {
              // Acción para el futuro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pantalla de configuración próximamente."),
                ),
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
