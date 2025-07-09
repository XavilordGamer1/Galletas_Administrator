import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cookie_provider.dart';
import 'providers/ventas_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart'; // <-- AÑADIDO: Importa el servicio

// CAMBIO: La función main ahora es asíncrona para poder esperar a que se completen las inicializaciones.
void main() async {
  // CAMBIO: Asegura que todos los bindings de Flutter estén listos antes de ejecutar código asíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // CAMBIO: Inicializa el servicio de notificaciones y solicita permisos.
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const VentasGalletasApp());
}

class VentasGalletasApp extends StatelessWidget {
  const VentasGalletasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CookieProvider()),
        ChangeNotifierProvider(create: (_) => VentasProvider()),
      ],
      child: MaterialApp(
        title: 'Gestión de Ventas de Galletas',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[100],
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
