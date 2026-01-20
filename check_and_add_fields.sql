-- Verificar si first_login_completed existe
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE
    table_name = 'profiles'
    AND column_name = 'first_login_completed';

-- Si no existe, agregar el campo
-- ALTER TABLE profiles ADD COLUMN first_login_completed BOOLEAN DEFAULT FALSE;

-- Verificar si location existe
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE
    table_name = 'profiles'
    AND column_name = 'location';

-- Si no existe, agregar el campo
-- ALTER TABLE profiles ADD COLUMN location VARCHAR(50) DEFAULT 'Ecuador';

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_profiles_first_login ON profiles (first_login_completed);

CREATE INDEX IF NOT EXISTS idx_profiles_location ON profiles (location);