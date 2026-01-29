# Homie App

**Homie** es una aplicación móvil moderna desarrollada en Flutter diseñada para facilitar la búsqueda de compañeros de cuarto y departamentos compartidos. Con un enfoque en la seguridad, la facilidad de uso y la conexión en tiempo real, Homie ofrece una experiencia premium para encontrar tu próximo hogar.

#Visita nuestro canal de Youtube
**https://youtu.be/1Zv6bsyw2tU**

## 📱 Características Principales

### 🗺️ Descubrimiento Inteligente

- **Mapa Interactivo**: Explora departamentos cercanos con marcadores visuales personalizados.
- **Swipe Cards**: Interfaz intuitiva para dar "Like" o "Reject" a posibles candidatos, ahora con guías visuales de uso.
- **Daily Discovery**: Límite diario de visualizaciones para fomentar interacciones de calidad.

### 🤝 Conexiones y Match

- **Sistema de Match**: Conecta solo cuando el interés es mutuo.
- **Cálculo de Compatibilidad**: Algoritmo que analiza intereses compartidos para mostrar un porcentaje de compatibilidad en cada Match.
- **Chat en Tiempo Real**: Mensajería instantánea integrada para coordinar visitas.
- **Notificaciones Push**: Alertas inmediatas para nuevos Likes y Matches.

### 💎 Experiencia Premium (Homie+)

- **Membresía**: Acceso ilimitado a visualizaciones y funciones exclusivas.
- **Gestión de Suscripción**: Control total sobre tu plan, incluyendo cancelación programada al final del periodo de facturación.
- **Temas Personalizados**: 6 temas exclusivos con controles de opacidad para personalizar la apariencia de la app.
- **Sin Publicidad**: Navegación fluida sin interrupciones.

### ⚙️ Configuración y Soporte

- **Módulo de Ajustes**: Nueva sección centralizada para gestionar tu cuenta.
- **Soporte Integrado**: Herramientas para contactar soporte, reportar usuarios o problemas técnicos.
- **Seguridad**: Opciones claras para cerrar sesión y gestionar la privacidad.

### 👤 Gestión de Perfil

- **Perfil Completo**: Biografía editable, etiquetas de estilo de vida y fotos.
- **Mis Habitaciones**: Publica y gestiona tus propios espacios con límites según tu plan.
- **Verificación**: Filtros de usuarios y reportes para mantener la comunidad segura.

## 🛠️ Tecnologías

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
  - **Auth**: Autenticación segura.
  - **Database**: PostgreSQL con Row Level Security.
  - **Storage**: Almacenamiento de imágenes.
  - **Edge Functions**: Lógica de servidor para gestión de suscripciones (Stripe).
- **Mapas**: `flutter_map`
- **Pagos**: Stripe (Suscripciones recurrentes).
- **Gestión de Estado**: `Provider`.
- **Enrutamiento**: `go_router`.

## 🚀 Instalación y Configuración

### Requisitos

- Flutter SDK >=3.0.0
- Cuenta de Supabase
- Cuenta de Stripe
- Supabase CLI (para desplegar Edge Functions)

### Pasos

1.  **Clonar el repositorio**

    ```bash
    git clone https://github.com/tu-usuario/homie-app.git
    cd homie_app
    ```

2.  **Instalar dependencias**

    ```bash
    flutter pub get
    ```

3.  **Configuración de Supabase**
    - Ejecuta el script `SUPABASE_SCHEMA.sql` en tu proyecto de Supabase.
    - Despliega las Edge Functions:
      ```bash
      supabase functions deploy cancel-subscription --no-verify-jwt
      ```

4.  **Variables de Entorno**
    Crea un archivo `.env` o configura tus claves en `lib/config/env.dart` (según tu implementación):

    ```dart
    const supabaseUrl = 'TU_URL';
    const supabaseKey = 'TU_ANON_KEY';
    ```

5.  **Ejecutar la App**
    ```bash
    flutter run
    ```

## 📂 Estructura del Proyecto

- `lib/screens`: Vistas principales (Home, Map, Chat, Profile, Settings, Premium).
- `lib/services`: Lógica de negocio y comunicación (AuthService, MatchService, StorageService).
- `lib/providers`: Gestión de estado global (AuthProvider, ThemeProvider).
- `lib/widgets`: Componentes UI reutilizables.
- `supabase/functions`: Código TypeScript para Edge Functions.

## 📄 Licencia

Propiedad privada. Todos los derechos reservados.
