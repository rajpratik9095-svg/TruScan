-- COMPLETE RLS POLICIES FOR TRUESCAN
-- Run this in Supabase SQL Editor

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Allow users to read their own profile
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- USER_PREFERENCES TABLE POLICIES
-- =====================================================

-- Allow users to read their own preferences
CREATE POLICY "Users can read own preferences" ON user_preferences
  FOR SELECT USING (auth.uid() = user_id);

-- Allow users to insert their own preferences
CREATE POLICY "Users can insert own preferences" ON user_preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own preferences
CREATE POLICY "Users can update own preferences" ON user_preferences
  FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- SCANNED_PRODUCTS TABLE POLICIES
-- =====================================================

-- Allow users to manage their own scan history
CREATE POLICY "Users can manage own scans" ON scanned_products
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- DIET_ENTRIES TABLE POLICIES
-- =====================================================

-- Allow users to manage their own diet entries
CREATE POLICY "Users can manage own diet entries" ON diet_entries
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- REMINDERS TABLE POLICIES
-- =====================================================

-- Allow users to manage their own reminders
CREATE POLICY "Users can manage own reminders" ON reminders
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- WATER_INTAKE TABLE POLICIES
-- =====================================================

-- Allow users to manage their own water intake
CREATE POLICY "Users can manage own water intake" ON water_intake
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- STEP_COUNT TABLE POLICIES
-- =====================================================

-- Allow users to manage their own step count
CREATE POLICY "Users can manage own step count" ON step_count
  FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- NOTE: If you get "policy already exists" error, run these first:
-- =====================================================
-- DROP POLICY IF EXISTS "Users can read own profile" ON users;
-- DROP POLICY IF EXISTS "Users can insert own profile" ON users;
-- DROP POLICY IF EXISTS "Users can update own profile" ON users;
-- DROP POLICY IF EXISTS "Users can read own preferences" ON user_preferences;
-- DROP POLICY IF EXISTS "Users can insert own preferences" ON user_preferences;
-- DROP POLICY IF EXISTS "Users can update own preferences" ON user_preferences;
-- Then run the CREATE statements again
