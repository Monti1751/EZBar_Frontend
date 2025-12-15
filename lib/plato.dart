import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Plato {
  int? id;
  String nombre;
  double precio;
  File? imagen;
  List<String> ingredientes;
  List<String> extras;
  List<String> alergenos;

  Plato({
    this.id,
    required this.nombre,
    required this.precio,
    this.imagen,
    List<String>? ingredientes,
    List<String>? extras,
    List<String>? alergenos,
  }) : ingredientes = ingredientes ?? [],
       extras = extras ?? [],
       alergenos = alergenos ?? [];
}

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF4A4025)),
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF4A4025), width: 1.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF7BA238), width: 2.2),
    ),
  );
}

class PlatoEditorPage extends StatefulWidget {
  final Plato plato;
  const PlatoEditorPage({Key? key, required this.plato}) : super(key: key);

  @override
  State<PlatoEditorPage> createState() => _PlatoEditorPageState();
}

class _PlatoEditorPageState extends State<PlatoEditorPage> {
  File? _imagenPlato;
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late List<String> _ingredientes;
  late List<String> _extras;
  late List<String> _alergenos;

  final TextEditingController _ingredienteController = TextEditingController();
  final TextEditingController _extraController = TextEditingController();
  final TextEditingController _alergenoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagenPlato = widget.plato.imagen;
    _nombreController = TextEditingController(text: widget.plato.nombre);
    _precioController = TextEditingController(
      text: widget.plato.precio.toString(),
    );
    _ingredientes = List.from(widget.plato.ingredientes);
    _extras = List.from(widget.plato.extras);
    _alergenos = List.from(widget.plato.alergenos);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _ingredienteController.dispose();
    _extraController.dispose();
    _alergenoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenPlato = File(pickedFile.path));
    }
  }

  Future<void> _tomarFoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imagenPlato = File(pickedFile.path));
    }
  }

  void _agregarIngrediente() {
    final t = _ingredienteController.text.trim();
    if (t.isNotEmpty) {
      setState(() {
        _ingredientes.add(t);
        _ingredienteController.clear();
      });
    }
  }

  void _agregarExtra() {
    final t = _extraController.text.trim();
    if (t.isNotEmpty) {
      setState(() {
        _extras.add(t);
        _extraController.clear();
      });
    }
  }

  void _agregarAlergeno() {
    final t = _alergenoController.text.trim();
    if (t.isNotEmpty) {
      setState(() {
        _alergenos.add(t);
        _alergenoController.clear();
      });
    }
  }

  void _confirmarBorrado(String item, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Seguro que quieres eliminar '$item'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(ctx).pop();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _guardarPlato() {
    widget.plato.nombre = _nombreController.text.trim();
    String precioStr = _precioController.text.trim().replaceAll(',', '.');
    widget.plato.precio = double.tryParse(precioStr) ?? 0.0;
    widget.plato.imagen = _imagenPlato;
    widget.plato.ingredientes = _ingredientes;
    widget.plato.extras = _extras;
    widget.plato.alergenos = _alergenos;
    Navigator.pop(context, widget.plato);
  }

  void _cancelar() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final verde = const Color(0xFF7BA238);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear/Editar Plato"),
        backgroundColor: verde,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del plato
            GestureDetector(
              onTap: _tomarFoto,
              onLongPress: _seleccionarImagen,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  image: _imagenPlato != null
                      ? DecorationImage(
                          image: FileImage(_imagenPlato!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagenPlato == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // Nombre y precio
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: loginInputDecoration(
                      "Nombre del plato",
                      Icons.fastfood,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: loginInputDecoration("Precio", Icons.euro),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alérgenos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _alergenoController,
                            decoration: loginInputDecoration(
                              "Alérgeno",
                              Icons.warning,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: verde),
                          onPressed: _agregarAlergeno,
                        ),
                      ],
                    ),
                    ..._alergenos.map(
                      (a) => ListTile(
                        title: Text(a),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarBorrado(a, () {
                            setState(() => _alergenos.remove(a));
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ingredientes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ingredienteController,
                            decoration: loginInputDecoration(
                              "Ingrediente",
                              Icons.restaurant,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: verde),
                          onPressed: _agregarIngrediente,
                        ),
                      ],
                    ),
                    ..._ingredientes.map(
                      (i) => ListTile(
                        title: Text(i),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarBorrado(i, () {
                            setState(() => _ingredientes.remove(i));
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Extras
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _extraController,
                            decoration: loginInputDecoration(
                              "Extra",
                              Icons.add_circle_outline,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: verde),
                          onPressed: _agregarExtra,
                        ),
                      ],
                    ),
                    ..._extras.map(
                      (e) => ListTile(
                        title: Text(e),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarBorrado(e, () {
                            setState(() => _extras.remove(e));
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones Guardar / Cancelar con texto negro
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardarPlato,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Guardar plato",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
