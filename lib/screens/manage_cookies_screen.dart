import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cookie_provider.dart';
import '../models/cookie.dart';
import './edit_cookie_screen.dart';

/// Pantalla para gestionar (ver, editar, añadir) las galletas.
/// Se accede desde el botón "Configuración".
class ManageCookiesScreen extends StatefulWidget {
  const ManageCookiesScreen({super.key});

  @override
  State<ManageCookiesScreen> createState() => _ManageCookiesScreenState();
}

class _ManageCookiesScreenState extends State<ManageCookiesScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<CookieProvider>(context, listen: false)
          .loadCookies()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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
                maxLength: 15, // <-- AQUÍ ESTÁ EL CAMBIO
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
      appBar: AppBar(
        title: const Text("Configurar Galletas"),
        backgroundColor: Colors.brown,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cookies.isEmpty
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
                        // En esta pantalla, SÍ se puede editar al tocar.
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  EditCookieScreen(cookieToEdit: cookie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
