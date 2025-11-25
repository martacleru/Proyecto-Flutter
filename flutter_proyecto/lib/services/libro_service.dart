// SERVICIO PARA OPERACIONES CON LIBROS - Capa de acceso a datos

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/libro_model.dart';

class LibroService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // OBTENER TODOS LOS LIBROS DE UN USUARIO
  Stream<QuerySnapshot> obtenerLibrosUsuario(String usuarioId) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .orderBy('fechaAgregado', descending: true) // Ordenar por fecha más reciente
        .snapshots(); // Stream en tiempo real
  }

  // OBTENER LIBROS POR ESTADO (leido, leyendo, por_leer)
  Stream<QuerySnapshot> obtenerLibrosPorEstado(String usuarioId, String estado) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .where('estado', isEqualTo: estado)
        .orderBy('fechaAgregado', descending: true)
        .snapshots();
  }

  // BUSCAR LIBROS POR TÍTULO O AUTOR
  Stream<QuerySnapshot> buscarLibros(String usuarioId, String query) {
    if (query.isEmpty) {
      return obtenerLibrosUsuario(usuarioId); // Si no hay query, devolver todos
    }
    
    final queryLower = query.toLowerCase(); // Búsqueda case-insensitive
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .where('tituloLower', isGreaterThanOrEqualTo: queryLower)
        .where('tituloLower', isLessThan: queryLower + 'z')
        .snapshots();
  }

  // AGREGAR UN NUEVO LIBRO A LA BIBLIOTECA
  Future<void> agregarLibro(String usuarioId, Libro libro) async {
    final libroData = libro.toMap();
    await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .add(libroData); // Crear nuevo documento
  }

  // ACTUALIZAR UN LIBRO EXISTENTE
  Future<void> actualizarLibro(String usuarioId, String libroId, Libro libro) async {
    final libroData = libro.toMap();
    await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .doc(libroId)
        .update(libroData); // Actualizar documento existente
  }

  // ACTUALIZAR SOLO LA CALIFICACIÓN (método específico)
  Future<void> actualizarCalificacion(String usuarioId, String libroId, double nuevaCalificacion) async {
    await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .doc(libroId)
        .update({
      'calificacion': nuevaCalificacion,
    });
  }

  // ELIMINAR UN LIBRO DE LA BIBLIOTECA
  Future<void> eliminarLibro(String usuarioId, String libroId) async {
    await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .doc(libroId)
        .delete();
  }

  // OBTENER UN LIBRO ESPECÍFICO POR ID
  Future<Libro?> obtenerLibro(String usuarioId, String libroId) async {
    final doc = await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('libros')
        .doc(libroId)
        .get();

    if (doc.exists) {
      return Libro.fromFirestore(doc);
    }
    return null; // Si no existe el libro
  }

  // OBTENER ESTADÍSTICAS DEL USUARIO
  Future<Map<String, dynamic>> obtenerEstadisticas(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('libros')
          .get(); // Obtener todos los libros

      final libros = querySnapshot.docs;

      // CALCULAR ESTADÍSTICAS BÁSICAS
      int totalLibros = libros.length;
      int leidos = libros.where((doc) => doc['estado'] == 'leido').length;
      int leyendo = libros.where((doc) => doc['estado'] == 'leyendo').length;
      int porLeer = libros.where((doc) => doc['estado'] == 'por_leer').length;

      int totalPaginas = 0;
      double sumaCalificaciones = 0;
      int librosCalificados = 0;

      // PROCESAR CADA LIBRO PARA MÉTRICAS DETALLADAS
      for (final doc in libros) {
        final data = doc.data();

        // SUMAR PÁGINAS (maneja diferentes tipos de datos)
        if (data['paginas'] != null) {
          final paginas = data['paginas'];
          if (paginas is num) {
            totalPaginas += paginas.toInt();
          } else if (paginas is String) {
            totalPaginas += int.tryParse(paginas) ?? 0;
          }
        }

        // CALCULAR CALIFICACIÓN PROMEDIO
        if (data['calificacion'] != null) {
          final calif = data['calificacion'];
          double valor = 0.0;

          if (calif is num) {
            valor = calif.toDouble();
          } else if (calif is String) {
            valor = double.tryParse(calif) ?? 0.0;
          }

          if (valor > 0) {
            sumaCalificaciones += valor;
            librosCalificados++;
          }
        }
      }

      // CALCULAR PROMEDIO FINAL
      double promedioCalificacion = librosCalificados > 0
          ? sumaCalificaciones / librosCalificados
          : 0.0;

      return {
        'totalLibros': totalLibros,
        'leidos': leidos,
        'leyendo': leyendo,
        'porLeer': porLeer,
        'totalPaginas': totalPaginas,
        'promedioCalificacion': promedioCalificacion,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      throw Exception('Error al cargar las estadísticas: $e');
    }
  }
}