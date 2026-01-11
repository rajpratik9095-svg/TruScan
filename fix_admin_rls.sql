-- =====================================================
-- Fix RLS Policies for Admin Panel Read Access
-- Run this in Supabase SQL Editor
-- =====================================================

-- Allow public read for health_tips (already exists, but making sure)
DROP POLICY IF EXISTS "Anyone can read tips" ON health_tips;
CREATE POLICY "Anyone can read tips" ON health_tips
  FOR SELECT USING (true);

-- Allow public read for ads
DROP POLICY IF EXISTS "Anyone can read ads" ON ads;
CREATE POLICY "Anyone can read ads" ON ads
  FOR SELECT USING (true);

-- Allow public read for profiles (for user count)
DROP POLICY IF EXISTS "Anyone can read profiles" ON profiles;
CREATE POLICY "Anyone can read profiles" ON profiles
  FOR SELECT USING (true);

-- =====================================================
-- Admin write access (if logged in as admin)
-- =====================================================

-- Allow any authenticated user to insert/update/delete tips (for now)
DROP POLICY IF EXISTS "Authenticated can manage tips" ON health_tips;
CREATE POLICY "Authenticated can manage tips" ON health_tips
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Allow any authenticated user to manage ads
DROP POLICY IF EXISTS "Authenticated can manage ads" ON ads;
CREATE POLICY "Authenticated can manage ads" ON ads
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Check current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('health_tips', 'ads', 'profiles');
