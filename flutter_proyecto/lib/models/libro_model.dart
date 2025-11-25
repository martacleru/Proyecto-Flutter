// MODELO DE DATOS PARA LIBROS - Define la estructura de un libro

import 'package:cloud_firestore/cloud_firestore.dart';

class Libro {
  String? id; // ID del documento en Firestore
  String titulo; // Título del libro
  String autor; // Autor del libro
  double calificacion; // Calificación de 0 a 5
  String resena; // Reseña personal del usuario
  int paginas; // Número de páginas
  String estado; // Estado: 'por_leer', 'leyendo', 'leido'
  String genero; // Género literario
  String? portadaURL; // URL de la imagen de portada (opcional)
  DateTime? fechaLectura; // Fecha cuando se marcó como leído
  DateTime fechaAgregado; // Fecha cuando se agregó a la biblioteca

  Libro({
    this.id,
    required this.titulo,
    required this.autor,
    this.calificacion = 0.0,
    this.resena = '',
    required this.paginas,
    required this.estado,
    required this.genero,
    this.portadaURL,
    this.fechaLectura,
    required this.fechaAgregado,
  });

  // Convierte el objeto Libro a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'autor': autor,
      'calificacion': calificacion,
      'resena': resena,
      'paginas': paginas,
      'estado': estado,
      'genero': genero,
      'portadaURL': portadaURL,
      'fechaLectura': fechaLectura,
      'fechaAgregado': fechaAgregado,
      'tituloLower': titulo.toLowerCase(), // Para búsquedas case-insensitive
      'autorLower': autor.toLowerCase(), // Para búsquedas case-insensitive
    };
  }

  // Constructor desde DocumentSnapshot de Firestore
  factory Libro.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Libro(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      resena: data['resena'] ?? '',
      paginas: (data['paginas'] ?? 0).toInt(),
      estado: data['estado'] ?? 'por_leer',
      genero: data['genero'] ?? 'General',
      portadaURL: data['portadaURL'],
      fechaLectura: data['fechaLectura']?.toDate(),
      fechaAgregado: (data['fechaAgregado'] as Timestamp).toDate(),
    );
  }

  // Constructor desde QueryDocumentSnapshot
  factory Libro.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Libro(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      resena: data['resena'] ?? '',
      paginas: (data['paginas'] ?? 0).toInt(),
      estado: data['estado'] ?? 'por_leer',
      genero: data['genero'] ?? 'General',
      portadaURL: data['portadaURL'],
      fechaLectura: data['fechaLectura']?.toDate(),
      fechaAgregado: (data['fechaAgregado'] as Timestamp).toDate(),
    );
  }

  // Propiedad computada: calificación en formato de estrellas
  String get calificacionEstrellas {
    if (calificacion == 0) return '☆☆☆☆☆';
    
    String estrellas = '';
    for (int i = 1; i <= 5; i++) {
      if (i <= calificacion) {
        estrellas += '⭐';
      } else if (i - 0.5 <= calificacion) {
        estrellas += '½';
      } else {
        estrellas += '☆';
      }
    }
    return estrellas;
  }

  // Propiedad computada: estado en español
  String get estadoEnEspanol {
    switch (estado) {
      case 'leido':
        return 'Leído';
      case 'leyendo':
        return 'Leyendo';
      case 'por_leer':
        return 'Por leer';
      default:
        return estado;
    }
  }

  // Propiedad computada: texto de calificación
  String get calificacionTexto {
    if (calificacion == 0) return 'Sin calificar';
    return '${calificacion.toStringAsFixed(1)}/5.0';
  }
}