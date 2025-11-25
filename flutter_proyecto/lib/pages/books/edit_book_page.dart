// EDITAR LIBROS EXISTENTES - Permite modificar la información de libros ya agregados

import 'package:flutter/material.dart';
import '../../models/libro_model.dart';
import '../../services/libro_service.dart';
import '../../widgets/calificacion_estrellas.dart';

class EditBookPage extends StatefulWidget {
  final String usuarioId; // ID del usuario propietario
  final Libro libro; // Libro a editar
  final String libroId; // ID del documento del libro

  const EditBookPage({
    super.key,
    required this.usuarioId,
    required this.libro,
    required this.libroId,
  });

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final LibroService _libroService = LibroService();
  final _formKey = GlobalKey<FormState>();

  // CONTROLADORES PRECARGADOS CON LOS DATOS EXISTENTES
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _paginasController = TextEditingController();
  final TextEditingController _resenaController = TextEditingController();
  final TextEditingController _portadaController = TextEditingController();

  // VARIABLES DE ESTADO INICIALIZADAS CON VALORES EXISTENTES
  double _calificacion = 0.0;
  String _estadoSeleccionado = 'por_leer';
  String _generoSeleccionado = 'Ficcion';
  
  final List<String> _estados = ['por_leer', 'leyendo', 'leido'];
  final List<String> _generos = [
    'Ficcion', 'No Ficcion', 'Ciencia Ficcion', 'Fantasia', 
    'Misterio', 'Romance', 'Thriller', 'Biografia', 'Historia',
    'Autoayuda', 'Poesia', 'Teatro', 'Infantil', 'Juvenil',
    'Aventura', 'Terror', 'Policiaca', 'Distopia', 'Realismo Magico',
    'Humor', 'Viajes', 'Cocina', 'Arte', 'Deportes', 'Otro'
  ];

  @override
  void initState() {
    super.initState();
    // CARGAR LOS DATOS EXISTENTES DEL LIBRO EN LOS CONTROLADORES
    _cargarDatosLibro();
  }

  // PRECARGAR DATOS DEL LIBRO EN EL FORMULARIO
  void _cargarDatosLibro() {
    _tituloController.text = widget.libro.titulo;
    _autorController.text = widget.libro.autor;
    _paginasController.text = widget.libro.paginas.toString();
    _resenaController.text = widget.libro.resena;
    _portadaController.text = widget.libro.portadaURL ?? '';
    _calificacion = widget.libro.calificacion;
    _estadoSeleccionado = widget.libro.estado;
    _generoSeleccionado = widget.libro.genero;
  }

  @override
  void dispose() {
    // LIMPIAR RECURSOS
    _tituloController.dispose();
    _autorController.dispose();
    _paginasController.dispose();
    _resenaController.dispose();
    _portadaController.dispose();
    super.dispose();
  }

  // ACTUALIZAR LIBRO EN LA BASE DE DATOS
  Future<void> _actualizarLibro() async {
    if (_formKey.currentState!.validate()) {
      try {
        // CREAR OBJETO LIBRO ACTUALIZADO
        Libro libroActualizado = Libro(
          id: widget.libroId, // Mantener el mismo ID
          titulo: _tituloController.text.trim(),
          autor: _autorController.text.trim(),
          calificacion: _calificacion,
          resena: _resenaController.text.trim(),
          paginas: int.parse(_paginasController.text),
          estado: _estadoSeleccionado,
          genero: _generoSeleccionado,
          portadaURL: _portadaController.text.trim().isEmpty 
              ? null 
              : _portadaController.text.trim(),
          // MANTENER FECHA DE LECTURA ORIGINAL O ACTUALIZAR SI CAMBIA A "LEÍDO"
          fechaLectura: _estadoSeleccionado == 'leido' 
              ? (widget.libro.fechaLectura ?? DateTime.now()) 
              : widget.libro.fechaLectura,
          fechaAgregado: widget.libro.fechaAgregado, // Mantener fecha original
        );

        // ACTUALIZAR EN FIRESTORE
        await _libroService.actualizarLibro(widget.usuarioId, widget.libroId, libroActualizado);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${libroActualizado.titulo}" actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context); // Volver a la pantalla anterior
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _cancelar() {
    Navigator.pop(context); // Volver sin guardar cambios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Libro'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _actualizarLibro,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          '📝 Editar Libro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CAMPO: TÍTULO (precargado)
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Titulo del libro *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el titulo del libro';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: AUTOR (precargado)
                      TextFormField(
                        controller: _autorController,
                        decoration: const InputDecoration(
                          labelText: 'Autor *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el autor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: PÁGINAS (precargado)
                      TextFormField(
                        controller: _paginasController,
                        decoration: const InputDecoration(
                          labelText: 'Numero de paginas *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el numero de paginas';
                          }
                          final pages = int.tryParse(value);
                          if (pages == null || pages <= 0) {
                            return 'Ingresa un numero valido de paginas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // SELECTOR: ESTADO (precargado)
                      DropdownButtonFormField<String>(
                        value: _estadoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Estado de lectura *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bookmark),
                        ),
                        items: _estados.map((String estado) {
                          return DropdownMenuItem<String>(
                            value: estado,
                            child: Text(
                              estado == 'leido' ? 'Leido' : 
                              estado == 'leyendo' ? 'Leyendo' : 'Por leer',
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _estadoSeleccionado = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // SELECTOR: GÉNERO CON CHIPS (precargado)
                      const Text(
                        'Género *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _generos.map((genero) {
                          return ChoiceChip(
                            label: Text(genero),
                            selected: _generoSeleccionado == genero,
                            onSelected: (selected) {
                              setState(() {
                                _generoSeleccionado = genero;
                              });
                            },
                            selectedColor: Colors.indigo.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _generoSeleccionado == genero 
                                  ? Colors.indigo 
                                  : Colors.black87,
                              fontWeight: _generoSeleccionado == genero 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // CALIFICACIÓN (precargada)
                      const Text(
                        'Calificacion:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CalificacionEstrellas(
                        calificacion: _calificacion,
                        onCalificacionCambiada: (nuevaCalificacion) {
                          setState(() {
                            _calificacion = nuevaCalificacion;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: RESEÑA (precargado, más grande para edición)
                      TextFormField(
                        controller: _resenaController,
                        decoration: const InputDecoration(
                          labelText: 'Reseña personal',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          hintText: 'Escribe tu reseña sobre este libro...',
                        ),
                        maxLines: 6,
                        minLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: URL DE PORTADA (precargado)
                      TextFormField(
                        controller: _portadaController,
                        decoration: const InputDecoration(
                          labelText: 'URL de la portada (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // BOTONES: CANCELAR Y GUARDAR CAMBIOS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _cancelar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _actualizarLibro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}