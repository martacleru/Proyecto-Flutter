// PANTALLA DE INICIO - Dashboard principal con resumen y acciones rápidas

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/login_page.dart';
import 'admin/admin_page.dart';
import 'profile/profile_page.dart';
import 'books/biblioteca_page.dart';
import 'books/add_book_page.dart';
import 'map/map_page.dart';
import 'stats/stats_page.dart';
import '../models/libro_model.dart';
import '../services/libro_service.dart';
import '../widgets/calificacion_estrellas.dart';
import '../widgets/custom_drawer.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String imageURL;

  const HomePage({super.key, required this.username, required this.imageURL});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final LibroService _libroService = LibroService();
  String userRole = 'usuario';
  String currentUsername = '';
  String currentImageURL = '';
  
  final ScrollController _scrollController = ScrollController();
  String _currentPage = 'home';

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
    currentImageURL = widget.imageURL;
    _getUserRole(); // Obtener rol del usuario
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // OBTENER ROL DEL USUARIO DESDE FIRESTORE
  Future<void> _getUserRole() async {
    try {
      var snapshot = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userRole = snapshot.docs.first.data()['rol'] ?? 'usuario';
        });
      }
    } catch (e) {
      print('Error al obtener rol: $e');
    }
  }

  // OBTENER ID DEL USUARIO ACTUAL
  Future<String?> _getUserId() async {
    try {
      var snapshot = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: currentUsername)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
    } catch (e) {
      print('Error al obtener userId: $e');
    }
    return null;
  }

  // MÉTODOS DE NAVEGACIÓN
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminPage(
        username: currentUsername,
        imageURL: currentImageURL,
        userRole: userRole,
      )),
    );
  }

  void _openProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          username: currentUsername,
          imageURL: currentImageURL,
          firestore: FirebaseFirestore.instance,
        ),
      ),
    );

    // ACTUALIZAR DATOS SI SE MODIFICARON EN EL PERFIL
    if (result != null) {
      setState(() {
        currentUsername = result['username'] ?? currentUsername;
        currentImageURL = result['imageURL'] ?? currentImageURL;
      });
    }
  }

  void _openBiblioteca() async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BibliotecaPage(
          usuarioId: userId,
          username: currentUsername,
          imageURL: currentImageURL,
          userRole: userRole,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de usuario')),
      );
    }
  }

  void _openAddBook() async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddBookPage(
          usuarioId: userId,
          usuarioNombre: currentUsername,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de usuario')),
      );
    }
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPage(
        username: currentUsername,
        imageURL: currentImageURL,
        userRole: userRole,
      )),
    );
  }

  void _openStats() async {
    final userId = await _getUserId();
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StatsPage(
          usuarioId: userId,
          username: currentUsername,
          imageURL: currentImageURL,
          userRole: userRole,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de usuario')),
      );
    }
  }

  // ACTUALIZAR CALIFICACIÓN DE UN LIBRO
  void _actualizarCalificacionLibro(String libroId, double nuevaCalificacion) async {
    final userId = await _getUserId();
    if (userId != null) {
      try {
        await _libroService.actualizarCalificacion(userId, libroId, nuevaCalificacion);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calificacion actualizada: ${nuevaCalificacion.toStringAsFixed(1)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // CONFIRMACIÓN DE CERRAR SESIÓN
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // FOTO DE PERFIL ENCIMA DEL NOMBRE
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: CircleAvatar(
                backgroundImage: currentImageURL.isNotEmpty
                    ? NetworkImage(currentImageURL)
                    : null,
                child: currentImageURL.isEmpty
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(currentUsername),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          // BOTÓN DE ADMIN SOLO PARA ADMINISTRADORES
          if (userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _openAdminPanel,
              tooltip: 'Panel de Administración',
            ),
          // BOTÓN DE CERRAR SESIÓN
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      // DRAWER DE NAVEGACIÓN
      drawer: CustomDrawer(
        currentUsername: currentUsername,
        currentImageURL: currentImageURL,
        userRole: userRole,
        currentPage: _currentPage,
        parentContext: context,
        onLogout: _logout,
        onProfile: _openProfile,
        onAddBook: _openAddBook,
        onBookList: _openBiblioteca,
        onSearch: _openBiblioteca,
        onMap: _openMap,
        onStats: _openStats,
        onHome: () {
          Navigator.pop(context);
        },
        onAdminPanel: userRole == 'admin' ? _openAdminPanel : null,
      ),
      body: _buildHomeContent(),
    );
  }

  // CONSTRUIR CONTENIDO PRINCIPAL DEL HOME
  Widget _buildHomeContent() {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = snapshot.data;
        if (userId == null) {
          return const Center(child: Text('Error al cargar datos'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Recargar datos
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SALUDO PERSONALIZADO
                  Text(
                    'Hola, $currentUsername! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bienvenido a tu biblioteca personal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // DISEÑO RESPONSIVE: COLUMNAS PARA TABLET, UNA COLUMNA PARA MÓVIL
                  if (MediaQuery.of(context).size.width > 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildLeftColumn(userId), // Lista de libros
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildQuickActions(), // Acciones rápidas
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildLeftColumn(userId),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // COLUMNA IZQUIERDA: LISTA DE LIBROS RECIENTES
  Widget _buildLeftColumn(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 Mis Libros',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: StreamBuilder<QuerySnapshot>(
            stream: _libroService.obtenerLibrosUsuario(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyLibrary(); // Biblioteca vacía
              }

              final libros = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: libros.length,
                itemBuilder: (context, index) {
                  final libroDoc = libros[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
                  final libro = Libro.fromQueryDocumentSnapshot(libroDoc);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PORTADA DEL LIBRO
                          Container(
                            width: 70,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: libro.portadaURL != null && libro.portadaURL!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      libro.portadaURL!,
                                      width: 70,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.book, size: 35, color: Colors.indigo);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.book, size: 35, color: Colors.indigo),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // INFORMACIÓN DEL LIBRO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TÍTULO
                                Text(
                                  libro.titulo,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // AUTOR
                                Text(
                                  libro.autor,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // ESTADO Y CALIFICACIÓN
                                Row(
                                  children: [
                                    _buildStatusBadge(libro.estado),
                                    const Spacer(),
                                    CalificacionEstrellas(
                                      calificacion: libro.calificacion,
                                      onCalificacionCambiada: (nuevaCalificacion) {
                                        _actualizarCalificacionLibro(libro.id!, nuevaCalificacion);
                                      },
                                      tamano: 25,
                                      editable: false,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // PANEL DE ACCIONES RÁPIDAS
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Acciones Rapidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildActionButton(
                  'Añadir Libro',
                  Icons.add,
                  Colors.green,
                  _openAddBook,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Mi Biblioteca',
                  Icons.library_books,
                  Colors.blue,
                  _openBiblioteca,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Ver Estadísticas',
                  Icons.bar_chart,
                  Colors.purple,
                  _openStats,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Ver Mapa',
                  Icons.map,
                  Colors.orange,
                  _openMap,
                ),
                // ACCIÓN SOLO PARA ADMINISTRADORES
                if (userRole == 'admin') ...[
                  const SizedBox(height: 8),
                  _buildActionButton(
                    'Administrar Usuarios',
                    Icons.people,
                    Colors.red,
                    _openAdminPanel,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // BOTÓN DE ACCIÓN RÁPIDA
  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      )),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // BADGE DE ESTADO DEL LIBRO
  Widget _buildStatusBadge(String estado) {
    Color color;
    String text;
    
    switch (estado) {
      case 'leido':
        color = Colors.green;
        text = 'Leido';
        break;
      case 'leyendo':
        color = Colors.orange;
        text = 'Leyendo';
        break;
      default:
        color = Colors.blue;
        text = 'Por leer';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // VISTA PARA BIBLIOTECA VACÍA
  Widget _buildEmptyLibrary() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'Tu biblioteca esta vacia',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: _openAddBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Añadir primer libro'),
          ),
        ],
      ),
    );
  }
}