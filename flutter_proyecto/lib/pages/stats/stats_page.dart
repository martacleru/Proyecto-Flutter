// ESTADÍSTICAS DE LECTURA - Muestra métricas y progreso de lectura del usuario

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';
import '../auth/login_page.dart';
import '../admin/admin_page.dart';
import '../profile/profile_page.dart';
import '../books/biblioteca_page.dart';
import '../map/map_page.dart';
import '../../services/libro_service.dart';
import '../../../widgets/custom_drawer.dart';

class StatsPage extends StatefulWidget {
  final String usuarioId;
  final String username;
  final String imageURL;
  final String userRole;

  const StatsPage({
    super.key,
    required this.usuarioId,
    required this.username,
    required this.imageURL,
    required this.userRole,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final LibroService _libroService = LibroService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _currentPage = 'stats';
  
  Map<String, dynamic> _estadisticas = {};
  bool _cargando = true;
  List<Map<String, dynamic>> _generosData = [];
  List<Map<String, dynamic>> _estadosData = [];

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas(); // Cargar estadísticas al iniciar
  }

  // CARGAR ESTADÍSTICAS DESDE FIRESTORE
  Future<void> _cargarEstadisticas() async {
    try {
      final stats = await _libroService.obtenerEstadisticas(widget.usuarioId);
      
      // OBTENER DATOS ADICIONALES PARA ESTADÍSTICAS DETALLADAS
      final querySnapshot = await firestore
          .collection('usuarios')
          .doc(widget.usuarioId)
          .collection('libros')
          .get();

      final libros = querySnapshot.docs;
      
      // ESTADÍSTICAS POR GÉNERO
      final generosCount = <String, int>{};
      for (final doc in libros) {
        final genero = doc['genero'] ?? 'Sin género';
        generosCount[genero] = (generosCount[genero] ?? 0) + 1;
      }
      
      _generosData = generosCount.entries.map((entry) => {
        'genero': entry.key,
        'cantidad': entry.value,
        'color': _getColorForIndex(generosCount.entries.toList().indexOf(entry))
      }).toList();
      
      // ESTADÍSTICAS POR ESTADO
      _estadosData = [
        {
          'estado': 'Leídos',
          'cantidad': stats['leidos'] ?? 0,
          'color': Colors.green,
          'icon': Icons.check_circle,
        },
        {
          'estado': 'Leyendo',
          'cantidad': stats['leyendo'] ?? 0,
          'color': Colors.orange,
          'icon': Icons.autorenew,
        },
        {
          'estado': 'Por leer',
          'cantidad': stats['porLeer'] ?? 0,
          'color': Colors.blue,
          'icon': Icons.bookmark,
        },
      ];

      setState(() {
        _estadisticas = stats;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando estadísticas: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  // OBTENER COLOR ÚNICO PARA CADA GÉNERO
  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.deepOrange,
    ];
    return colors[index % colors.length];
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
        username: widget.username,
        imageURL: widget.imageURL,
        userRole: widget.userRole,
      )),
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

  void _openBiblioteca() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BibliotecaPage(
        usuarioId: widget.usuarioId,
        username: widget.username,
        imageURL: widget.imageURL,
        userRole: widget.userRole,
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

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(
        username: widget.username,
        imageURL: widget.imageURL,
      )),
    );
  }

  // TARJETA DE ESTADÍSTICA INDIVIDUAL
  Widget _buildStatCard(String titulo, String valor, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LISTA DE DISTRIBUCIÓN POR GÉNEROS
  Widget _buildGenerosList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Distribución por Género',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._generosData.map((genero) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: genero['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(genero['genero']),
                  ),
                  Text(
                    '${genero['cantidad']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // LISTA DE ESTADOS DE LECTURA
  Widget _buildEstadosList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📖 Estado de Lectura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._estadosData.map((estado) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(estado['icon'], color: estado['color']),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(estado['estado']),
                  ),
                  Text(
                    '${estado['cantidad']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: estado['color'],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // BARRA DE PROGRESO DE LECTURA
  Widget _buildProgresoLectura() {
    final total = _estadisticas['totalLibros'] ?? 0;
    final leidos = _estadisticas['leidos'] ?? 0;
    final porcentaje = total > 0 ? (leidos / total * 100) : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Progreso de Lectura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Stack(
              children: [
                // BARRA DE PROGRESO
                LinearProgressIndicator(
                  value: porcentaje / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    porcentaje >= 50 ? Colors.green : Colors.orange,
                  ),
                  minHeight: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
                // PORCENTAJE SUPERPUESTO
                if (total > 0)
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${porcentaje.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // ESTADÍSTICAS NUMÉRICAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$leidos/$total libros leídos'),
                Text('${porcentaje.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 10),
            // MENSAJE MOTIVACIONAL SEGÚN EL PROGRESO
            if (total == 0)
              const Text(
                '📚 ¡Comienza añadiendo tu primer libro!',
                style: TextStyle(color: Colors.blue),
              )
            else if (porcentaje < 25)
              const Text(
                '💪 ¡Sigue leyendo! Cada libro cuenta.',
                style: TextStyle(color: Colors.orange),
              )
            else if (porcentaje < 75)
              const Text(
                '🔥 ¡Excelente progreso! Vas por buen camino.',
                style: TextStyle(color: Colors.green),
              )
            else
              const Text(
                '🏆 ¡Eres un lector ejemplar!',
                style: TextStyle(color: Colors.purple),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // FOTO DE PERFIL EN LA APP BAR
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: CircleAvatar(
                backgroundImage: widget.imageURL.isNotEmpty
                    ? NetworkImage(widget.imageURL)
                    : null,
                child: widget.imageURL.isEmpty
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Estadísticas - ${widget.username}'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // BOTÓN ACTUALIZAR
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEstadisticas,
            tooltip: 'Actualizar estadísticas',
          ),
          // BOTÓN ADMIN SOLO PARA ADMINISTRADORES
          if (widget.userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _openAdminPanel,
              tooltip: 'Panel de Administración',
            ),
        ],
      ),
      drawer: CustomDrawer(
        currentUsername: widget.username,
        currentImageURL: widget.imageURL,
        userRole: widget.userRole,
        currentPage: _currentPage,
        parentContext: context,
        onLogout: _logout,
        onProfile: _openProfile,
        onAddBook: _openBiblioteca,
        onBookList: _openBiblioteca,
        onSearch: _openBiblioteca,
        onMap: _openMap,
        onStats: () {
          Navigator.pop(context);
        },
        onHome: _openHome,
        onAdminPanel: widget.userRole == 'admin' ? _openAdminPanel : null,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarEstadisticas, // Pull to refresh
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TARJETAS DE ESTADÍSTICAS RÁPIDAS
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600, // Ancho máximo para buen aspecto
                        ),
                        child: GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            _buildStatCard(
                              'Leídos',
                              '${_estadisticas['leidos'] ?? 0}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Leyendo',
                              '${_estadisticas['leyendo'] ?? 0}',
                              Icons.autorenew,
                              Colors.orange,
                            ),
                            _buildStatCard(
                              'Por Leer',
                              '${_estadisticas['porLeer'] ?? 0}',
                              Icons.bookmark,
                              Colors.purple,
                            ),
                            _buildStatCard(
                              'Total Libros',
                              '${_estadisticas['totalLibros'] ?? 0}',
                              Icons.library_books,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Páginas Total',
                              '${_estadisticas['totalPaginas'] ?? 0}',
                              Icons.format_list_numbered,
                              Colors.red,
                            ),
                            _buildStatCard(
                              'Calificación',
                              '${(_estadisticas['promedioCalificacion'] ?? 0).toStringAsFixed(1)}/5',
                              Icons.star,
                              Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // PROGRESO DE LECTURA
                    _buildProgresoLectura(),
                    const SizedBox(height: 20),
                    
                    // DISTRIBUCIÓN POR GÉNEROS (SI HAY DATOS)
                    if (_generosData.isNotEmpty) ...[
                      _buildGenerosList(),
                      const SizedBox(height: 20),
                    ],
                    
                    // DISTRIBUCIÓN POR ESTADOS (SI HAY DATOS)
                    if (_estadosData.isNotEmpty) ...[
                      _buildEstadosList(),
                      const SizedBox(height: 20),
                    ],
                    
                    // MENSAJE SI NO HAY LIBROS
                    if ((_estadisticas['totalLibros'] ?? 0) == 0)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.auto_stories, size: 60, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text(
                                'No hay libros en tu biblioteca',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _openBiblioteca,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Añadir primer libro'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}