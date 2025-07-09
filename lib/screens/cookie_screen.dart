import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cookie_provider.dart';
import '../models/cookie.dart';

/// Pantalla para ver la lista de galletas (SOLO LECTURA).
/// No permite añadir ni eliminar, solo consultar la lista.
/// Ahora con información desplegable.
class CookieScreen extends StatefulWidget {
  const CookieScreen({super.key});

  @override
  State<CookieScreen> createState() => _CookieScreenState();
}

class _CookieScreenState extends State<CookieScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    // Carga los datos solo la primera vez que se construye el widget.
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // Llama al provider para cargar las galletas desde la BD.
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

  @override
  Widget build(BuildContext context) {
    final cookieProvider = Provider.of<CookieProvider>(context);
    final cookies = cookieProvider.cookies;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Galleta"),
        backgroundColor: Colors.brown,
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Muestra un spinner mientras carga
          : cookies.isEmpty
              ? const Center(child: Text("Aún no has agregado galletas."))
              : ListView.builder(
                  itemCount: cookies.length,
                  itemBuilder: (ctx, i) {
                    final cookie = cookies[i];
                    // --- CAMBIO: Se reemplaza ListTile con ExpansionTile ---
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: ExpansionTile(
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
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                cookie.descripcion.isEmpty
                                    ? 'No hay descripción disponible.'
                                    : cookie.descripcion,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
