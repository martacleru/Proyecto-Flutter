// PANTALLA DE REGISTRO - Crea nuevas cuentas de usuario

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // CONTROLADORES PARA LOS CAMPOS DEL FORMULARIO
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  String errorMessage = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // FOCUS NODES PARA NAVEGACIÓN CON ENTER
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _ubicacionFocusNode = FocusNode();
  final FocusNode _imageFocusNode = FocusNode();

  // MÉTODO DE REGISTRO PRINCIPAL
  Future<void> _registerUser() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String email = emailController.text.trim();
    String telefono = telefonoController.text.trim();
    String ubicacion = ubicacionController.text.trim();
    String imageURL = imageController.text.trim();

    // VALIDAR CAMPOS OBLIGATORIOS
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      setState(() => errorMessage = 'Rellena los campos obligatorios (*)');
      return;
    }

    // VALIDAR FORMATO DE EMAIL
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => errorMessage = 'Ingresa un email válido');
      return;
    }

    try {
      // VERIFICAR SI EL USUARIO YA EXISTE
      var existing = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: username)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => errorMessage = 'El usuario ya existe');
        return;
      }

      // VERIFICAR SI EL EMAIL YA EXISTE
      var existingEmail = await firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (existingEmail.docs.isNotEmpty) {
        setState(() => errorMessage = 'El email ya está registrado');
        return;
      }

      // CREAR NUEVO USUARIO EN FIRESTORE
      await firestore.collection('usuarios').add({
        'nombreUsuario': username,
        'password': password,
        'email': email,
        'telefono': telefono,
        'ubicacion': ubicacion,
        'rol': 'usuario', // Rol por defecto
        'imageURL': imageURL,
      });

      // OBTENER EL USUARIO RECIÉN CREADO Y NAVEGAR A HOME
      var snapshot = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: username)
          .limit(1)
          .get();

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
      }
    } catch (e) {
      setState(() => errorMessage = 'Error al registrar: ${e.toString()}');
    }
  }

  // MANEJADORES DE NAVEGACIÓN CON ENTER ENTRE CAMPOS
  void _handleUsernameEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
    }
  }

  void _handlePasswordEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    }
  }

  void _handleEmailEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_telefonoFocusNode);
    }
  }

  void _handleTelefonoEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_ubicacionFocusNode);
    }
  }

  void _handleUbicacionEnter(String value) {
    if (value.isNotEmpty) {
      FocusScope.of(context).requestFocus(_imageFocusNode);
    }
  }

  void _handleImageEnter(String value) {
    if (usernameController.text.isNotEmpty && 
        passwordController.text.isNotEmpty && 
        emailController.text.isNotEmpty) {
      _registerUser(); // Registro automático al finalizar
    }
  }

  @override
  void dispose() {
    // LIMPIAR RECURSOS
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _ubicacionFocusNode.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                  'Registrar usuario',
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
                    labelText: 'Usuario *',
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
                    labelText: 'Contraseña *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: _handlePasswordEnter,
                ),
                const SizedBox(height: 15),
                // CAMPO DE EMAIL
                TextField(
                  controller: emailController,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: _handleEmailEnter,
                ),
                const SizedBox(height: 15),
                // CAMPO DE TELÉFONO (OPCIONAL)
                TextField(
                  controller: telefonoController,
                  focusNode: _telefonoFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: _handleTelefonoEnter,
                ),
                const SizedBox(height: 15),
                // CAMPO DE UBICACIÓN (OPCIONAL)
                TextField(
                  controller: ubicacionController,
                  focusNode: _ubicacionFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: _handleUbicacionEnter,
                ),
                const SizedBox(height: 15),
                // CAMPO DE IMAGEN (OPCIONAL)
                TextField(
                  controller: imageController,
                  focusNode: _imageFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'URL de la imagen (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: _handleImageEnter,
                ),
                const SizedBox(height: 20),
                // BOTÓN DE REGISTRO
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _registerUser,
                  child: const Text('Registrar'),
                ),
                const SizedBox(height: 10),
                // ENLACE A LOGIN
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Volver al login
                  },
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // MENSAJE DE ERROR/ÉXITO
                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: errorMessage.contains('✅')
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // INDICADOR DE CAMPOS OBLIGATORIOS
                Text(
                  '* Campos obligatorios',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}