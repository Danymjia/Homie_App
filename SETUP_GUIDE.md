# Guía de Configuración Completa - Roomie App

## 📋 Requisitos Previos

1. Flutter SDK (>=3.0.0)
2. Cuenta de Supabase
3. Android Studio / Xcode (para desarrollo móvil)

## 🔧 Configuración Paso a Paso

### 1. Configurar Supabase

#### 1.1 Crear Proyecto en Supabase
1. Ve a [supabase.com](https://supabase.com)
2. Crea un nuevo proyecto
3. Anota tu URL y anon key

#### 1.2 Configurar Base de Datos
1. Ve a SQL Editor en Supabase
2. Ejecuta el contenido completo de `database_schema.sql`
3. Esto creará todas las tablas necesarias

#### 1.3 Configurar Storage Buckets
En Supabase Dashboard → Storage, crea los siguientes buckets:

- **profile-photos**
  - Public: Sí
  - File size limit: 5MB
  - Allowed MIME types: image/jpeg, image/png, image/webp

- **apartment-photos**
  - Public: Sí
  - File size limit: 10MB
  - Allowed MIME types: image/jpeg, image/png, image/webp

- **verification-documents**
  - Public: No (privado)
  - File size limit: 5MB
  - Allowed MIME types: image/jpeg, image/png, application/pdf

#### 1.4 Configurar Autenticación
En Supabase Dashboard → Authentication → Providers:

- **Email**: Habilitado por defecto
- **Google**: Opcional (configurar OAuth)
- **Facebook**: Opcional (configurar OAuth)
- **Apple**: Opcional (para iOS)

### 2. Configurar la Aplicación Flutter

#### 2.1 Actualizar Configuración de Supabase
Edita `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'TU_SUPABASE_URL';
  static const String anonKey = 'TU_SUPABASE_ANON_KEY';
}
```

#### 2.2 Instalar Dependencias
```bash
flutter pub get
```

#### 2.3 Configurar Permisos

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrar departamentos cercanos</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necesitamos tu ubicación para mostrar departamentos cercanos</string>
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de perfil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para seleccionar imágenes</string>
```

### 3. Flujo de la Aplicación

#### 3.1 Autenticación
1. **Registro**: 
   - Usuario completa formulario con tipo (estudiante/trabajador)
   - Opcionalmente sube documento de verificación
   - Se crea perfil en Supabase

2. **Cuestionario de Compatibilidad**:
   - Usuario responde preguntas sobre hábitos
   - Se calcula score de compatibilidad
   - Se guarda en `compatibility_data` del perfil

#### 3.2 Publicaciones
1. Usuario puede registrar apartamento desde perfil
2. Sube fotos (máximo 10)
3. Define reglas de casa y gastos incluidos
4. Se guarda con geolocalización

#### 3.3 Búsqueda y Matches
1. Usuario ve tarjetas estilo Tinder
2. Puede dar like o rechazar
3. Si ambos dan like → Match
4. Se crea chat automáticamente

#### 3.4 Chat y Visitas
1. Usuarios con match pueden chatear
2. Pueden agendar visitas
3. Después de visita, pueden aceptar/rechazar

#### 3.5 Seguridad
1. Usuarios pueden reportar otros usuarios
2. Sistema de referencias de convivencia
3. Verificación de identidad (manual por admin)

## 🗄️ Estructura de Base de Datos

### Tablas Principales

- **profiles**: Perfiles de usuario con datos de compatibilidad
- **apartments**: Publicaciones de departamentos
- **interests**: Intereses de usuarios en apartamentos
- **matches**: Matches mutuos entre usuarios
- **chats**: Conversaciones entre usuarios
- **messages**: Mensajes en los chats
- **visits**: Visitas agendadas
- **reports**: Reportes de usuarios
- **references**: Referencias de convivencia

## 🔐 Seguridad

### Row Level Security (RLS)
Todas las tablas tienen RLS habilitado con políticas que:
- Permiten lectura pública de perfiles y apartamentos
- Restringen escritura a propietarios
- Protegen datos sensibles

### Verificación de Usuarios
- Los usuarios pueden subir documentos de verificación
- Los admins verifican manualmente
- Usuarios verificados tienen badge especial

## 📱 Funcionalidades Premium

Las funciones premium están disponibles pero requieren:
1. Integración con sistema de pagos (Stripe, RevenueCat)
2. Verificación de suscripción activa
3. Desbloqueo de funciones según plan

## 🚀 Próximos Pasos

1. **Integrar sistema de pagos** para funciones premium
2. **Implementar notificaciones push** para matches y mensajes
3. **Agregar filtros avanzados** de búsqueda
4. **Sistema de calificaciones** después de convivencia
5. **Integración con APIs** de transporte público y universidades

## 🐛 Solución de Problemas

### Error de conexión a Supabase
- Verifica que la URL y anon key sean correctas
- Asegúrate de que el proyecto esté activo

### Error al subir fotos
- Verifica que los buckets de Storage existan
- Revisa los permisos del bucket
- Verifica el tamaño máximo de archivo

### Error de geolocalización
- Verifica permisos en AndroidManifest.xml / Info.plist
- Asegúrate de que la ubicación esté habilitada en el dispositivo

## 📞 Soporte

Para problemas o preguntas, consulta la documentación de:
- [Supabase](https://supabase.com/docs)
- [Flutter](https://flutter.dev/docs)
- [flutter_map](https://pub.dev/packages/flutter_map)
