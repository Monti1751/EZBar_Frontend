import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/visual_settings_provider.dart';
import '../l10n/app_localizations.dart';

class Plato {
  int? id;
  String nombre;
  double precio;
  XFile? imagen; // Local file picked by user
  String? imagenUrl; // URL if hosted remotely
  String? imagenBlob; // Base64 string if stored incorrectly as blob
  List<String> ingredientes;
  List<String> extras;
  List<String> alergenos;
  String syncStatus; // "pendiente" o "sincronizado"
  String? localId; // ID temporal para productos creados sin conexión
  int? categoriaId;

  Plato({
    this.id,
    required this.nombre,
    required this.precio,
    this.imagen,
    this.imagenUrl,
    this.imagenBlob,
    List<String>? ingredientes,
    List<String>? extras,
    List<String>? alergenos,
    this.syncStatus = 'sincronizado',
    this.localId,
    this.categoriaId,
  })  : ingredientes = ingredientes ?? [],
        extras = extras ?? [],
        alergenos = alergenos ?? [];

  // Convertir a Map para SQLite / JSON
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (id != null) 'producto_id': id,
      'nombre': nombre,
      'precio': precio,
      if (imagenBlob != null) 'imagen_blob': imagenBlob,
      if (imagenUrl != null) 'imagen_url': imagenUrl,
      'ingredientes':
          ingredientes.join('|'), // Convertir lista a string separado por |
      'extras': extras.join('|'),
      'alergenos': alergenos.join('|'),
      'sync_status': syncStatus,
      if (localId != null) 'local_id': localId,
      if (categoriaId != null) 'categoria_id': categoriaId,
    };
  }

  // Crear desde Map de SQLite / JSON
  factory Plato.fromMap(Map<String, dynamic> map) {
    int? parseId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    return Plato(
      id: parseId(map['id']) ?? parseId(map['producto_id']),
      nombre: map['nombre'] as String? ?? '',
      precio: (map['precio'] is String)
          ? double.tryParse(map['precio']) ?? 0.0
          : (map['precio'] as num?)?.toDouble() ?? 0.0,
      imagenBlob: map['imagen_blob'] as String?,
      imagenUrl: map['imagen_url'] as String?,
      ingredientes: (map['ingredientes'] as String?)
              ?.split('|')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      extras: (map['extras'] as String?)
              ?.split('|')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      alergenos: (map['alergenos'] as String?)
              ?.split('|')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      syncStatus: map['sync_status'] as String? ?? 'sincronizado',
      localId: map['local_id'] as String?,
      categoriaId: parseId(map['categoria_id']) ?? 
                  (map['categoria'] != null ? parseId(map['categoria']['categoria_id']) : null),
    );
  }
}

/// Helper para InputDecoration consistente
InputDecoration loginInputDecoration(String hint, IconData icon,
    {bool darkMode = false, Color? iconColor}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: darkMode ? Colors.grey[400] : Colors.grey[600]),
    prefixIcon: Icon(icon, color: iconColor ?? const Color(0xFF4A4025)),
    filled: true,
    fillColor: darkMode ? Colors.grey[800] : const Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide:
          BorderSide(color: iconColor ?? const Color(0xFF4A4025), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(
          color: darkMode ? Colors.greenAccent : const Color(0xFF7BA238),
          width: 2.2),
    ),
  );
}

class PlatoEditorPage extends StatefulWidget {
  final Plato plato;
  final Future<void> Function(Plato)? onSave; // Callback for persistence

  const PlatoEditorPage({super.key, required this.plato, this.onSave});

  @override
  State<PlatoEditorPage> createState() => _PlatoEditorPageState();
}

class _PlatoEditorPageState extends State<PlatoEditorPage> {
  XFile? _imagenPlato; // Better for cross-platform
  String? _imagenUrl;
  String? _imagenBlob;
  bool _isSaving = false;

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
    _imagenUrl = widget.plato.imagenUrl;
    _imagenBlob = widget.plato.imagenBlob;

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
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Limit size to avoid huge base64 strings
        maxHeight: 800,
        imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imagenPlato = pickedFile;
        _imagenUrl = null;
        _imagenBlob = null;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imagenPlato = pickedFile;
        _imagenUrl = null;
        _imagenBlob = null;
      });
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
        title: Text(
            AppLocalizations.of(context).translate('confirm_delete_title')),
        content: Text(
            "${AppLocalizations.of(context).translate('confirm_delete_message')} '$item'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(ctx).pop();
            },
            child: Text(AppLocalizations.of(context).translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarPlato() async {
    // 1. Prepare data in the object
    widget.plato.nombre = _nombreController.text.trim();
    String precioStr = _precioController.text.trim().replaceAll(',', '.');
    widget.plato.precio = double.tryParse(precioStr) ?? 0.0;

    widget.plato.ingredientes = List.from(_ingredientes);
    widget.plato.extras = List.from(_extras);
    widget.plato.alergenos = List.from(_alergenos);

    if (_imagenPlato != null) {
      // widget.plato.imagen = File(_imagenPlato!.path); // Only if you really need the File object
      final bytes = await _imagenPlato!.readAsBytes();
      String base64Image = base64Encode(bytes);
      widget.plato.imagenBlob = base64Image;
      widget.plato.imagenUrl = null;
    }

    if (widget.onSave != null) {
      // Save and Stay logic
      try {
        setState(() => _isSaving = true);
        await widget.onSave!(widget.plato);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).translate('added')),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isSaving = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Traditional Save and Pop logic (for new items)
      if (!mounted) return;
      Navigator.pop(context, widget.plato);
    }
  }

  void _cancelar() {
    Navigator.pop(context, null);
  }

  bool get _hasChanges {
    final nombreChanged = _nombreController.text.trim() != widget.plato.nombre;
    final precioStr = _precioController.text.trim().replaceAll(',', '.');
    final precioVal = double.tryParse(precioStr) ?? 0.0;
    final precioChanged = (precioVal - widget.plato.precio).abs() > 0.01;

    final imagenChanged = _imagenPlato?.path != widget.plato.imagen?.path;

    // Comparación de listas (orden y contenido)
    final ingredientesChanged =
        !_listEquals(_ingredientes, widget.plato.ingredientes);
    final extrasChanged = !_listEquals(_extras, widget.plato.extras);
    final alergenosChanged = !_listEquals(_alergenos, widget.plato.alergenos);

    return !_isSaving &&
        (nombreChanged ||
            precioChanged ||
            imagenChanged ||
            ingredientesChanged ||
            extrasChanged ||
            alergenosChanged);
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // Helper to build image widget
  Widget _buildImageWidget(bool darkMode) {
    if (_imagenPlato != null) {
      if (kIsWeb) {
        return Image.network(_imagenPlato!.path, fit: BoxFit.cover);
      }
      return Image.file(File(_imagenPlato!.path), fit: BoxFit.cover);
    } else if (_imagenBlob != null && _imagenBlob!.isNotEmpty) {
      try {
        // Handle data:image/png;base64, prefix if present
        String cleanBase64 = _imagenBlob!;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        Uint8List decoded = base64Decode(cleanBase64);
        return Image.memory(decoded, fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.error);
      }
    } else if (_imagenUrl != null && _imagenUrl!.isNotEmpty) {
      return Image.network(
        _imagenUrl!,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
      );
    }
    return Icon(Icons.add_a_photo,
        size: 50, color: darkMode ? Colors.grey : Colors.black54);
  }

  @override
  Widget build(BuildContext context) {
    // We need to inject VisualSettingsProvider here or reuse the one from context if available
    // Since this file didn't import it before, I added the import.
    // If provider is not found, we use defaults.

    bool darkMode = false;
    bool colorBlind = false;

    try {
      final settings = Provider.of<VisualSettingsProvider>(context);
      darkMode = settings.darkMode;
      colorBlind = settings.colorBlindMode;
    } catch (_) {}

    final primaryColor = colorBlind ? Colors.blue : const Color(0xFF7BA238);
    final backgroundColor = darkMode ? Colors.black87 : Colors.white;
    final textColor = darkMode ? Colors.white : Colors.black;
    final cardColor = darkMode ? Colors.grey[900] : Colors.white;

    // Colores para el botón de guardar (bloqueado vs activo)
    final saveButtonColor = primaryColor;
    final saveButtonDisabledColor =
        darkMode ? Colors.grey[700] : Colors.grey[400];
    final saveButtonTextColor = Colors.white;
    final saveButtonDisabledTextColor =
        darkMode ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('create_edit_dish')),
        backgroundColor: primaryColor,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: darkMode ? Colors.grey : Colors.transparent),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(darkMode),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nombre y precio
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombreController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: textColor),
                    decoration: loginInputDecoration(
                      "Nombre del plato",
                      Icons.fastfood,
                      darkMode: darkMode,
                      iconColor: darkMode ? Colors.white70 : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: textColor),
                    decoration: loginInputDecoration(
                      "Precio",
                      Icons.euro,
                      darkMode: darkMode,
                      iconColor: darkMode ? Colors.white70 : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alérgenos
            Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _alergenoController,
                            style: TextStyle(color: textColor),
                            decoration: loginInputDecoration(
                              AppLocalizations.of(context)
                                  .translate('allergens'),
                              Icons.warning,
                              darkMode: darkMode,
                              iconColor: darkMode ? Colors.white70 : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: primaryColor),
                          onPressed: _agregarAlergeno,
                        ),
                      ],
                    ),
                    ..._alergenos.map(
                      (a) => ListTile(
                        title: Text(a, style: TextStyle(color: textColor)),
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
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ingredienteController,
                            style: TextStyle(color: textColor),
                            decoration: loginInputDecoration(
                              AppLocalizations.of(context)
                                  .translate('ingredients'),
                              Icons.restaurant,
                              darkMode: darkMode,
                              iconColor: darkMode ? Colors.white70 : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: primaryColor),
                          onPressed: _agregarIngrediente,
                        ),
                      ],
                    ),
                    ..._ingredientes.map(
                      (i) => ListTile(
                        title: Text(i, style: TextStyle(color: textColor)),
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
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _extraController,
                            style: TextStyle(color: textColor),
                            decoration: loginInputDecoration(
                              AppLocalizations.of(context).translate('extras'),
                              Icons.add_circle_outline,
                              darkMode: darkMode,
                              iconColor: darkMode ? Colors.white70 : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: primaryColor),
                          onPressed: _agregarExtra,
                        ),
                      ],
                    ),
                    ..._extras.map(
                      (e) => ListTile(
                        title: Text(e, style: TextStyle(color: textColor)),
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

            // Botones Guardar / Cancelar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasChanges ? _guardarPlato : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: saveButtonColor,
                      disabledBackgroundColor: saveButtonDisabledColor,
                      disabledForegroundColor: saveButtonDisabledTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).translate('add'),
                      style: TextStyle(
                          color: _hasChanges
                              ? saveButtonTextColor
                              : saveButtonDisabledTextColor),
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
                    child: Text(
                      AppLocalizations.of(context).translate('cancel'),
                      style: const TextStyle(color: Colors.white),
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
