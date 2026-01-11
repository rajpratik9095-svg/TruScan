-- Settings Table for TrueScan Admin Panel
-- Run this in Supabase SQL Editor

-- Create settings table
CREATE TABLE IF NOT EXISTS app_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description VARCHAR(255),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by UUID REFERENCES auth.users(id)
);

-- Disable RLS for easy access
ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;

-- Insert default settings
INSERT INTO app_settings (setting_key, setting_value, description) VALUES
('gemini_api_key', 'AIzaSyBb7VvZ6VKYlaWBp3RrJzfWqmGXmEd2his', 'Gemini AI API Key for health tips generation'),
('app_name', 'TrueScan', 'Application name'),
('app_version', '1.0.0', 'Application version')
ON CONFLICT (setting_key) DO NOTHING;

SELECT 'Settings table created successfully!' as status;
