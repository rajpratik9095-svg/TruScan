-- Add gemini_api_key column to admin_users table
-- Run this in Supabase SQL Editor

-- Add API key column to admin_users table
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS gemini_api_key TEXT;

-- Set default API key for existing admins
UPDATE admin_users SET gemini_api_key = 'AIzaSyBb7VvZ6VKYlaWBp3RrJzfWqmGXmEd2his' WHERE gemini_api_key IS NULL;

SELECT 'API key column added to admin_users table!' as status;
