-- Script para corregir las políticas RLS faltantes
-- Ejecutar en Supabase SQL Editor si ya tienes las tablas creadas

-- Política faltante para INSERT en profiles
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Si la política ya existe, primero elimínala con:
-- DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
