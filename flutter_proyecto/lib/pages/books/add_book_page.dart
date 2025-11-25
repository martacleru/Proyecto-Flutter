// FORMULARIO PARA AÑADIR NUEVOS LIBROS - Interfaz completa para agregar libros a la biblioteca

import 'package:flutter/material.dart';
import '../../models/libro_model.dart';
import '../../services/libro_service.dart';
import '../../widgets/calificacion_estrellas.dart';

class AddBookPage extends StatefulWidget {
  final String usuarioId; // ID del usuario que añade el libro
  final String usuarioNombre; // Nombre del usuario para referencia

  const AddBookPage({
    super.key,
    required this.usuarioId,
    required this.usuarioNombre,
  });

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final LibroService _libroService = LibroService(); // Servicio para operaciones con libros
  final _formKey = GlobalKey<FormState>(); // Key para validación del formulario

  // CONTROLADORES PARA LOS CAMPOS DE TEXTO
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _paginasController = TextEditingController();
  final TextEditingController _resenaController = TextEditingController();
  final TextEditingController _portadaController = TextEditingController();

  // VARIABLES DE ESTADO DEL FORMULARIO
  double _calificacion = 0.0; // Calificación inicial 0
  String _estadoSeleccionado = 'por_leer'; // Estado por defecto
  String _generoSeleccionado = 'Ficcion'; // Género por defecto
  
  // LISTAS DE OPCIONES PARA DROPDOWNS Y CHIPS
  final List<String> _estados = ['por_leer', 'leyendo', 'leido'];
  final List<String> _generos = [
    'Ficcion', 'No Ficcion', 'Ciencia Ficcion', 'Fantasia', 
    'Misterio', 'Romance', 'Thriller', 'Biografia', 'Historia',
    'Autoayuda', 'Poesia', 'Teatro', 'Infantil', 'Juvenil',
    'Aventura', 'Terror', 'Policiaca', 'Distopia', 'Realismo Magico',
    'Humor', 'Viajes', 'Cocina', 'Arte', 'Deportes', 'Otro'
  ];

  // FOCUS NODES PARA NAVEGACIÓN CON TECLADO
  final FocusNode _autorFocusNode = FocusNode();
  final FocusNode _paginasFocusNode = FocusNode();
  final FocusNode _resenaFocusNode = FocusNode();
  final FocusNode _portadaFocusNode = FocusNode();

  @override
  void dispose() {
    // LIMPIAR CONTROLADORES Y FOCUS NODES AL DESTRUIR EL WIDGET
    _tituloController.dispose();
    _autorController.dispose();
    _paginasController.dispose();
    _resenaController.dispose();
    _portadaController.dispose();
    
    _autorFocusNode.dispose();
    _paginasFocusNode.dispose();
    _resenaFocusNode.dispose();
    _portadaFocusNode.dispose();
    
    super.dispose();
  }

  // MÉTODO PRINCIPAL PARA GUARDAR EL LIBRO
  Future<void> _guardarLibro() async {
    if (_formKey.currentState!.validate()) { // Validar formulario
      try {
        // CREAR NUEVO OBJETO LIBRO CON LOS DATOS DEL FORMULARIO
        Libro nuevoLibro = Libro(
          titulo: _tituloController.text.trim(),
          autor: _autorController.text.trim(),
          calificacion: _calificacion,
          resena: _resenaController.text.trim(),
          paginas: int.parse(_paginasController.text),
          estado: _estadoSeleccionado,
          genero: _generoSeleccionado,
          portadaURL: _portadaController.text.trim().isEmpty 
              ? null  // Si no hay URL, dejar como null
              : _portadaController.text.trim(),
          fechaLectura: _estadoSeleccionado == 'leido' ? DateTime.now() : null, // Solo si está leído
          fechaAgregado: DateTime.now(), // Fecha actual
        );

        // GUARDAR EN FIRESTORE
        await _libroService.agregarLibro(widget.usuarioId, nuevoLibro);

        if (mounted) {
          // MOSTRAR MENSAJE DE ÉXITO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${nuevoLibro.titulo}" anadido correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          
          // VOLVER A LA PANTALLA ANTERIOR
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          // MOSTRAR ERROR EN CASO DE FALLO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // MÉTODO PARA CANCELAR Y LIMPIAR EL FORMULARIO
  void _cancelar() {
    // LIMPIAR TODOS LOS CAMPOS
    _tituloController.clear();
    _autorController.clear();
    _paginasController.clear();
    _resenaController.clear();
    _portadaController.clear();
    _calificacion = 0.0;
    _estadoSeleccionado = 'por_leer';
    _generoSeleccionado = 'Ficcion';
    
    // VOLVER A LA PANTALLA ANTERIOR
    Navigator.pop(context);
  }

  // MANEJADORES DE NAVEGACIÓN CON ENTER ENTRE CAMPOS
  void _manejarEnterTitulo(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_autorFocusNode);
    }
  }

  void _manejarEnterAutor(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_paginasFocusNode);
    }
  }

  void _manejarEnterPaginas(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_resenaFocusNode);
    }
  }

  void _manejarEnterResena(String value) {
    FocusScope.of(context).requestFocus(_portadaFocusNode);
  }

  void _manejarEnterPortada(String value) {
    _guardarLibro(); // Guardar automáticamente al final
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anadir Nuevo Libro'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // BOTÓN DE GUARDAR EN LA APP BAR
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarLibro,
            tooltip: 'Guardar libro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Ancho máximo para tablets
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey, // Key para validación
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TÍTULO DE LA PÁGINA
                      const Center(
                        child: Text(
                          '📖 Añadir Nuevo Libro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CAMPO: TÍTULO DEL LIBRO
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Titulo del libro *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: _manejarEnterTitulo,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el titulo del libro';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: AUTOR
                      TextFormField(
                        controller: _autorController,
                        focusNode: _autorFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Autor *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: _manejarEnterAutor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el autor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: NÚMERO DE PÁGINAS
                      TextFormField(
                        controller: _paginasController,
                        focusNode: _paginasFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Numero de paginas *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        keyboardType: TextInputType.number, // Teclado numérico
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: _manejarEnterPaginas,
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

                      // SELECTOR: ESTADO DE LECTURA
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
                              // Traducir valores internos a español
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

                      // SELECTOR: GÉNERO CON CHIPS INTERACTIVOS
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
                                _generoSeleccionado = genero; // Solo un género seleccionable
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

                      // CALIFICACIÓN CON ESTRELLAS
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

                      // CAMPO: RESEÑA PERSONAL (OPCIONAL)
                      TextFormField(
                        controller: _resenaController,
                        focusNode: _resenaFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Resena personal (opcional)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4, // Campo multilínea
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: _manejarEnterResena,
                      ),
                      const SizedBox(height: 16),

                      // CAMPO: URL DE PORTADA (OPCIONAL)
                      TextFormField(
                        controller: _portadaController,
                        focusNode: _portadaFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'URL de la portada (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: _manejarEnterPortada,
                      ),
                      const SizedBox(height: 24),

                      // BOTONES DE ACCIÓN: CANCELAR Y GUARDAR
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
                              onPressed: _guardarLibro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Guardar Libro',
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