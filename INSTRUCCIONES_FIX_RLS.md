# Solución: Error 403 al Registrar Usuario

## Problema
Al intentar registrarse, aparece el error:
```
PostgrestException: new row violates row-level security policy for table "profiles"
Error 403 (Forbidden)
```

## Causa
Falta una política de Row Level Security (RLS) en Supabase que permita a los usuarios insertar su propio perfil.

## Solución Rápida

### Opción 1: Ejecutar SQL en Supabase (Recomendado)

1. Ve a tu proyecto en Supabase Dashboard
2. Navega a **SQL Editor**
3. Ejecuta el siguiente SQL:

```sql
-- Crear política para permitir que usuarios inserten su propio perfil
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### Opción 2: Usar el archivo fix_rls_policies.sql

Ejecuta el contenido del archivo `fix_rls_policies.sql` en el SQL Editor de Supabase.

## Verificar que funciona

Después de ejecutar el SQL:

1. Intenta registrarte nuevamente en la app
2. El registro debería funcionar correctamente
3. El perfil se creará automáticamente después del registro

## Verificar políticas existentes

Para ver todas las políticas de la tabla `profiles`, ejecuta:

```sql
SELECT * FROM pg_policies WHERE tablename = 'profiles';
```

Si la política ya existe y hay conflictos, elimínala primero:

```sql
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
```

Luego vuelve a crearla con el comando anterior.

## Políticas RLS Completas para Profiles

Asegúrate de tener estas tres políticas:

1. **SELECT**: Todos pueden ver perfiles
   ```sql
   CREATE POLICY "Users can view all profiles" ON profiles
     FOR SELECT USING (true);
   ```

2. **INSERT**: Usuarios pueden crear su propio perfil (ESTA ES LA QUE FALTA)
   ```sql
   CREATE POLICY "Users can insert own profile" ON profiles
     FOR INSERT WITH CHECK (auth.uid() = id);
   ```

3. **UPDATE**: Usuarios pueden actualizar su propio perfil
   ```sql
   CREATE POLICY "Users can update own profile" ON profiles
     FOR UPDATE USING (auth.uid() = id);
   ```

## Nota importante

El `id` en la tabla `profiles` debe ser igual al `id` del usuario autenticado (`auth.uid()`). Esto se asegura en el código cuando creas el perfil con:

```dart
await _supabase.from('profiles').insert({
  'id': user.id,  // <- Este debe ser igual a auth.uid()
  ...
});
```

¡Listo! Después de agregar esta política, el registro debería funcionar correctamente.
