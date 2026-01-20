-- Add location field to profiles table
ALTER TABLE profiles
ADD COLUMN location VARCHAR(50) DEFAULT 'Ecuador';

-- Add first_login_completed field to profiles table
ALTER TABLE profiles
ADD COLUMN first_login_completed BOOLEAN DEFAULT FALSE;

-- Create index for better performance
CREATE INDEX idx_profiles_location ON profiles (location);

CREATE INDEX idx_profiles_first_login ON profiles (first_login_completed);