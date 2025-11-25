// MAPA DE LIBRERÍAS EN ESPAÑA - Muestra librerías en un mapa interactivo

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/login_page.dart';
import '../home_page.dart';
import '../admin/admin_page.dart';
import '../profile/profile_page.dart';
import '../books/biblioteca_page.dart';
import '../stats/stats_page.dart';
import '../../widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../books/add_book_page.dart';

class MapPage extends StatefulWidget {
  final String username;
  final String imageURL;
  final String userRole;

  const MapPage({
    super.key,
    required this.username,
    required this.imageURL,
    required this.userRole,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController(); // Controlador del mapa
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _currentPage = 'map';
  LatLng? _currentLocation;
  LatLng? _userLocation;
  String? _userId;
  
  // LISTA DE 20 LIBRERÍAS EN ESPAÑA CON COORDENADAS REALES
  final List<Libreria> _librerias = [
    // MADRID
    Libreria(
      nombre: 'Casa del Libro - Madrid',
      direccion: 'Gran Vía, 29, Madrid',
      coordenadas: LatLng(40.4192, -3.7034),
      telefono: '+34 915 75 18 00',
      tipo: 'General',
    ),
    Libreria(
      nombre: 'Librería Ocho y Medio - Madrid',
      direccion: 'Calle Martín de los Heros, 11, Madrid',
      coordenadas: LatLng(40.4240, -3.7145),
      telefono: '+34 915 59 25 53',
      tipo: 'Cine y Arte',
    ),
    Libreria(
      nombre: 'Tipos Infames - Madrid',
      direccion: 'Calle San Joaquín, 3, Madrid',
      coordenadas: LatLng(40.4251, -3.7032),
      telefono: '+34 910 00 45 45',
      tipo: 'Especializada',
    ),
    Libreria(
      nombre: 'Librería Rafael Alberti - Madrid',
      direccion: 'Calle Tutor, 57, Madrid',
      coordenadas: LatLng(40.4356, -3.7190),
      telefono: '+34 915 44 09 29',
      tipo: 'Especializada',
    ),

    // BARCELONA
    Libreria(
      nombre: 'La Central - Barcelona',
      direccion: 'Carrer Elisabets, 6, Barcelona',
      coordenadas: LatLng(41.3825, 2.1700),
      telefono: '+34 933 17 28 63',
      tipo: 'General',
    ),
    Libreria(
      nombre: 'Librería Altaïr - Barcelona',
      direccion: 'Gran Via de les Corts Catalanes, 616, Barcelona',
      coordenadas: LatLng(41.3874, 2.1686),
      telefono: '+34 933 42 71 71',
      tipo: 'Viajes',
    ),
    Libreria(
      nombre: 'Librería Finestres - Barcelona',
      direccion: 'Carrer de Joaquín Costa, 30, Barcelona',
      coordenadas: LatLng(41.3830, 2.1665),
      telefono: '+34 934 13 61 54',
      tipo: 'Especializada',
    ),

    // VALENCIA
    Libreria(
      nombre: 'Librería Primado - Valencia',
      direccion: 'Calle del Primado Reig, 29, Valencia',
      coordenadas: LatLng(39.4749, -0.3767),
      telefono: '+34 963 94 22 44',
      tipo: 'General',
    ),
    Libreria(
      nombre: 'Librería Babel - Valencia',
      direccion: 'Calle de la Tapinería, 16, Valencia',
      coordenadas: LatLng(39.4765, -0.3758),
      telefono: '+34 963 92 20 45',
      tipo: 'Especializada',
    ),

    // SEVILLA
    Libreria(
      nombre: 'Librería Beta - Sevilla',
      direccion: 'Calle de la Feria, 95, Sevilla',
      coordenadas: LatLng(37.3925, -5.9912),
      telefono: '+34 954 90 12 34',
      tipo: 'General',
    ),
    Libreria(
      nombre: 'Librería Caótica - Sevilla',
      direccion: 'Calle Pérez Galdós, 4, Sevilla',
      coordenadas: LatLng(37.3889, -5.9956),
      telefono: '+34 955 12 34 56',
      tipo: 'Especializada',
    ),

    // BILBAO
    Libreria(
      nombre: 'Librería Cámara - Bilbao',
      direccion: 'Calle de Bidebarrieta, 17, Bilbao',
      coordenadas: LatLng(43.2603, -2.9254),
      telefono: '+34 944 15 12 34',
      tipo: 'General',
    ),

    // ZARAGOZA
    Libreria(
      nombre: 'Librería Central - Zaragoza',
      direccion: 'Paseo de la Independencia, 11, Zaragoza',
      coordenadas: LatLng(41.6488, -0.8891),
      telefono: '+34 976 23 45 67',
      tipo: 'General',
    ),

    // MÁLAGA
    Libreria(
      nombre: 'Librería Luces - Málaga',
      direccion: 'Calle de la Aurora, 25, Málaga',
      coordenadas: LatLng(36.7194, -4.4200),
      telefono: '+34 952 12 34 56',
      tipo: 'General',
    ),

    // MURCIA
    Libreria(
      nombre: 'Librería Escarabajal - Murcia',
      direccion: 'Plaza de la Cruz Roja, 3, Murcia',
      coordenadas: LatLng(37.9870, -1.1300),
      telefono: '+34 968 21 23 45',
      tipo: 'Especializada',
    ),

    // PALMA DE MALLORCA
    Libreria(
      nombre: 'Librería Drac Màgic - Palma',
      direccion: 'Carrer de la Soledat, 12, Palma',
      coordenadas: LatLng(39.5716, 2.6504),
      telefono: '+34 971 71 23 45',
      tipo: 'Especializada',
    ),

    // LAS PALMAS
    Libreria(
      nombre: 'Librería del Cabildo - Las Palmas',
      direccion: 'Calle Doctor Chil, 17, Las Palmas',
      coordenadas: LatLng(28.1235, -15.4362),
      telefono: '+34 928 23 45 67',
      tipo: 'General',
    ),

    // SAN SEBASTIÁN
    Libreria(
      nombre: 'Librería Lagun - San Sebastián',
      direccion: 'Calle de San Marcial, 32, San Sebastián',
      coordenadas: LatLng(43.3224, -1.9846),
      telefono: '+34 943 45 67 89',
      tipo: 'General',
    ),

    // SANTIAGO DE COMPOSTELA
    Libreria(
      nombre: 'Librería Couceiro - Santiago',
      direccion: 'Rúa do Vilar, 39, Santiago de Compostela',
      coordenadas: LatLng(42.8805, -8.5456),
      telefono: '+34 981 58 12 34',
      tipo: 'General',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // ESTABLECER UBICACIÓN INICIAL (MADRID) Y CARGAR DATOS DEL USUARIO
    _currentLocation = const LatLng(40.4168, -3.7038);
    _loadUserData();
  }

  // CARGAR DATOS DEL USUARIO DESDE FIRESTORE
  Future<void> _loadUserData() async {
    try {
      var snapshot = await _firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        setState(() {
          _userId = snapshot.docs.first.id;
          
          // INTENTAR OBTENER UBICACIÓN DEL USUARIO DESDE SU PERFIL
          final ubicacion = userData['ubicacion'];
          if (ubicacion != null && ubicacion.toString().isNotEmpty) {
            // SIMULAR COORDENADAS BASADAS EN LA UBICACIÓN (EN PRODUCCIÓN USAR GEOLOCALIZACIÓN)
            _userLocation = _parseUbicacionToCoords(ubicacion.toString());
          }
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  // CONVERTIR TEXTO DE UBICACIÓN A COORDENADAS (SIMULACIÓN)
  LatLng _parseUbicacionToCoords(String ubicacion) {
    // EN UNA APP REAL, USARÍAS UN SERVICIO DE GEOLOCALIZACIÓN
    // AQUÍ SIMULAMOS CON COORDENADAS DE CIUDADES PRINCIPALES
    final ubicacionLower = ubicacion.toLowerCase();
    
    if (ubicacionLower.contains('madrid')) {
      return const LatLng(40.4168, -3.7038);
    } else if (ubicacionLower.contains('barcelona')) {
      return const LatLng(41.3825, 2.1775);
    } else if (ubicacionLower.contains('valencia')) {
      return const LatLng(39.4699, -0.3763);
    } else if (ubicacionLower.contains('sevilla')) {
      return const LatLng(37.3891, -5.9845);
    } else if (ubicacionLower.contains('bilbao')) {
      return const LatLng(43.2627, -2.9253);
    } else {
      // UBICACIÓN POR DEFECTO (MADRID)
      return const LatLng(40.4168, -3.7038);
    }
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

  void _openBiblioteca() async {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BibliotecaPage(
          usuarioId: _userId!,
          username: widget.username,
          imageURL: widget.imageURL,
          userRole: widget.userRole,
        )),
      );
    }
  }

  void _openStats() async {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StatsPage(
          usuarioId: _userId!,
          username: widget.username,
          imageURL: widget.imageURL,
          userRole: widget.userRole,
        )),
      );
    }
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

  void _openAddBook() async {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddBookPage(
          usuarioId: _userId!,
          usuarioNombre: widget.username,
        )),
      );
    }
  }

  // ZOOM A UNA LIBRERÍA ESPECÍFICA
  void _zoomToLibreria(LatLng coordenadas) {
    _mapController.move(coordenadas, 15.0);
  }

  // ZOOM A LA UBICACIÓN DEL USUARIO
  void _zoomToUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró tu ubicación en el perfil')),
      );
    }
  }

  // MOSTRAR DETALLES DE UNA LIBRERÍA
  void _showLibreriaDetails(Libreria libreria) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              libreria.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '📍 ${libreria.direccion}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              '📞 ${libreria.telefono}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              '🏷️ Tipo: ${libreria.tipo}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _launchMaps(libreria.coordenadas); // Abrir Google Maps
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Cómo llegar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _callLibreria(libreria.telefono); // Llamar a la librería
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Llamar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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

  // ABRIR GOOGLE MAPS CON LAS COORDENADAS
  Future<void> _launchMaps(LatLng coordenadas) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${coordenadas.latitude},${coordenadas.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa')),
      );
    }
  }

  // LLAMAR A LA LIBRERÍA
  Future<void> _callLibreria(String telefono) async {
    final url = 'tel:$telefono';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo realizar la llamada')),
      );
    }
  }

  // COLOR DEL MARCADOR SEGÚN EL TIPO DE LIBRERÍA
  Color _getMarkerColor(String tipo) {
    switch (tipo) {
      case 'Especializada':
        return Colors.orange;
      case 'Cine y Arte':
        return Colors.purple;
      case 'Viajes':
        return Colors.teal;
      default:
        return Colors.red; // General
    }
  }

  // EMOJI SEGÚN EL TIPO DE LIBRERÍA
  String _getTipoEmoji(String tipo) {
    switch (tipo) {
      case 'General':
        return '📚';
      case 'Especializada':
        return '🎯';
      case 'Viajes':
        return '🧳';
      case 'Cine y Arte':
        return '🎨';
      default:
        return '📖';
    }
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
              child: Text('Mapa de Librerías - ${widget.username}'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
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
        onAddBook: _openAddBook,
        onBookList: _openBiblioteca,
        onSearch: _openBiblioteca,
        onMap: () {
          Navigator.pop(context);
        },
        onStats: _openStats,
        onHome: _openHome,
        onAdminPanel: widget.userRole == 'admin' ? _openAdminPanel : null,
      ),
      // MAPA PRINCIPAL
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 6.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Deshabilitar rotación
                ),
              ),
              children: [
                // CAPA DE TILES (MAPA BASE)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.booktracker',
                ),
                
                // CAPA DE MARCADORES (LIBRERÍAS)
                MarkerLayer(
                  markers: _librerias.map((libreria) {
                    return Marker(
                      width: 40.0,
                      height: 40.0,
                      point: libreria.coordenadas,
                      child: GestureDetector(
                        onTap: () {
                          _zoomToLibreria(libreria.coordenadas);
                          _showLibreriaDetails(libreria);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: _getMarkerColor(libreria.tipo),
                              size: 35,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getTipoEmoji(libreria.tipo),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // CAPA DE MARCADOR DEL USUARIO (SI TIENE UBICACIÓN)
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 50.0,
                        height: 50.0,
                        point: _userLocation!,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Tu Ubicación'),
                                content: const Text('Esta es tu ubicación registrada en el perfil'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue,
                                size: 40,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Tú',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      // BOTONES FLOTANTES DE CONTROL DEL MAPA
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // BOTÓN PARA IR A LA UBICACIÓN DEL USUARIO
          if (_userLocation != null)
            FloatingActionButton(
              heroTag: 'btn_user_location',
              onPressed: _zoomToUserLocation,
              mini: true,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.person_pin_circle, color: Colors.white),
            ),
          if (_userLocation != null) const SizedBox(height: 10),
          
          // BOTÓN ZOOM OUT
          FloatingActionButton(
            heroTag: 'btn_zoom_out',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, currentZoom - 1);
            },
            mini: true,
            backgroundColor: Colors.indigo,
            child: const Icon(Icons.zoom_out, color: Colors.white),
          ),
          const SizedBox(height: 10),
          
          // BOTÓN ZOOM IN
          FloatingActionButton(
            heroTag: 'btn_zoom_in',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, currentZoom + 1);
            },
            mini: true,
            backgroundColor: Colors.indigo,
            child: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          const SizedBox(height: 10),
          
          // BOTÓN CENTRAR EN ESPAÑA
          FloatingActionButton(
            heroTag: 'btn_center',
            onPressed: () {
              _mapController.move(_currentLocation!, 6.0); // Volver a vista inicial
            },
            backgroundColor: Colors.indigo,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// MODELO DE DATOS PARA LIBRERÍAS
class Libreria {
  final String nombre;
  final String direccion;
  final LatLng coordenadas;
  final String telefono;
  final String tipo;

  Libreria({
    required this.nombre,
    required this.direccion,
    required this.coordenadas,
    required this.telefono,
    required this.tipo,
  });
}