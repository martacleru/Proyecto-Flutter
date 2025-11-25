// BÚSQUEDA DE LIBROS - Busca libros en la biblioteca por título o autor

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/libro_model.dart';
import '../../services/libro_service.dart';
import '../../widgets/custom_drawer.dart';
import '../auth/login_page.dart';
import '../home_page.dart';
import '../map/map_page.dart';
import '../admin/admin_page.dart';
import '../profile/profile_page.dart';

class SearchPage extends StatefulWidget {
  final String usuarioId;
  final String username;
  final String imageURL;
  final String userRole;

  const SearchPage({
    super.key, 
    required this.usuarioId,
    required this.username,
    required this.imageURL,
    required this.userRole,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final LibroService _libroService = LibroService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentPage = 'search';

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

  // COLOR DEL BADGE DE ESTADO
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'leido':
        return Colors.green;
      case 'leyendo':
        return Colors.orange;
      case 'por_leer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Libros'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: CustomDrawer(
        currentUsername: widget.username,
        currentImageURL: widget.imageURL,
        userRole: widget.userRole,
        currentPage: _currentPage,
        parentContext: context,
        onLogout: _logout,
        onProfile: _openProfile,
        onAddBook: () {
          Navigator.pop(context);
        },
        onBookList: () {
          Navigator.pop(context);
        },
        onSearch: () {
          Navigator.pop(context);
        },
        onMap: _openMap,
        onStats: () {},
        onHome: _openHome,
        onAdminPanel: widget.userRole == 'admin' ? _openAdminPanel : null,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Padding(
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
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(
                    // ESTADO INICIAL: SIN BÚSQUEDA
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'Busca libros en tu biblioteca',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    // STREAM DE RESULTADOS DE BÚSQUEDA
                    stream: _libroService.buscarLibros(widget.usuarioId, _searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          // SIN RESULTADOS
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book, size: 60, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('No se encontraron libros'),
                            ],
                          ),
                        );
                      }

                      final libros = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: libros.length,
                        itemBuilder: (context, index) {
                          final libroDoc = libros[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
                          final libro = Libro.fromQueryDocumentSnapshot(libroDoc);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: libro.portadaURL != null && libro.portadaURL!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        libro.portadaURL!,
                                        width: 40,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 40,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.book, size: 24, color: Colors.indigo),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.book, size: 24, color: Colors.indigo),
                                    ),
                              title: Text(
                                libro.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Por: ${libro.autor}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${libro.paginas} páginas • ${libro.estadoEnEspanol}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getEstadoColor(libro.estado),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  libro.estadoEnEspanol,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}