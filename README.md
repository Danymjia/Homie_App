# Roomie App - Aplicación de Búsqueda de Roomies

Aplicación móvil desarrollada con Flutter para encontrar compañeros de cuarto ideales. Los usuarios pueden buscar departamentos para compartir y establecer preferencias sobre hábitos de vida (mascotas, alcohol, fumar, etc.).

## Características

- 🔐 **Autenticación**: Login, registro y recuperación de contraseña
- 🗺️ **Mapa interactivo**: Visualización de departamentos disponibles con geolocalización
- 💬 **Chat en tiempo real**: Sistema de mensajería integrado con Supabase
- 🤖 **Chatbot AI**: Asistente virtual para ayudar en la búsqueda
- 👆 **Swipe Cards**: Interfaz estilo Tinder para descubrir roomies
- 🎯 **Sistema de Matches**: Cuando ambos usuarios se aceptan mutuamente
- 📝 **Registro de departamentos**: Formulario completo con reglas y gastos incluidos
- 👤 **Perfil de usuario**: Gestión de información personal y preferencias

## Requisitos Previos

- Flutter SDK (>=3.0.0)
- Dart SDK
- Cuenta de Supabase
- Google Maps API Key (para la funcionalidad de mapas)

## Configuración

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd roomie_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Obtén tu URL y anon key
3. Edita `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'TU_SUPABASE_URL';
  static const String anonKey = 'TU_SUPABASE_ANON_KEY';
}
```

### 4. Configurar Google Maps

1. Obtén una API Key de Google Maps
2. Para Android: Edita `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="TU_API_KEY"/>
  </application>
</manifest>
```

3. Para iOS: Edita `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("TU_API_KEY")
```

### 5. Configurar permisos

#### Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS (`ios/Runner/Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrar departamentos cercanos</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necesitamos tu ubicación para mostrar departamentos cercanos</string>
```

## Estructura de Base de Datos Supabase

Necesitarás crear las siguientes tablas en Supabase:

### Tabla `profiles`
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT,
  age INTEGER,
  location TEXT,
  bio TEXT,
  lifestyle_tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Tabla `apartments`
```sql
CREATE TABLE apartments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users,
  title TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  price DECIMAL,
  description TEXT,
  images TEXT[],
  allows_smoking BOOLEAN DEFAULT FALSE,
  allows_pets BOOLEAN DEFAULT FALSE,
  allows_alcohol BOOLEAN DEFAULT FALSE,
  quiet_hours BOOLEAN DEFAULT FALSE,
  own_laundry BOOLEAN DEFAULT FALSE,
  includes_water BOOLEAN DEFAULT FALSE,
  includes_electricity BOOLEAN DEFAULT FALSE,
  includes_internet BOOLEAN DEFAULT FALSE,
  includes_gas BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Tabla `likes`
```sql
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  apartment_id UUID REFERENCES apartments,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, apartment_id)
);
```

### Tabla `matches`
```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID REFERENCES auth.users,
  user2_id UUID REFERENCES auth.users,
  apartment_id UUID REFERENCES apartments,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user1_id, user2_id, apartment_id)
);
```

### Tabla `messages`
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID,
  sender_id UUID REFERENCES auth.users,
  text TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Tabla `chats`
```sql
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID REFERENCES auth.users,
  user2_id UUID REFERENCES auth.users,
  apartment_id UUID REFERENCES apartments,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Ejecutar la aplicación

```bash
flutter run
```

## Estructura del Proyecto

```
lib/
├── config/           # Configuraciones (Supabase, etc.)
├── providers/        # State management (Auth, Location)
├── routes/          # Navegación y rutas
├── screens/         # Pantallas de la aplicación
│   ├── auth/        # Login, Registro, Recuperar contraseña
│   ├── home/        # Swipe cards
│   ├── map/         # Mapa con geolocalización
│   ├── chat/        # Lista y detalle de chats
│   ├── match/       # Pantalla de match
│   └── profile/     # Perfil y registro de apartamento
├── theme/           # Tema y estilos
└── widgets/         # Componentes reutilizables
```

## Características de Diseño

- **Tema oscuro**: Diseño moderno con fondo negro (#000000)
- **Color primario**: Rojo pastel (#E57373, #EB6B6B, #FF4B63)
- **Tipografía**: Inter y Plus Jakarta Sans
- **Navegación**: Bottom navigation bar con 4 secciones principales

## Próximos Pasos

- [ ] Integración completa con Supabase para datos reales
- [ ] Implementación del chatbot AI
- [ ] Sistema de notificaciones push
- [ ] Subida de imágenes a Supabase Storage
- [ ] Filtros avanzados de búsqueda
- [ ] Sistema de calificaciones y reseñas

## Licencia

Este proyecto es privado y de uso exclusivo.

## Contacto

Para preguntas o soporte, contacta al equipo de desarrollo.
