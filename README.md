# Roomie App

**Roomie App** es una aplicación móvil moderna desarrollada en Flutter diseñada para facilitar la búsqueda de compañeros de cuarto y departamentos compartidos. Con un enfoque en la seguridad, la facilidad de uso y la conexión en tiempo real, Roomie App ofrece una experiencia premium para encontrar tu próximo hogar.

## 📱 Características Principales

### 🗺️ Descubrimiento Inteligente

- **Mapa Interactivo**: Explora departamentos cercanos con marcadores visuales personalizados.
- **Daily Discovery**: Límite diario de 5 nuevas habitaciones en el mapa para fomentar la revisión detallada.
- **Swipe Cards**: Interfaz intuitiva para dar "Like" o "Reject" a posibles candidatos.

### 🤝 Conexiones y Match

- **Sistema de Match**: Conecta solo cuando el interés es mutuo.
- **Solicitudes Enviadas**: Gestiona y cancela tus likes enviados antes de que sean aceptados.
- **Chat en Tiempo Real**: Mensajería instantánea integrada para coordinar visitas y entrevistas.
- **Notificaciones Push**: Alertas inmediatas cuando recibes un Like o haces un Match.

### 💎 Experiencia Premium

- **Membresía**: Acceso a funciones exclusivas y límites de visualización ampliados.
- **Sin Publicidad**: Navegación fluida sin interrupciones.
- **Temas Personalizados**: Adapta la app a tu estilo preferido.

### 👤 Gestión de Perfil

- **Perfil Completo**: biografía, etiquetas de estilo de vida, edad, profesión.
- **Mis Habitaciones**: Publica tus propios espacios. Visualiza tus 2 principales habitaciones con opción de expandir toda tu lista.
- **Verificación**: Filtros de usuarios y reportes para mantener la comunidad segura.

## 🛠️ Tecnologías

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth, Database, Realtime, Storage)
- **Mapas**: `flutter_map`
- **Pagos**: Stripe (integrado para suscripciones Premium)
- **Notificaciones**: `flutter_local_notifications` + Supabase Realtime

## 🚀 Instalación y Configuración

### Requisitos

- Flutter SDK >=3.0.0
- Cuenta de Supabase
- Cuenta de Stripe (para pagos)

### Pasos

1.  **Clonar el repositorio**

    ```bash
    git clone https://github.com/tu-usuario/roomie-app.git
    cd roomie_app
    ```

2.  **Instalar dependencias**

    ```bash
    flutter pub get
    ```

3.  **Configuración de Supabase**
    Crea un proyecto en Supabase y ejecuta el script de base de datos incluido en `SUPABASE_SCHEMA.sql` para configurar todas las tablas y políticas de seguridad necesarias.

    Actualiza las credenciales en `lib/config/supabase_config.dart` (o donde definas tus claves):

    ```dart
    const supabaseUrl = 'TU_URL';
    const supabaseKey = 'TU_ANON_KEY';
    ```

4.  **Ejecutar la App**
    ```bash
    flutter run
    ```

## 📂 Estructura del Proyecto

- `lib/screens`: Vistas principales (Home, Map, Chat, Profile).
- `lib/services`: Lógica de negocio y comunicación con APIs (MatchService, RealtimeService, NotificationService).
- `lib/providers`: Gestión de estado (AuthProvider, ThemeProvider).
- `lib/widgets`: Componentes reutilizables UI.

## 📄 Licencia

Propiedad privada. Todos los derechos reservados.
