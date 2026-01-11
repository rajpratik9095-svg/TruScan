-- =====================================================
-- TrueScan Admin Tables Setup
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create admin_users table
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  role TEXT DEFAULT 'admin' CHECK (role IN ('super_admin', 'admin', 'moderator')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policy - Admin can read their own record
CREATE POLICY "Admin can read own record" ON admin_users
  FOR SELECT USING (auth.uid() = user_id);

-- 4. RLS Policy - Super admin can read all
CREATE POLICY "Super admin can read all" ON admin_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE user_id = auth.uid() AND role = 'super_admin'
    )
  );

-- =====================================================
-- 5. Add your email as super admin
-- IMPORTANT: Replace with YOUR email that you use to login
-- =====================================================
INSERT INTO admin_users (user_id, email, full_name, role) 
SELECT id, email, raw_user_meta_data->>'full_name', 'super_admin'
FROM auth.users 
WHERE email = 'YOUR_EMAIL@example.com'  -- <-- CHANGE THIS TO YOUR EMAIL
ON CONFLICT (email) DO UPDATE SET role = 'super_admin';

-- =====================================================
-- 6. Update health_tips RLS for admin write access
-- =====================================================

-- Drop old policies if exist
DROP POLICY IF EXISTS "Admin can manage tips" ON health_tips;

-- Create new policy for admin CRUD
CREATE POLICY "Admin can manage tips" ON health_tips
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- =====================================================
-- 7. Update ads RLS for admin write access
-- =====================================================

DROP POLICY IF EXISTS "Admin can manage ads" ON ads;

CREATE POLICY "Admin can manage ads" ON ads
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- =====================================================
-- 8. Function to check if user is admin
-- =====================================================
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_users 
    WHERE user_id = auth.uid() AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- QUICK SETUP: Run this single query with YOUR email
-- =====================================================
-- 
-- INSERT INTO admin_users (user_id, email, full_name, role) 
-- SELECT id, email, 'Admin', 'super_admin'
-- FROM auth.users 
-- WHERE email = 'your-email@gmail.com';
--
-- =====================================================

-- Check current admin users
SELECT * FROM admin_users;
