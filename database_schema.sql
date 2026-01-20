-- Esquema de base de datos para Roomie App
-- Ejecutar en Supabase SQL Editor

-- Extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de perfiles de usuario
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  age INTEGER,
  location TEXT,
  bio TEXT,
  photo_url TEXT,
  user_type TEXT CHECK (user_type IN ('student', 'worker', 'both')),
  is_verified BOOLEAN DEFAULT FALSE,
  verification_document_url TEXT,
  lifestyle_tags TEXT[] DEFAULT '{}',
  compatibility_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de apartamentos
CREATE TABLE apartments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  price DECIMAL(10, 2) NOT NULL,
  description TEXT,
  images TEXT[] DEFAULT '{}',
  
  -- Reglas de casa
  allows_smoking BOOLEAN DEFAULT FALSE,
  allows_pets BOOLEAN DEFAULT FALSE,
  allows_alcohol BOOLEAN DEFAULT FALSE,
  quiet_hours BOOLEAN DEFAULT FALSE,
  own_laundry BOOLEAN DEFAULT FALSE,
  
  -- Gastos incluidos
  includes_water BOOLEAN DEFAULT FALSE,
  includes_electricity BOOLEAN DEFAULT FALSE,
  includes_internet BOOLEAN DEFAULT FALSE,
  includes_gas BOOLEAN DEFAULT FALSE,
  
  -- Disponibilidad
  is_available BOOLEAN DEFAULT TRUE,
  available_from DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de intereses
CREATE TABLE interests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  apartment_id UUID REFERENCES apartments NOT NULL,
  owner_id UUID REFERENCES auth.users NOT NULL,
  status TEXT DEFAULT 'interested',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, apartment_id)
);

-- Tabla de matches
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID REFERENCES auth.users NOT NULL,
  user2_id UUID REFERENCES auth.users NOT NULL,
  apartment_id UUID REFERENCES apartments NOT NULL,
  status TEXT DEFAULT 'matched',
  match_score DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id, apartment_id)
);

-- Tabla de chats
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID REFERENCES auth.users NOT NULL,
  user2_id UUID REFERENCES auth.users NOT NULL,
  apartment_id UUID REFERENCES apartments NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de mensajes
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats NOT NULL,
  sender_id UUID REFERENCES auth.users NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de visitas agendadas
CREATE TABLE visits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats NOT NULL,
  scheduled_by UUID REFERENCES auth.users NOT NULL,
  visit_date TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  status TEXT DEFAULT 'scheduled',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reportes
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES auth.users NOT NULL,
  reported_user_id UUID REFERENCES auth.users NOT NULL,
  apartment_id UUID REFERENCES apartments,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de referencias de convivencia
CREATE TABLE references (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  reference_by UUID REFERENCES auth.users NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, reference_by)
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_apartments_owner ON apartments(owner_id);
CREATE INDEX idx_apartments_location ON apartments(latitude, longitude);
CREATE INDEX idx_interests_user ON interests(user_id);
CREATE INDEX idx_interests_apartment ON interests(apartment_id);
CREATE INDEX idx_matches_users ON matches(user1_id, user2_id);
CREATE INDEX idx_messages_chat ON messages(chat_id);
CREATE INDEX idx_chats_users ON chats(user1_id, user2_id);
CREATE INDEX idx_reports_reported ON reports(reported_user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_apartments_updated_at BEFORE UPDATE ON apartments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at BEFORE UPDATE ON chats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Políticas de seguridad RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE apartments ENABLE ROW LEVEL SECURITY;
ALTER TABLE interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE references ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Políticas para apartments
CREATE POLICY "Users can view all apartments" ON apartments
  FOR SELECT USING (true);

CREATE POLICY "Users can create own apartments" ON apartments
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own apartments" ON apartments
  FOR UPDATE USING (auth.uid() = owner_id);

-- Políticas para interests
CREATE POLICY "Users can view own interests" ON interests
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = owner_id);

CREATE POLICY "Users can create interests" ON interests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para matches
CREATE POLICY "Users can view own matches" ON matches
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Políticas para chats
CREATE POLICY "Users can view own chats" ON chats
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create chats" ON chats
  FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Políticas para messages
CREATE POLICY "Users can view messages in own chats" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.user1_id = auth.uid() OR chats.user2_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in own chats" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.user1_id = auth.uid() OR chats.user2_id = auth.uid())
    )
  );

-- Políticas para reports
CREATE POLICY "Users can create reports" ON reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- Storage buckets (ejecutar en Supabase Storage)
-- Crear buckets para:
-- - profile-photos
-- - apartment-photos
-- - verification-documents
