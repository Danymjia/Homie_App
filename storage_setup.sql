-- Storage setup script for Roomie App
-- Execute this in Supabase SQL Editor

-- 1. Create storage buckets if they don't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('profile-photos', 'profile-photos', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('apartment-photos', 'apartment-photos', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('verification-documents', 'verification-documents', false, 10485760, ARRAY['application/pdf', 'image/jpeg', 'image/png'])
ON CONFLICT (id) DO NOTHING;

-- 2. Create Row Level Security (RLS) policies for storage

-- Profile photos policies
CREATE POLICY "Users can upload their own profile photos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'profile_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can view their own profile photos" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profile-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'profile_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can update their own profile photos" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'profile_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can delete their own profile photos" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profile-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'profile_(.*)_.*', 'g'))[1]
  );

-- Apartment photos policies
CREATE POLICY "Users can upload their own apartment photos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'apartment-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'apartment_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can view their own apartment photos" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'apartment-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'apartment_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can update their own apartment photos" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'apartment-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'apartment_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can delete their own apartment photos" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'apartment-photos' AND 
    auth.uid()::text = (regexp_matches(name, 'apartment_(.*)_.*', 'g'))[1]
  );

-- Verification documents policies
CREATE POLICY "Users can upload their own verification documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'verification-documents' AND 
    auth.uid()::text = (regexp_matches(name, 'verification_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can view their own verification documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'verification-documents' AND 
    auth.uid()::text = (regexp_matches(name, 'verification_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can update their own verification documents" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'verification-documents' AND 
    auth.uid()::text = (regexp_matches(name, 'verification_(.*)_.*', 'g'))[1]
  );

CREATE POLICY "Users can delete their own verification documents" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'verification-documents' AND 
    auth.uid()::text = (regexp_matches(name, 'verification_(.*)_.*', 'g'))[1]
  );

-- 3. Enable RLS on storage if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- 4. Grant necessary permissions
GRANT ALL ON storage.objects TO authenticated;

GRANT ALL ON storage.buckets TO authenticated;