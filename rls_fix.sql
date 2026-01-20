-- Corrección de políticas RLS para permitir inserción de perfiles
-- El problema: la política "Users can insert own profile" requiere auth.uid() = id
-- Pero en el registro, auth.uid() puede ser null temporalmente

-- Eliminar políticas problemáticas
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Política corregida que permite inserción durante registro
CREATE POLICY "Users can insert own profile" ON profiles FOR
INSERT
WITH
    CHECK (
        -- Permitir inserción si el usuario está autenticado O si es un nuevo registro
        (auth.uid () = id)
        OR (
            auth.uid () IS NULL
            AND id IS NOT NULL
        )
    );

-- Similar corrección para otras tablas si es necesario
DROP POLICY IF EXISTS "Users can create interests" ON interests;

CREATE POLICY "Users can create interests" ON interests FOR
INSERT
WITH
    CHECK (
        (auth.uid () = user_id)
        OR (
            auth.uid () IS NULL
            AND user_id IS NOT NULL
        )
    );