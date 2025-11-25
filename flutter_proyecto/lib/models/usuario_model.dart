// MODELO DE DATOS PARA USUARIOS - Define la estructura de un usuario

import 'package:cloud_firestore/cloud_firestore.dart'; // Import para Firestore

class Usuario {
  final String id; // ID único del usuario
  final String nombreUsuario; // Nombre de usuario para login
  final String email; // Email del usuario
  final String? telefono; // Teléfono (opcional)
  final String? ubicacion; // Ubicación (opcional)
  final String? urlImagen; // URL de la imagen de perfil
  final String rol; // Rol: 'usuario' o 'admin'

  Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    this.telefono,
    this.ubicacion,
    this.urlImagen,
    this.rol = 'usuario', // Valor por defecto: usuario
  });

  // Convierte el objeto Usuario a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombreUsuario': nombreUsuario,
      'email': email,
      'telefono': telefono ?? '',
      'ubicacion': ubicacion ?? '',
      'urlImagen': urlImagen ?? '',
      'rol': rol,
    };
  }

  // Constructor desde DocumentSnapshot de Firestore
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'],
      ubicacion: data['ubicacion'],
      urlImagen: data['urlImagen'],
      rol: data['rol'] ?? 'usuario',
    );
  }
}