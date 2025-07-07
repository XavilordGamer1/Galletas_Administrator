// lib/screens/cookie_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cookie_provider.dart';
import '../models/cookie.dart';

class CookieScreen extends StatelessWidget {
  const CookieScreen({super.key});

  void _abrirFormulario(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final precioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva Galleta"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Agregar"),
            onPressed: () {
              if (nombreCtrl.text.isEmpty || precioCtrl.text.isEmpty) return;
              final nueva = Cookie(
                id: DateTime.now().toIso8601String(),
                nombre: nombreCtrl.text,
                descripcion: descCtrl.text,
                precio: double.tryParse(precioCtrl.text) ?? 0.0,
              );
              Provider.of<CookieProvider>(
                context,
                listen: false,
              ).addCookie(nueva);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cookieProvider = Provider.of<CookieProvider>(context);
    final cookies = cookieProvider.cookies;

    return Scaffold(
      appBar: AppBar(title: const Text("Tipos de Galleta")),
      body: cookies.isEmpty
          ? const Center(child: Text("Aún no has agregado galletas."))
          : ListView.builder(
              itemCount: cookies.length,
              itemBuilder: (ctx, i) {
                final cookie = cookies[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.cookie_outlined,
                      color: Colors.brown,
                    ),
                    title: Text(
                      cookie.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Precio: \$${cookie.precio.toStringAsFixed(2)}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => cookieProvider.removeCookie(cookie.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
