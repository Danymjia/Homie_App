-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES
create table public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  full_name text,
  photo_url text,
  age int check (age >= 18),
  bio text,
  lifestyle_tags text[], -- Array of strings e.g. ['pet_friendly', 'smoker']
  location text,
  city text,
  country text,
  is_premium boolean default false,
  premium_expiry timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- APARTMENTS
create table public.apartments (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references public.profiles(id) not null,
  title text not null,
  description text,
  price numeric not null,
  city text,
  address text, 
  latitude double precision,
  longitude double precision,
  images text[], -- Array of image URLs
  amenities text[], -- Array of strings
  is_active boolean default true,
  
  -- Boolean flags for quick filtering (optional but good for performance)
  allows_pets boolean default false,
  allows_smoking boolean default false,
  allows_alcohol boolean default false,
  
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- SWIPES (Likes/Dislikes)
create table public.swipes (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null, -- Who swiped
  apartment_id uuid references public.apartments(id) not null, -- What they swiped
  owner_id uuid references public.profiles(id) not null, -- Owner of the apartment
  type text check (type in ('like', 'dislike')) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  unique(user_id, apartment_id) -- Prevent duplicate swipes on same item
);

-- CHATS (Matches)
create table public.chats (
  id uuid default uuid_generate_v4() primary key,
  user1_id uuid references public.profiles(id) not null,
  user2_id uuid references public.profiles(id) not null,
  apartment_id uuid references public.apartments(id), -- Context of the match
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  unique(user1_id, user2_id, apartment_id)
);

-- CHAT PARTICIPANTS (Many-to-Many for flexible querying)
create table public.chat_participants (
  chat_id uuid references public.chats(id) on delete cascade not null,
  user_id uuid references public.profiles(id) not null,
  joined_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  primary key (chat_id, user_id)
);

-- MESSAGES
create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  chat_id uuid references public.chats(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) not null,
  text text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- STORAGE BUCKETS (for reference)
-- bucket: 'profile_photos'
-- bucket: 'apartment_images'

-- RLS POLICIES (Examples)
alter table profiles enable row level security;
create policy "Public profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can insert their own profile" on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

alter table apartments enable row level security;
create policy "Apartments are viewable by everyone" on apartments for select using (true);
create policy "Users can insert their own apartments" on apartments for insert with check (auth.uid() = owner_id);
create policy "Users can update own apartments" on apartments for update using (auth.uid() = owner_id);

alter table swipes enable row level security;
create policy "Users can see their own swipes" on swipes for select using (auth.uid() = user_id);
create policy "Owners can see incoming likes" on swipes for select using (auth.uid() = owner_id and type = 'like');
create policy "Users can insert swipes" on swipes for insert with check (auth.uid() = user_id);
create policy "Users can delete their own swipes" on swipes for delete using (auth.uid() = user_id);

alter table chats enable row level security;
create policy "Users can see chats they are part of" on chats for select using (auth.uid() = user1_id or auth.uid() = user2_id);

alter table messages enable row level security;
create policy "Users can see messages in their chats" on messages for select using (
  exists (
    select 1 from chat_participants cp
    where cp.chat_id = messages.chat_id and cp.user_id = auth.uid()
  )
);
create policy "Users can insert messages in their chats" on messages for insert with check (
  exists (
    select 1 from chat_participants cp
    where cp.chat_id = messages.chat_id and cp.user_id = auth.uid()
  )
);
