// MENÚ DE NAVEGACIÓN LATERAL - Drawer personalizado para navegación entre secciones

import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String currentUsername; // Nombre de usuario actual
  final String currentImageURL; // URL de imagen de perfil
  final String userRole; // Rol del usuario (admin/usuario)
  final String currentPage; // Página actual para resaltar
  final BuildContext parentContext; // Contexto del padre
  final VoidCallback onLogout; // Callback para cerrar sesión
  final VoidCallback onProfile; // Callback para abrir perfil
  final VoidCallback onAddBook; // Callback para añadir libro
  final VoidCallback onBookList; // Callback para biblioteca
  final VoidCallback onSearch; // Callback para búsqueda
  final VoidCallback onMap; // Callback para mapa
  final VoidCallback onStats; // Callback para estadísticas
  final VoidCallback onHome; // Callback para inicio
  final VoidCallback? onAdminPanel; // Callback para panel admin (solo admins)

  const CustomDrawer({
    super.key,
    required this.currentUsername,
    required this.currentImageURL,
    required this.userRole,
    required this.currentPage,
    required this.parentContext,
    required this.onLogout,
    required this.onProfile,
    required this.onAddBook,
    required this.onBookList,
    required this.onSearch,
    required this.onMap,
    required this.onStats,
    required this.onHome,
    this.onAdminPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // HEADER DEL DRAWER CON INFORMACIÓN DEL USUARIO
          UserAccountsDrawerHeader(
            accountName: Text(currentUsername),
            accountEmail: Text(userRole == 'admin' ? 'Administrador' : 'Usuario'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: currentImageURL.isNotEmpty 
                  ? NetworkImage(currentImageURL) 
                  : null,
              child: currentImageURL.isEmpty 
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Colors.indigo, // Color de fondo del header
            ),
          ),
          
          // ELEMENTOS DE NAVEGACIÓN PRINCIPAL
          
          // INICIO
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Inicio',
            page: 'home',
            onTap: onHome,
          ),
          
          // BIBLIOTECA
          _buildDrawerItem(
            icon: Icons.library_books,
            title: 'Biblioteca',
            page: 'library',
            onTap: onBookList,
          ),
          
          // MAPA
          _buildDrawerItem(
            icon: Icons.map,
            title: 'Mapa de Librerías',
            page: 'map',
            onTap: onMap,
          ),
          
          // ESTADÍSTICAS
          _buildDrawerItem(
            icon: Icons.bar_chart,
            title: 'Estadísticas',
            page: 'stats',
            onTap: onStats,
          ),
          
          // PANEL DE ADMINISTRACIÓN (solo para admins)
          if (onAdminPanel != null)
            _buildDrawerItem(
              icon: Icons.admin_panel_settings,
              title: 'Administración',
              page: 'admin',
              onTap: onAdminPanel!,
            ),
          
          const Divider(), // Separador visual
          
          // PERFIL (siempre visible)
          ListTile(
            leading: Icon(
              Icons.person,
              color: currentPage == 'profile' ? Colors.indigo : Colors.grey,
            ),
            title: Text(
              'Mi Perfil',
              style: TextStyle(
                color: currentPage == 'profile' ? Colors.indigo : Colors.black,
                fontWeight: currentPage == 'profile' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.pop(parentContext); // Cerrar drawer
              if (currentPage != 'profile') {
                onProfile(); // Navegar solo si no está en la página actual
              }
            },
          ),
          
          // CERRAR SESIÓN (siempre visible, en rojo)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  // MÉTODO AUXILIAR PARA CONSTRUIR ELEMENTOS DEL DRAWER
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String page,
    required VoidCallback onTap,
  }) {
    final bool isCurrentPage = currentPage == page; // Verificar si es la página actual
    
    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentPage ? Colors.indigo : Colors.grey, // Color según estado
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCurrentPage ? Colors.indigo : Colors.black,
          fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(parentContext); // Cerrar drawer primero
        if (!isCurrentPage) {
          onTap(); // Ejecutar callback solo si no está en la página actual
        }
      },
    );
  }
}