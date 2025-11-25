# 📚 BookTracker - Tu Biblioteca Personal

## 📖 Descripción

**BookTracker** es una aplicación móvil desarrollada en Flutter que permite a los usuarios gestionar su biblioteca personal de libros. Los usuarios pueden registrar libros, llevar un seguimiento de su estado de lectura, calificarlos, escribir reseñas y visualizar estadísticas de su hábito de lectura.

## 🎯 Funcionalidades Principales

### 🔐 Autenticación y Usuarios
- **Registro de nuevos usuarios** con información completa
- **Inicio de sesión seguro** 
- **Perfil de usuario** editable con foto, email, teléfono y ubicación
- **Sistema de roles** (Usuario/Administrador)

### 📚 Gestión de Biblioteca
- **Añadir nuevos libros** con información completa
- **Editar y eliminar** libros existentes
- **Filtrado avanzado** por estado de lectura
- **Búsqueda en tiempo real** por título y autor
- **Calificación con estrellas** interactivas
- **Reseñas personales** para cada libro

### 📊 Estadísticas y Métricas
- **Dashboard completo** con métricas de lectura
- **Progreso visual** de libros leídos
- **Distribución por géneros**
- **Estadísticas detalladas** (total páginas, calificación promedio)

### 🗺️ Mapa de Librerías
- **Mapa interactivo** con librerías en España
- **Ubicación del usuario** integrada desde el perfil
- **Navegación a Google Maps**
- **Información de contacto** de librerías

### 👨‍💼 Panel de Administración
- **Gestión completa de usuarios** (CRUD)
- **Creación y edición** de usuarios
- **Eliminación segura** con confirmación
- **Diferenciación de roles**

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** - Framework principal
- **Dart** - Lenguaje de programación
- **Material Design** - Design system

### Backend y Base de Datos
- **Firebase Firestore** - Base de datos NoSQL
- **Firebase Authentication** - Autenticación de usuarios

### Paquetes y Dependencias
- `cloud_firestore` - Integración con Firestore
- `flutter_map` - Mapas interactivos
- `latlong2` - Manejo de coordenadas
- `url_launcher` - Lanzamiento de URLs externas

## 📱 Estructura del Proyecto
```java
lib/
├── main.dart                       # Punto de entrada de la aplicación
├── models/                         # Modelos de datos
│ ├── libro_model.dart
│ └── usuario_model.dart
├── services/                       # Servicios y lógica de negocio
│ ├── libro_service.dart
│ └── mapa_service.dart
├── pages/                          # Pantallas de la aplicación
│ ├── auth/                         # Autenticación
│ │ ├── login_page.dart
│ │ └── register_page.dart
│ ├── books/                        # Gestión de libros
│ │ ├── biblioteca_page.dart
│ │ ├── add_book_page.dart
│ │ ├── edit_book_page.dart
│ │ └── search_page.dart
│ ├── profile/                      # Perfil de usuario
│ │ └── profile_page.dart
│ ├── stats/                        # Estadísticas
│ │ └── stats_page.dart
│ ├── map/                          # Mapa de librerías
│ │ └── map_page.dart
│ ├── admin/                        # Panel de administración
│ │ └── admin_page.dart
│ └── home_page.dart                # Página principal
└── widgets/                        # Componentes reutilizables
├── custom_drawer.dart
└── calificacion_estrellas.dart
```



## 🎨 Características de Diseño

- **Material Design 3** - Guidelines oficiales
- **Responsive design** - Adaptable a diferentes tamaños
- **Accesibilidad** - Navegación intuitiva
- **Feedback visual** - Estados de carga y confirmaciones

## 📊 Características Técnicas

- **Arquitectura limpia** con separación de concerns
- **Streams** para actualizaciones en tiempo real
- **Validación** de datos en frontend y backend
- **Código completamente documentado**

## 👥 Roles de Usuario

### 👤 Usuario Normal
- Gestionar su biblioteca personal
- Ver sus estadísticas
- Editar su perfil
- Explorar librerías en el mapa

### 👑 Administrador
- Todas las funciones de usuario normal
- Gestión completa de usuarios
- Creación de nuevos usuarios
- Eliminación de usuarios existentes

## 🔄 Flujo de la Aplicación

1. **Autenticación** → Login/Registro
2. **Dashboard** → Vista general y acciones rápidas
3. **Biblioteca** → Gestión completa de libros
4. **Estadísticas** → Métricas y progreso
5. **Mapa** → Librerías y ubicación
6. **Perfil** → Edición de información personal
7. **Admin** → Gestión de usuarios (solo administradores)





