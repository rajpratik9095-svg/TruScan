-- TrueScan Complete Database Schema for Supabase
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  avatar_url TEXT,
  is_premium BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- 2. USER PREFERENCES TABLE
-- =====================================================
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  language TEXT DEFAULT 'en_US',
  theme_mode TEXT DEFAULT 'light',
  calorie_goal INTEGER DEFAULT 2000,
  water_goal INTEGER DEFAULT 8,
  step_goal INTEGER DEFAULT 10000,
  push_notifications BOOLEAN DEFAULT true,
  email_notifications BOOLEAN DEFAULT true,
  reminder_enabled BOOLEAN DEFAULT true,
  ads_enabled BOOLEAN DEFAULT true,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own preferences" ON user_preferences
  USING (auth.uid() = user_id);

-- =====================================================
-- 3. PRODUCTS TABLE (PUBLIC)
-- =====================================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  barcode TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  brand TEXT,
  category TEXT,
  image_url TEXT,
  ingredients TEXT[],
  allergens TEXT[],
  health_score DECIMAL(3,1),
  calories DECIMAL(6,2),
  protein DECIMAL(5,2),
  carbs DECIMAL(5,2),
  fats DECIMAL(5,2),
  fiber DECIMAL(5,2),
  sugar DECIMAL(5,2),
  sodium DECIMAL(6,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_products_barcode ON products(barcode);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

-- =====================================================
-- 4. SCANNED PRODUCTS HISTORY
-- =====================================================
CREATE TABLE scanned_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  barcode TEXT NOT NULL,
  scanned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_scanned_user_date ON scanned_products(user_id, scanned_at DESC);

ALTER TABLE scanned_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own scans" ON scanned_products
  USING (auth.uid() = user_id);

-- =====================================================
-- 5. DIET ENTRIES TABLE
-- =====================================================
CREATE TABLE diet_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snacks')),
  food_name TEXT NOT NULL,
  calories DECIMAL(7,2) NOT NULL,
  protein DECIMAL(6,2) DEFAULT 0,
  carbs DECIMAL(6,2) DEFAULT 0,
  fats DECIMAL(6,2) DEFAULT 0,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  synced BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_diet_entries_user_date ON diet_entries(user_id, entry_date DESC);

ALTER TABLE diet_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own diet entries" ON diet_entries
  USING (auth.uid() = user_id);

-- =====================================================
-- 6. DIET PLANS TABLE
-- =====================================================
CREATE TABLE diet_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_name TEXT NOT NULL,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('weight_loss', 'weight_gain', 'maintain', 'custom')),
  target_calories INTEGER NOT NULL,
  duration_days INTEGER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  is_active BOOLEAN DEFAULT true,
  metadata JSONB, -- For storing additional plan details
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_diet_plans_user ON diet_plans(user_id, is_active);

ALTER TABLE diet_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own diet plans" ON diet_plans
  USING (auth.uid() = user_id);

-- =====================================================
-- 7. REMINDERS TABLE
-- =====================================================
CREATE TABLE reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reminder_type TEXT NOT NULL CHECK (reminder_type IN ('water', 'calories', 'meal', 'custom')),
  title TEXT NOT NULL,
  message TEXT,
  frequency TEXT NOT NULL CHECK (frequency IN ('once', 'daily', 'hourly', 'weekly')),
  reminder_time TIME,
  interval_minutes INTEGER,
  days_of_week INTEGER[],
  is_active BOOLEAN DEFAULT true,
  last_triggered_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_reminders_user_active ON reminders(user_id, is_active);

ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own reminders" ON reminders
  USING (auth.uid() = user_id);

-- =====================================================
-- 8. WATER INTAKE TABLE
-- =====================================================
CREATE TABLE water_intake (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  glasses INTEGER NOT NULL DEFAULT 1,
  ml_amount INTEGER,
  intake_date DATE NOT NULL DEFAULT CURRENT_DATE,
  intake_time TIME NOT NULL DEFAULT CURRENT_TIME,
  synced BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_water_user_date ON water_intake(user_id, intake_date DESC);

ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own water intake" ON water_intake
  USING (auth.uid() = user_id);

-- =====================================================
-- 9. STEP COUNT TABLE
-- =====================================================
CREATE TABLE step_count (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  steps INTEGER NOT NULL DEFAULT 0,
  distance_meters DECIMAL(10,2),
  calories_burned DECIMAL(6,2),
  activity_date DATE NOT NULL DEFAULT CURRENT_DATE,
  synced BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, activity_date)
);

CREATE INDEX idx_steps_user_date ON step_count(user_id, activity_date DESC);

ALTER TABLE step_count ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own step count" ON step_count
  USING (auth.uid() = user_id);

-- =====================================================
-- 10. OFFLINE QUEUE TABLE
-- =====================================================
CREATE TABLE offline_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_offline_queue_user ON offline_queue(user_id, created_at);

ALTER TABLE offline_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own offline queue" ON offline_queue
  USING (auth.uid() = user_id);

-- =====================================================
-- 11. APP CONTENT TABLE (Privacy, Terms, etc.)
-- =====================================================
CREATE TABLE app_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_type TEXT NOT NULL,
  language TEXT DEFAULT 'en',
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(content_type, language)
);

ALTER TABLE app_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "App content is publicly readable" ON app_content
  FOR SELECT USING (true);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert sample products
INSERT INTO products (barcode, name, brand, category, image_url, health_score, calories, protein, carbs, fats, fiber, sugar, sodium, ingredients, allergens) VALUES
('1234567890123', 'Whole Wheat Bread', 'Healthy Bakery', 'Bakery', 'https://via.placeholder.com/300', 8.5, 247, 13.0, 41.0, 4.0, 7.0, 4.0, 400, ARRAY['Whole Wheat Flour', 'Water', 'Yeast', 'Salt', 'Honey', 'Olive Oil'], ARRAY['Gluten', 'Wheat']),
('9876543210987', 'Organic Milk', 'Pure Dairy', 'Dairy', 'https://via.placeholder.com/300', 7.5, 149, 8.0, 12.0, 8.0, 0, 12.0, 105, ARRAY['Organic Whole Milk', 'Vitamin D3'], ARRAY['Milk', 'Lactose']),
('5555555555555', 'Mixed Nuts', 'Nature''s Best', 'Snacks', 'https://via.placeholder.com/300', 9.0, 607, 20.0, 27.0, 54.0, 7.0, 5.0, 16, ARRAY['Almonds', 'Cashews', 'Walnuts', 'Pistachios', 'Sea Salt'], ARRAY['Tree Nuts']);

-- Insert Privacy Policy
INSERT INTO app_content (content_type, language, title, content) VALUES
('privacy', 'en', 'Privacy Policy', 'Your privacy is important to us. This policy explains how TrueScan collects, uses, and protects your personal information...'),
('privacy', 'hi', 'गोपनीयता नीति', 'आपकी गोपनीयता हमारे लिए महत्वपूर्ण है। यह नीति बताती है कि TrueScan आपकी व्यक्तिगत जानकारी कैसे एकत्र, उपयोग और सुरक्षित करता है...');

-- Insert Terms & Conditions
INSERT INTO app_content (content_type, language, title, content) VALUES
('terms', 'en', 'Terms & Conditions', 'By using TrueScan, you agree to these terms and conditions...'),
('terms', 'hi', 'नियम और शर्तें', 'TrueScan का उपयोग करके, आप इन नियमों और शर्तों से सहमत हैं...');

-- =====================================================
-- FUNCTIONS FOR AUTO-UPDATE TIMESTAMPS
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_step_count_updated_at BEFORE UPDATE ON step_count
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMPLETED!
-- =====================================================
-- All tables created successfully
-- Row Level Security enabled
-- Sample data inserted
-- Ready to use!
