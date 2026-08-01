-- ==========================================
-- SUPABASE BACKEND SCHEMA FOR PICKD V1.1
-- ==========================================

-- 0. TEARDOWN EXISTING SCHEMA
-- WARNING: This deletes existing data to start fresh. Remove these 3 lines if you want to preserve data.
DROP TABLE IF EXISTS public.watchlists CASCADE;
DROP TABLE IF EXISTS public.swipe_history CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 1. PROFILES TABLE
-- Stores user preferences, taste seeds, and basic info
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    total_swipe_count INTEGER DEFAULT 0,
    taste_seed_movie_ids INTEGER[] DEFAULT '{}',
    taste_seed_tv_ids INTEGER[] DEFAULT '{}',
    allow_old_movies BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
    ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
    ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE USING (auth.uid() = id);


-- 2. SWIPE HISTORY TABLE
-- Stores every swipe action so we can undo them and prevent duplicates
CREATE TABLE IF NOT EXISTS public.swipe_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    media_id BIGINT NOT NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('movie', 'tv')),
    title TEXT NOT NULL,
    poster_path TEXT,
    action TEXT NOT NULL CHECK (action IN ('save', 'skip', 'watched')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, media_id, media_type)
);

ALTER TABLE public.swipe_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own swipe history" 
    ON public.swipe_history FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into their own swipe history" 
    ON public.swipe_history FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own swipe history" 
    ON public.swipe_history FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete from their own swipe history" 
    ON public.swipe_history FOR DELETE USING (auth.uid() = user_id);


-- 3. WATCHLISTS TABLE
-- Dedicated table for Saved and Watched movies (Populates the Watchlist UI)
CREATE TABLE IF NOT EXISTS public.watchlists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    media_id BIGINT NOT NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('movie', 'tv')),
    title TEXT NOT NULL,
    poster_path TEXT,
    is_watched BOOLEAN DEFAULT false,
    rating INTEGER CHECK (rating >= 1 AND rating <= 10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, media_id, media_type)
);

ALTER TABLE public.watchlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own watchlist" 
    ON public.watchlists FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into their own watchlist" 
    ON public.watchlists FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own watchlist" 
    ON public.watchlists FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete from their own watchlist" 
    ON public.watchlists FOR DELETE USING (auth.uid() = user_id);

-- 4. AUTO-CREATE PROFILE TRIGGER
-- Automatically creates a row in public.profiles when a new auth.user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (new.id);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists so this script is idempotent
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
