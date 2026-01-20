-- Actualizar tabla profiles para tener city y country separados

-- Eliminar campo location
ALTER TABLE profiles DROP COLUMN IF EXISTS location;

-- Agregar campos city y country
ALTER TABLE profiles ADD COLUMN city VARCHAR(50) DEFAULT NULL;

ALTER TABLE profiles
ADD COLUMN country VARCHAR(50) DEFAULT 'Ecuador';

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_profiles_city ON profiles (city);

CREATE INDEX IF NOT EXISTS idx_profiles_country ON profiles (country);

-- Actualizar datos existentes (migración)
UPDATE profiles
SET
    city = CASE
        WHEN location LIKE '%,%' THEN SPLIT_PART (location, ',', 1)
        WHEN location IS NOT NULL THEN NULL
        ELSE location
    END,
    country = CASE
        WHEN location LIKE '%,%' THEN SPLIT_PART (location, ',', 2)
        WHEN location IS NOT NULL THEN 'Ecuador'
        ELSE SPLIT_PART (location, ',', 2)
    END
WHERE
    location IS NOT NULL
    OR location LIKE '%,%';

-- Nota: Esta migración asume que los datos existentes están en formato "Ciudad, País"
-- Para nuevos registros, se guardarán city y country por separado