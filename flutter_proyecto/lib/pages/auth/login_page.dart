// PANTALLA DE INICIO DE SESIÓN - Autentica usuarios existentes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = ''; // Mensaje de error para el usuario

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FocusNode _passwordFocusNode = FocusNode(); // Para navegación con Enter

  // MÉTODO DE LOGIN PRINCIPAL
  Future<void> _loginUser() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // VALIDACIÓN DE CAMPOS VACÍOS
    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Completa todos los campos');
      return;
    }

    try {
      // BUSCAR USUARIO EN FIRESTORE
      var snapshot = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: username)
          .where('password', isEqualTo: password) // ⚠️ En producción usar auth
          .limit(1)
          .get();

      // SI EXISTE EL USUARIO, NAVEGAR A HOME
      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              username: userData['nombreUsuario'],
              imageURL: userData['imageURL'] ?? '',
            ),
          ),
        );
      } else {
        setState(() => errorMessage = 'Usuario o contraseña incorrectos');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: ${e.toString()}');
    }
  }

  // MANEJADORES DE NAVEGACIÓN CON ENTER
  void _handleUsernameEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_passwordFocusNode); // Ir a contraseña
    }
  }

  void _handlePasswordEnter(String value) {
    if (value.isNotEmpty) {
      _loginUser(); // Intentar login automáticamente
    }
  }

  // ABRIR PANTALLA DE REGISTRO
  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // CAMPO DE USUARIO
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: _handleUsernameEnter,
                ),
                const SizedBox(height: 15),
                // CAMPO DE CONTRASEÑA
                TextField(
                  controller: passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Oculta el texto
                  textInputAction: TextInputAction.go,
                  onSubmitted: _handlePasswordEnter,
                ),
                const SizedBox(height: 20),
                // BOTÓN DE LOGIN
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _loginUser,
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 10),
                // ENLACE A REGISTRO
                TextButton(
                  onPressed: _openRegister,
                  child: const Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // MENSAJE DE ERROR
                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}