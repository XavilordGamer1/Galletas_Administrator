import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cookie.dart';
import '../providers/cookie_provider.dart';

/// Pantalla para editar los detalles de una galleta existente.
class EditCookieScreen extends StatefulWidget {
  final Cookie cookieToEdit;

  const EditCookieScreen({super.key, required this.cookieToEdit});

  @override
  _EditCookieScreenState createState() => _EditCookieScreenState();
}

class _EditCookieScreenState extends State<EditCookieScreen> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _precioCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los datos de la galleta a editar.
    _nombreCtrl = TextEditingController(text: widget.cookieToEdit.nombre);
    _descCtrl = TextEditingController(text: widget.cookieToEdit.descripcion);
    _precioCtrl =
        TextEditingController(text: widget.cookieToEdit.precio.toString());
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye.
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  /// Guarda los cambios realizados en el formulario.
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Crea el objeto de la galleta actualizada.
      final updatedCookie = Cookie(
        id: widget.cookieToEdit.id, // Mantiene el mismo ID
        nombre: _nombreCtrl.text,
        descripcion: _descCtrl.text,
        precio: double.parse(_precioCtrl.text),
      );

      // Llama al provider para actualizar la galleta.
      Provider.of<CookieProvider>(context, listen: false)
          .updateCookie(widget.cookieToEdit.id, updatedCookie);

      // Regresa a la pantalla anterior.
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Galleta actualizada con éxito.'),
            backgroundColor: Colors.green),
      );
    }
  }

  /// Muestra un diálogo de confirmación para eliminar la galleta.
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: Text(
            '¿Deseas eliminar la galleta "${widget.cookieToEdit.nombre}" de forma permanente?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, Eliminar'),
            onPressed: () {
              Provider.of<CookieProvider>(context, listen: false)
                  .removeCookie(widget.cookieToEdit.id);
              // Cierra el diálogo y la pantalla de edición
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar "${widget.cookieToEdit.nombre}"'),
        backgroundColor: const Color.fromARGB(255, 179, 53, 7),
        actions: [
          // Botón para eliminar en la barra de la aplicación
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'El precio no puede estar vacío';
                  if (double.tryParse(value) == null)
                    return 'Ingrese un número válido';
                  if (double.parse(value) < 0)
                    return 'El precio no puede ser negativo';
                  return null;
                },
              ),
              const Spacer(), // Empuja el botón hacia el final
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveChanges,
                  child: const Text('Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
