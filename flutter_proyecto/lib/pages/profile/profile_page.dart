// PERFIL DE USUARIO - Edición de información personal del usuario

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';
import '../auth/login_page.dart';
import '../admin/admin_page.dart';
import '../books/biblioteca_page.dart';
import '../map/map_page.dart';
import '../../widgets/custom_drawer.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String imageURL;
  final FirebaseFirestore firestore;

  const ProfilePage({
    super.key,
    required this.username,
    required this.imageURL,
    required this.firestore,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // CONTROLADORES PARA LOS CAMPOS DEL FORMULARIO
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  late TextEditingController imageController;
  late TextEditingController telefonoController;
  late TextEditingController ubicacionController;
  
  String docId = ''; // ID del documento del usuario en Firestore
  String _currentPage = 'profile';
  String userRole = 'usuario';
  
  // FOCUS NODES PARA NAVEGACIÓN CON TECLADO
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _imageFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _ubicacionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // INICIALIZAR CONTROLADORES CON VALORES ACTUALES
    usernameController = TextEditingController(text: widget.username);
    passwordController = TextEditingController();
    emailController = TextEditingController();
    imageController = TextEditingController(text: widget.imageURL);
    telefonoController = TextEditingController();
    ubicacionController = TextEditingController();
    
    _loadUserDocId(); // Cargar ID del documento
    _loadUserCompleteData(); // Cargar datos completos del usuario
  }

  // CARGAR ID DEL DOCUMENTO DEL USUARIO
  Future<void> _loadUserDocId() async {
    var snapshot = await widget.firestore
        .collection('usuarios')
        .where('nombreUsuario', isEqualTo: widget.username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        docId = snapshot.docs.first.id;
        userRole = snapshot.docs.first.data()['rol'] ?? 'usuario';
      });
    }
  }

  // CARGAR DATOS COMPLETOS DEL USUARIO DESDE FIRESTORE
  Future<void> _loadUserCompleteData() async {
    var snapshot = await widget.firestore
        .collection('usuarios')
        .where('nombreUsuario', isEqualTo: widget.username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var userData = snapshot.docs.first.data();
      setState(() {
        emailController.text = userData['email'] ?? '';
        telefonoController.text = userData['telefono'] ?? '';
        ubicacionController.text = userData['ubicacion'] ?? '';
      });
    }
  }

  // GUARDAR CAMBIOS EN EL PERFIL
  Future<void> _saveChanges() async {
    if (docId.isEmpty) return;

    // VALIDAR CAMPOS OBLIGATORIOS
    if (usernameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
      _showErrorDialog('El nombre de usuario y email no pueden estar vacíos');
      return;
    }

    // VALIDAR FORMATO DE EMAIL
    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      _showErrorDialog('Ingresa un email válido');
      return;
    }

    try {
      Map<String, dynamic> updateData = {
        'nombreUsuario': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'imageURL': imageController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'ubicacion': ubicacionController.text.trim(),
      };

      // SOLO ACTUALIZAR CONTRASEÑA SI SE PROPORCIONÓ UNA NUEVA
      if (passwordController.text.isNotEmpty) {
        if (passwordController.text.length < 6) {
          _showErrorDialog('La contraseña debe tener al menos 6 caracteres');
          return;
        }
        updateData['password'] = passwordController.text.trim();
      }

      // ACTUALIZAR EN FIRESTORE
      await widget.firestore.collection('usuarios').doc(docId).update(updateData);

      // MOSTRAR CONFIRMACIÓN DE ÉXITO
      _showSuccessDialog();

    } catch (e) {
      _showErrorDialog('Error al guardar los cambios: $e');
    }
  }

  // MOSTRAR DIALOGO DE ERROR
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // MOSTRAR DIALOGO DE ÉXITO
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: const Text('Has guardado los datos correctamente'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context, { // Cerrar página y retornar datos actualizados
                'username': usernameController.text.trim(),
                'imageURL': imageController.text.trim(),
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        username: usernameController.text,
        imageURL: imageController.text,
        userRole: userRole,
      )),
    );
  }

  void _openBiblioteca() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BibliotecaPage(
        usuarioId: docId,
        username: usernameController.text,
        imageURL: imageController.text,
        userRole: userRole,
      )),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPage(
        username: usernameController.text,
        imageURL: imageController.text,
        userRole: userRole,
      )),
    );
  }

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(
        username: usernameController.text,
        imageURL: imageController.text,
      )),
    );
  }

  @override
  void dispose() {
    // LIMPIAR RECURSOS
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    imageController.dispose();
    telefonoController.dispose();
    ubicacionController.dispose();
    
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    _imageFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _ubicacionFocusNode.dispose();
    
    super.dispose();
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
                backgroundImage: imageController.text.isNotEmpty
                    ? NetworkImage(imageController.text)
                    : null,
                child: imageController.text.isEmpty
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Editar perfil'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // BOTÓN GUARDAR
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Guardar cambios',
          ),
          // BOTÓN ADMIN SOLO PARA ADMINISTRADORES
          if (userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _openAdminPanel,
              tooltip: 'Panel de Administración',
            ),
        ],
      ),
      drawer: CustomDrawer(
        currentUsername: usernameController.text,
        currentImageURL: imageController.text,
        userRole: userRole,
        currentPage: _currentPage,
        parentContext: context,
        onLogout: _logout,
        onProfile: () {
          Navigator.pop(context);
        },
        onAddBook: _openBiblioteca,
        onBookList: _openBiblioteca,
        onSearch: _openBiblioteca,
        onMap: _openMap,
        onStats: () {},
        onHome: _openHome,
        onAdminPanel: userRole == 'admin' ? _openAdminPanel : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COLUMNA IZQUIERDA: IMAGEN DE PERFIL
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: imageController.text.isNotEmpty
                              ? NetworkImage(imageController.text)
                              : null,
                          child: imageController.text.isEmpty
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Foto de perfil',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    
                    // COLUMNA DERECHA: FORMULARIO DE EDICIÓN
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // CAMPO: NOMBRE DE USUARIO
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de usuario *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // CAMPO: EMAIL
                          TextField(
                            controller: emailController,
                            focusNode: _emailFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Email *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          
                          // CAMPO: CONTRASEÑA (OPCIONAL)
                          TextField(
                            controller: passwordController,
                            focusNode: _passwordFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña (dejar vacío si no cambia)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 15),
                          
                          // CAMPO: URL DE IMAGEN
                          TextField(
                            controller: imageController,
                            focusNode: _imageFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'URL de imagen de perfil',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // CAMPO: TELÉFONO
                          TextField(
                            controller: telefonoController,
                            focusNode: _telefonoFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
                          
                          // CAMPO: UBICACIÓN
                          TextField(
                            controller: ubicacionController,
                            focusNode: _ubicacionFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Ubicación',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 25),
                          
                          // BOTONES: CANCELAR Y GUARDAR
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Volver sin guardar
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                    side: const BorderSide(color: Colors.grey),
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cancel),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cancelar',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.save),
                                      SizedBox(width: 8),
                                      Text(
                                        'Guardar',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}