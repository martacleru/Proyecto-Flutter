// PUNTO DE ENTRADA PRINCIPAL DE LA APLICACIÓN
// Configura Firebase y lanza la aplicación Flutter

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth/login_page.dart';

Future<void> main() async {
  // Inicialización de Firebase antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBm4mR-tsoAPiFCGNBb3YPljqOqQ9uLVZc",
        authDomain: "login-6e333.firebaseapp.com",
        projectId: "login-6e333",
        storageBucket: "login-6e333.firebasestorage.app",
        messagingSenderId: "27076951455",
        appId: "1:27076951455:web:7ee7a20480775028da51aa"
    ),
  );

  runApp(const MyApp()); // Lanza la aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookTracker - Tu Biblioteca Personal',
      debugShowCheckedModeBanner: false, // Oculta la banda de debug
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Tema principal color índigo
      ),
      home: const LoginPage(), // Pantalla inicial: Login
    );
  }
}