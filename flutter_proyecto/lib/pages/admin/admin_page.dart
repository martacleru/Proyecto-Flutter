// PANEL DE ADMINISTRACIÓN - Permite gestionar usuarios (crear, editar, eliminar)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';
import '../books/biblioteca_page.dart';
import '../map/map_page.dart';
import '../stats/stats_page.dart';
import '../../widgets/custom_drawer.dart';

class AdminPage extends StatefulWidget {
  final String username;
  final String imageURL;
  final String userRole;

  const AdminPage({
    super.key,
    required this.username,
    required this.imageURL,
    required this.userRole,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _currentPage = 'admin';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId(); // Obtener ID del usuario actual
  }

  // OBTENER ID DEL USUARIO ACTUAL
  Future<void> _getUserId() async {
    try {
      var snapshot = await firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _userId = snapshot.docs.first.id;
        });
      }
    } catch (e) {
      print('Error al obtener userId: $e');
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
          firestore: firestore,
        ),
      ),
    );
  }

  void _openBiblioteca() {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de usuario')),
      );
    }
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

  void _openStats() {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de usuario')),
      );
    }
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

  void _openAdminPanel() {
    Navigator.pop(context);
  }

  // OPERACIONES CRUD PARA USUARIOS

  // ELIMINAR USUARIO
  Future<void> _deleteUser(String docId, String username) async {
    await firestore.collection('usuarios').doc(docId).delete();
  }

  // EDITAR USUARIO
  Future<void> _editUser(String docId, Map<String, dynamic> data) async {
    await firestore.collection('usuarios').doc(docId).update(data);
  }

  // DIALOGO DE CONFIRMACIÓN PARA ELIMINAR USUARIO
  void _showDeleteConfirmation(String docId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que quieres eliminar al usuario "$username"?\n\n'
          '⚠️ Esta acción no se puede deshacer y se perderán todos los datos del usuario.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo de confirmación
              try {
                await _deleteUser(docId, username);
                
                // Mostrar mensaje de éxito
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Usuario "$username" eliminado correctamente'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                // Mostrar mensaje de error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar usuario: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // DIALOGO PARA CREAR NUEVO USUARIO
  void _openCreateUserDialog() {
    String newUsername = '';
    String newPassword = '';
    String newEmail = '';
    String newImage = '';
    String newRole = 'usuario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear nuevo usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario *',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => newUsername = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => newEmail = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (val) => newPassword = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => newImage = val,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: newRole,
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) => newRole = val ?? 'usuario',
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // VALIDAR CAMPOS OBLIGATORIOS
              if (newUsername.trim().isEmpty || newPassword.trim().isEmpty || newEmail.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos obligatorios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // VALIDAR FORMATO DE EMAIL
              if (!newEmail.contains('@') || !newEmail.contains('.')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un email válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // VERIFICAR SI EL USUARIO YA EXISTE
                var existing = await firestore
                    .collection('usuarios')
                    .where('nombreUsuario', isEqualTo: newUsername)
                    .get();

                if (existing.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El usuario ya existe'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // VERIFICAR SI EL EMAIL YA EXISTE
                var existingEmail = await firestore
                    .collection('usuarios')
                    .where('email', isEqualTo: newEmail)
                    .get();

                if (existingEmail.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El email ya está registrado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // CREAR NUEVO USUARIO
                await firestore.collection('usuarios').add({
                  'nombreUsuario': newUsername.trim(),
                  'email': newEmail.trim(),
                  'password': newPassword.trim(),
                  'imageURL': newImage.trim(),
                  'rol': newRole,
                  'telefono': '',
                  'ubicacion': '',
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario creado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al crear usuario: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // DIALOGO PARA EDITAR USUARIO EXISTENTE
  void _openEditUserDialog(String docId, Map<String, dynamic> data) {
    String editUsername = data['nombreUsuario'] ?? '';
    String editEmail = data['email'] ?? '';
    String editPassword = '';
    String editImage = data['imageURL'] ?? '';
    String editRole = data['rol'] ?? 'usuario';
    String editTelefono = data['telefono'] ?? '';
    String editUbicacion = data['ubicacion'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario *',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editUsername),
                onChanged: (val) => editUsername = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editEmail),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => editEmail = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Contraseña (dejar vacío si no cambia)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (val) => editPassword = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editImage),
                onChanged: (val) => editImage = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editTelefono),
                keyboardType: TextInputType.phone,
                onChanged: (val) => editTelefono = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: editUbicacion),
                onChanged: (val) => editUbicacion = val,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: editRole,
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) => editRole = val ?? 'usuario',
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // VALIDAR CAMPOS OBLIGATORIOS
              if (editUsername.trim().isEmpty || editEmail.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El nombre de usuario y email son obligatorios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // VALIDAR FORMATO DE EMAIL
              if (!editEmail.contains('@') || !editEmail.contains('.')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un email válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                Map<String, dynamic> updateData = {
                  'nombreUsuario': editUsername.trim(),
                  'email': editEmail.trim(),
                  'imageURL': editImage.trim(),
                  'rol': editRole,
                  'telefono': editTelefono.trim(),
                  'ubicacion': editUbicacion.trim(),
                };

                // SOLO ACTUALIZAR CONTRASEÑA SI SE PROPORCIONÓ UNA NUEVA
                if (editPassword.isNotEmpty) {
                  if (editPassword.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La contraseña debe tener al menos 6 caracteres'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  updateData['password'] = editPassword.trim();
                }

                await _editUser(docId, updateData);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario actualizado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar usuario: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // WIDGET PARA LISTAR USUARIOS POR ROL
  Widget _userList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('usuarios').where('rol', isEqualTo: role).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                role == 'admin' ? 'No hay administradores' : 'No hay usuarios',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        final users = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role == 'admin' ? '👑 Administradores' : '👥 Usuarios',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...users.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final username = data['nombreUsuario'] ?? 'Sin nombre';
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['imageURL'] != null && data['imageURL'] != ''
                        ? NetworkImage(data['imageURL'])
                        : null,
                    child: (data['imageURL'] == null || data['imageURL'] == '')
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(username),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${data['email'] ?? 'No especificado'}'),
                      Text('Rol: ${data['rol'] ?? 'usuario'}'),
                      if (data['telefono'] != null && data['telefono'] != '')
                        Text('Tel: ${data['telefono']}'),
                      if (data['ubicacion'] != null && data['ubicacion'] != '')
                        Text('Ubicación: ${data['ubicacion']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _openEditUserDialog(doc.id, data);
                        },
                        tooltip: 'Editar usuario',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(doc.id, username),
                        tooltip: 'Eliminar usuario',
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - ${widget.username}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear usuario',
            onPressed: _openCreateUserDialog,
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
        onStats: _openStats,
        onHome: _openHome,
        onAdminPanel: _openAdminPanel,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Administra los usuarios del sistema. Puedes crear, editar y eliminar usuarios.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            
            _userList('usuario'), // Lista de usuarios normales
            _userList('admin'),   // Lista de administradores
            
            // ADVERTENCIA SOBRE ELIMINACIÓN
            Card(
              color: Colors.orange[50],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Al eliminar un usuario, se perderán todos sus datos y libros asociados. Esta acción no se puede deshacer.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}