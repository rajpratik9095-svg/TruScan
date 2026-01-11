-- Notifications Table for TrueScan
-- Run this in Supabase SQL Editor

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general', -- general, alert, promotion, reminder
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL means broadcast to all
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Disable RLS for easy access
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Sample data
INSERT INTO notifications (title, message, type, user_id) VALUES
('Welcome to TrueScan!', 'Thank you for joining. Start tracking your health today!', 'general', NULL),
('Daily Reminder', 'Don''t forget to log your steps today!', 'reminder', NULL);

SELECT 'Notifications table created successfully!' as status;
