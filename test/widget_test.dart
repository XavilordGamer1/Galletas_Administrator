import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Asegúrate de que este import apunte al nombre correcto de tu proyecto
import 'package:galletas_app_nueva/main.dart';

void main() {
  testWidgets('Verifica que la pantalla principal se carga correctamente',
      (WidgetTester tester) async {
    // 1. Construye tu app usando el nombre correcto del widget principal.
    await tester.pumpWidget(const VentasGalletasApp());

    // 2. Verifica que el título de la pantalla principal ("Gestor de Galletas") aparece.
    // Esto confirma que la app se inició y la HomeScreen se está mostrando.
    expect(find.text('Gestor de Galletas'), findsOneWidget);

    // 3. También podemos verificar que una de las tarjetas del menú está presente.
    // Esto nos da aún más seguridad de que la UI se cargó bien.
    expect(find.text('Vender'), findsOneWidget);
  });
}
