// BIBLIOTECA PERSONAL DEL USUARIO - Vista principal para gestionar la colección de libros

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/libro_model.dart';
import '../../services/libro_service.dart';
import '../../widgets/calificacion_estrellas.dart';
import '../../widgets/custom_drawer.dart';
import '../auth/login_page.dart';
import '../home_page.dart';
import '../map/map_page.dart';
import '../admin/admin_page.dart';
import '../profile/profile_page.dart';
import '../stats/stats_page.dart';
import '../books/add_book_page.dart';
import '../books/edit_book_page.dart';

class BibliotecaPage extends StatefulWidget {
  final String usuarioId; // ID del usuario actual
  final String username; // Nombre de usuario
  final String imageURL; // URL de imagen de perfil
  final String userRole; // Rol del usuario

  const BibliotecaPage({
    super.key, 
    required this.usuarioId,
    required this.username,
    required this.imageURL,
    required this.userRole,
  });

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  final LibroService _libroService = LibroService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  // VARIABLES DE ESTADO PARA FILTROS Y BÚSQUEDA
  String _filtroEstado = 'todos'; // Filtro por estado: 'todos', 'leido', 'leyendo', 'por_leer'
  String _searchQuery = ''; // Término de búsqueda
  String _currentPage = 'library'; // Página actual para el drawer

  @override
  void initState() {
    super.initState();
    // LISTENER PARA BÚSQUEDA EN TIEMPO REAL
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MÉTODOS DE NAVEGACIÓN

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          username: widget.username,
          imageURL: widget.imageURL,
          firestore: FirebaseFirestore.instance,
        ),
      ),
    );
  }

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(
        username: widget.username,
        imageURL: widget.imageURL,
      )),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPage(
        username: widget.username,
        imageURL: widget.imageURL,
        userRole: widget.userRole,
      )),
    );
  }

  void _openStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatsPage(
        usuarioId: widget.usuarioId,
        username: widget.username,
        imageURL: widget.imageURL,
        userRole: widget.userRole,
      )),
    );
  }

  void _openAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminPage(
        username: widget.username,
        imageURL: widget.imageURL,
        userRole: widget.userRole,
      )),
    );
  }

  void _openAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBookPage(
        usuarioId: widget.usuarioId,
        usuarioNombre: widget.username,
      )),
    );
  }

  void _openEditBook(Libro libro, String libroId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditBookPage(
        usuarioId: widget.usuarioId,
        libro: libro,
        libroId: libroId,
      )),
    );
  }

  // ACTUALIZAR CALIFICACIÓN DE UN LIBRO
  void _actualizarCalificacion(String libroId, double nuevaCalificacion) {
    _libroService.actualizarCalificacion(
      widget.usuarioId, 
      libroId, 
      nuevaCalificacion
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calificación actualizada: $nuevaCalificacion estrellas'),
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar calificación: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // ELIMINAR LIBRO CON CONFIRMACIÓN
  void _eliminarLibro(String libroId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: const Text('¿Estás seguro de que quieres eliminar este libro de tu biblioteca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _libroService.eliminarLibro(widget.usuarioId, libroId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Libro eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Eliminar', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // OBTENER STREAM DE LIBROS FILTRADOS
  Stream<QuerySnapshot> _obtenerLibrosFiltrados() {
    Query query = _firestore
        .collection('usuarios')
        .doc(widget.usuarioId)
        .collection('libros');

    // APLICAR FILTRO DE ESTADO SI NO ES 'TODOS'
    if (_filtroEstado != 'todos') {
      query = query.where('estado', isEqualTo: _filtroEstado);
    }

    return query.snapshots();
  }

  // TEXTO DESCRIPTIVO DEL FILTRO ACTUAL
  String _obtenerTextoFiltroActual() {
    switch (_filtroEstado) {
      case 'leido':
        return 'Leídos';
      case 'leyendo':
        return 'Leyendo';
      case 'por_leer':
        return 'Por leer';
      default:
        return 'Todos los libros';
    }
  }

  // COLOR DEL FILTRO ACTUAL
  Color _obtenerColorFiltroActual() {
    switch (_filtroEstado) {
      case 'leido':
        return Colors.green;
      case 'leyendo':
        return Colors.orange;
      case 'por_leer':
        return Colors.blue;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // INDICADOR VISUAL DEL FILTRO ACTIVO
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                if (_filtroEstado != 'todos')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _obtenerColorFiltroActual().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _obtenerColorFiltroActual(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _obtenerTextoFiltroActual(),
                      style: TextStyle(
                        color: _obtenerColorFiltroActual(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // MENÚ DE FILTROS
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      _filtroEstado = value; // Cambiar filtro
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'todos',
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books,
                            color: _filtroEstado == 'todos' ? Colors.indigo : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Todos los libros',
                            style: TextStyle(
                              fontWeight: _filtroEstado == 'todos' ? FontWeight.bold : FontWeight.normal,
                              color: _filtroEstado == 'todos' ? Colors.indigo : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'leido',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _filtroEstado == 'leido' ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Leídos',
                            style: TextStyle(
                              fontWeight: _filtroEstado == 'leido' ? FontWeight.bold : FontWeight.normal,
                              color: _filtroEstado == 'leido' ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'leyendo',
                      child: Row(
                        children: [
                          Icon(
                            Icons.autorenew,
                            color: _filtroEstado == 'leyendo' ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Leyendo',
                            style: TextStyle(
                              fontWeight: _filtroEstado == 'leyendo' ? FontWeight.bold : FontWeight.normal,
                              color: _filtroEstado == 'leyendo' ? Colors.orange : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'por_leer',
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            color: _filtroEstado == 'por_leer' ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Por leer',
                            style: TextStyle(
                              fontWeight: _filtroEstado == 'por_leer' ? FontWeight.bold : FontWeight.normal,
                              color: _filtroEstado == 'por_leer' ? Colors.blue : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // DRAWER DE NAVEGACIÓN
      drawer: CustomDrawer(
        currentUsername: widget.username,
        currentImageURL: widget.imageURL,
        userRole: widget.userRole,
        currentPage: _currentPage,
        parentContext: context,
        onLogout: _logout,
        onProfile: _openProfile,
        onAddBook: _openAddBook,
        onBookList: () {
          Navigator.pop(context);
        },
        onSearch: () {
          Navigator.pop(context);
        },
        onMap: _openMap,
        onStats: _openStats,
        onHome: _openHome,
        onAdminPanel: widget.userRole == 'admin' ? _openAdminPanel : null,
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Barra de búsqueda
          // INDICADOR DE FILTROS ACTIVOS
          if (_searchQuery.isNotEmpty || _filtroEstado != 'todos')
            _buildFiltrosActivos(),
          Expanded(
            child: _buildListaLibros(), // Lista de libros
          ),
        ],
      ),
      // BOTÓN FLOTANTE PARA AÑADIR LIBROS
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddBook,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // CONSTRUIR BARRA DE BÚSQUEDA
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por título o autor...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value; // Búsqueda en tiempo real
          });
        },
      ),
    );
  }

  // CONSTRUIR INDICADORES DE FILTROS ACTIVOS
  Widget _buildFiltrosActivos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_searchQuery.isNotEmpty)
            Chip(
              label: Text('Busqueda: "$_searchQuery"'),
              backgroundColor: Colors.blue.withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          if (_filtroEstado != 'todos')
            Chip(
              label: Text('Estado: ${_obtenerTextoFiltroActual()}'),
              backgroundColor: _obtenerColorFiltroActual().withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _filtroEstado = 'todos'; // Quitar filtro
                });
              },
            ),
        ],
      ),
    );
  }

  // CONSTRUIR LISTA DE LIBROS
  Widget _buildListaLibros() {
    return StreamBuilder<QuerySnapshot>(
      stream: _obtenerLibrosFiltrados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(); // Estado vacío
        }

        // OBTENER LIBROS Y APLICAR BÚSQUEDA LOCAL
        List<QueryDocumentSnapshot> libros = snapshot.data!.docs;
        
        if (_searchQuery.isNotEmpty) {
          libros = libros.where((doc) {
            final libroData = doc.data() as Map<String, dynamic>;
            final titulo = libroData['titulo']?.toString().toLowerCase() ?? '';
            final autor = libroData['autor']?.toString().toLowerCase() ?? '';
            final busqueda = _searchQuery.toLowerCase();
            return titulo.contains(busqueda) || autor.contains(busqueda);
          }).toList();
        }

        if (libros.isEmpty) {
          return _buildEmptyState(); // No hay resultados
        }

        return ListView.builder(
          itemCount: libros.length,
          itemBuilder: (context, index) {
            final libroDoc = libros[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
            final libro = Libro.fromQueryDocumentSnapshot(libroDoc);
            return _buildLibroCard(libro, libros[index].id); // Tarjeta de libro
          },
        );
      },
    );
  }

  // ESTADO VACÍO O SIN RESULTADOS
  Widget _buildEmptyState() {
    String mensaje = '';
    IconData icono = Icons.library_books;

    // MENSAJES PERSONALIZADOS SEGÚN EL ESTADO
    if (_searchQuery.isNotEmpty && _filtroEstado != 'todos') {
      mensaje = 'No se encontraron libros para "$_searchQuery" con estado "${_obtenerTextoFiltroActual()}"';
      icono = Icons.search_off;
    } else if (_searchQuery.isNotEmpty) {
      mensaje = 'No se encontraron libros para "$_searchQuery"';
      icono = Icons.search_off;
    } else if (_filtroEstado != 'todos') {
      mensaje = 'No hay libros con estado "${_obtenerTextoFiltroActual()}"';
      icono = Icons.filter_list_off;
    } else {
      mensaje = 'No hay libros en tu biblioteca';
      icono = Icons.library_books;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            mensaje,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          // BOTONES ACCIONABLES SEGÚN EL ESTADO
          if (_searchQuery.isEmpty && _filtroEstado == 'todos') ...[
            const SizedBox(height: 10),
            const Text(
              '¡Añade tu primer libro!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openAddBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Añadir primer libro'),
            ),
          ] else ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _filtroEstado = 'todos';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    );
  }

  // CONSTRUIR TARJETA INDIVIDUAL DE LIBRO
  Widget _buildLibroCard(Libro libro, String libroId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PORTADA DEL LIBRO (MÁS GRANDE)
            libro.portadaURL != null && libro.portadaURL!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      libro.portadaURL!,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.book, size: 40, color: Colors.indigo),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 80,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 40, color: Colors.indigo),
                  ),
            
            const SizedBox(width: 16),
            
            // INFORMACIÓN DEL LIBRO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  Text(
                    libro.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // AUTOR
                  Text(
                    'Por: ${libro.autor}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  // METADATOS: PÁGINAS Y ESTADO
                  Text(
                    '${libro.paginas} páginas • ${libro.estadoEnEspanol}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  // RESEÑA (SI EXISTE)
                  if (libro.resena.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📝 ${libro.resena.length > 50 ? "${libro.resena.substring(0, 50)}..." : libro.resena}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // CALIFICACIÓN CON ESTRELLAS
                  CalificacionEstrellas(
                    calificacion: libro.calificacion,
                    onCalificacionCambiada: (nuevaCalificacion) {
                      _actualizarCalificacion(libroId, nuevaCalificacion);
                    },
                    tamano: 20,
                    editable: false, // Solo lectura en la lista
                  ),
                ],
              ),
            ),
            
            // MENÚ DE OPCIONES (EDITAR/ELIMINAR)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'editar') {
                  _openEditBook(libro, libroId);
                } else if (value == 'eliminar') {
                  _eliminarLibro(libroId);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Editar', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
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