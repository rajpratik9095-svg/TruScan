-- ============================================
-- TRUESCAN - Health Tips & Ads Tables
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. Create health_tips table
CREATE TABLE IF NOT EXISTS health_tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT DEFAULT 'health',
  image_url TEXT,
  icon TEXT DEFAULT 'lightbulb',
  priority INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create ads table
CREATE TABLE IF NOT EXISTS ads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  action_url TEXT,
  is_active BOOLEAN DEFAULT true,
  priority INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE health_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- 4. Create policies for public read access
CREATE POLICY "Anyone can read active health_tips" ON health_tips
  FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can read active ads" ON ads
  FOR SELECT USING (is_active = true);

-- ============================================
-- INSERT SAMPLE HEALTH TIPS (50+ Tips)
-- ============================================

INSERT INTO health_tips (title, content, category, icon, priority) VALUES

-- HEALTH CATEGORY (General Health)
('Stay Hydrated', 'Drink at least 8 glasses of water daily. Water helps maintain body temperature, removes toxins, and keeps your skin healthy. Try to drink a glass of water first thing in the morning!', 'health', 'water_drop', 100),
('Get Enough Sleep', 'Adults need 7-9 hours of sleep each night. Quality sleep improves memory, boosts immunity, and helps with weight management. Create a bedtime routine for better sleep.', 'health', 'bedtime', 99),
('Regular Health Checkups', 'Visit your doctor for annual checkups even when you feel healthy. Early detection of health issues can save lives. Keep track of your blood pressure, sugar, and cholesterol levels.', 'health', 'medical_services', 98),
('Wash Hands Frequently', 'Proper handwashing for 20 seconds can prevent many infections. Use soap and water, especially before eating and after using the restroom.', 'health', 'clean_hands', 97),
('Maintain Good Posture', 'Poor posture can lead to back pain, neck strain, and headaches. Sit straight, keep your shoulders relaxed, and take breaks if working at a desk.', 'health', 'accessibility', 96),
('Limit Screen Time', 'Too much screen time can cause eye strain, headaches, and sleep problems. Follow the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.', 'health', 'visibility', 95),
('Practice Deep Breathing', 'Deep breathing reduces stress, lowers blood pressure, and improves focus. Try 4-7-8 breathing: inhale for 4 seconds, hold for 7, exhale for 8.', 'health', 'air', 94),
('Protect Your Skin', 'Use sunscreen with SPF 30+ daily, even on cloudy days. UV rays can cause skin cancer and premature aging. Wear protective clothing and a hat outdoors.', 'health', 'wb_sunny', 93),
('Stay Vaccinated', 'Keep your vaccinations up to date including flu shots. Vaccines are safe and effective in preventing serious diseases.', 'health', 'vaccines', 92),
('Monitor Your Weight', 'Maintaining a healthy weight reduces the risk of heart disease, diabetes, and joint problems. Calculate your BMI and aim for a healthy range.', 'health', 'monitor_weight', 91),

-- NUTRITION CATEGORY
('Eat More Vegetables', 'Include 5 servings of vegetables daily. Vegetables are rich in vitamins, minerals, and fiber. Try to fill half your plate with vegetables at each meal.', 'nutrition', 'eco', 100),
('Choose Whole Grains', 'Replace white bread and rice with whole grain alternatives. Whole grains provide more fiber, vitamins, and help maintain stable blood sugar levels.', 'nutrition', 'grain', 99),
('Limit Sugar Intake', 'Excessive sugar can lead to obesity, diabetes, and tooth decay. Check food labels - sugar hides in processed foods, sauces, and drinks.', 'nutrition', 'no_food', 98),
('Eat More Protein', 'Protein is essential for muscle repair and satiety. Include lean meats, fish, eggs, beans, or tofu in each meal.', 'nutrition', 'restaurant', 97),
('Healthy Fats Matter', 'Not all fats are bad! Include healthy fats from nuts, avocados, olive oil, and fatty fish like salmon. Avoid trans fats and limit saturated fats.', 'nutrition', 'opacity', 96),
('Reduce Salt Intake', 'High sodium intake increases blood pressure. Limit processed foods, check labels, and use herbs and spices for flavor instead of salt.', 'nutrition', 'local_dining', 95),
('Eat Breakfast Daily', 'A healthy breakfast kickstarts your metabolism and provides energy. Include protein and fiber for sustained energy throughout the morning.', 'nutrition', 'free_breakfast', 94),
('Control Portion Sizes', 'Even healthy foods can lead to weight gain if eaten in excess. Use smaller plates and be mindful of serving sizes.', 'nutrition', 'straighten', 93),
('Include Fiber in Diet', 'Fiber aids digestion, controls blood sugar, and helps with weight management. Aim for 25-30 grams daily from fruits, vegetables, and whole grains.', 'nutrition', 'grass', 92),
('Stay Away from Processed Foods', 'Processed foods often contain hidden sugars, unhealthy fats, and excess sodium. Choose fresh, whole foods whenever possible.', 'nutrition', 'fastfood', 91),
('Eat Colorful Foods', 'Different colored fruits and vegetables contain different nutrients. Aim for a rainbow on your plate - red, orange, yellow, green, blue, and purple!', 'nutrition', 'palette', 90),
('Mindful Eating', 'Eat slowly and pay attention to hunger cues. It takes 20 minutes for your brain to register fullness. Put down your phone and enjoy your meal.', 'nutrition', 'self_improvement', 89),

-- FITNESS CATEGORY
('Walk 10,000 Steps Daily', 'Walking is the easiest form of exercise. 10,000 steps is approximately 8 kilometers. Use a pedometer or phone app to track your steps.', 'fitness', 'directions_walk', 100),
('Exercise Regularly', '150 minutes of moderate exercise per week keeps you healthy. This could be 30 minutes, 5 days a week. Find activities you enjoy!', 'fitness', 'fitness_center', 99),
('Stretch Every Morning', 'Morning stretches improve flexibility, reduce muscle tension, and prepare your body for the day. Take 5-10 minutes each morning.', 'fitness', 'self_improvement', 98),
('Take the Stairs', 'Skip the elevator and take the stairs. It is a simple way to add exercise to your daily routine and strengthen your leg muscles.', 'fitness', 'stairs', 97),
('Stand Up Every Hour', 'Sitting for long periods is harmful. Set a reminder to stand and move for 2-3 minutes every hour. It improves circulation and energy.', 'fitness', 'event_seat', 96),
('Try Strength Training', 'Strength training builds muscle, boosts metabolism, and strengthens bones. Start with bodyweight exercises like squats, pushups, and planks.', 'fitness', 'fitness_center', 95),
('Warm Up Before Exercise', 'Always warm up for 5-10 minutes before exercising. It prepares your muscles and reduces injury risk. Light jogging and dynamic stretches work well.', 'fitness', 'whatshot', 94),
('Cool Down After Workouts', 'After exercise, cool down with light activity and stretching. This helps your heart rate return to normal and prevents muscle stiffness.', 'fitness', 'ac_unit', 93),
('Join a Sports Activity', 'Team sports or group fitness classes make exercise fun and social. Try tennis, badminton, swimming, or a dance class.', 'fitness', 'sports_tennis', 92),
('Set Fitness Goals', 'Set specific, measurable fitness goals. Instead of "exercise more," try "walk 30 minutes daily" or "do 20 pushups." Track your progress!', 'fitness', 'track_changes', 91),

-- MENTAL HEALTH CATEGORY
('Practice Meditation', 'Just 10 minutes of daily meditation can reduce stress, improve focus, and enhance emotional well-being. Start with guided meditation apps.', 'mental', 'self_improvement', 100),
('Get Fresh Air Daily', 'Spending time outdoors improves mood, reduces stress, and provides vitamin D. Try to get at least 15-30 minutes of outdoor time daily.', 'mental', 'park', 99),
('Connect with Loved Ones', 'Social connections are vital for mental health. Call a friend, visit family, or join a community group. Loneliness affects both mental and physical health.', 'mental', 'people', 98),
('Practice Gratitude', 'Write down 3 things you are grateful for each day. Gratitude practice improves mood, sleep, and overall life satisfaction.', 'mental', 'favorite', 97),
('Limit Social Media', 'Excessive social media use is linked to anxiety and depression. Set time limits and take regular breaks from your phone.', 'mental', 'phonelink_off', 96),
('Learn Something New', 'Learning keeps your brain active and can boost self-esteem. Take up a new hobby, learn a language, or read about something interesting.', 'mental', 'school', 95),
('Take Mental Health Days', 'It is okay to take a day off when you need it. Mental health is just as important as physical health. Rest and recharge when necessary.', 'mental', 'spa', 94),
('Seek Help When Needed', 'If you are struggling with mental health, reach out to a professional. There is no shame in seeking help. Talk to a therapist or counselor.', 'mental', 'support_agent', 93),
('Create a Relaxing Space', 'Having a calm, organized space at home can reduce stress. Declutter your room, add plants, and create a cozy corner for relaxation.', 'mental', 'home', 92),
('Laugh More', 'Laughter is great medicine! It releases endorphins, reduces stress hormones, and strengthens your immune system. Watch comedy or spend time with funny friends.', 'mental', 'sentiment_satisfied', 91),

-- PRODUCT TIPS (Food Label Reading)
('Check Expiry Dates', 'Always check expiry dates before buying products. Expired food can cause food poisoning. Also check for damaged packaging.', 'product', 'event', 100),
('Read Nutrition Labels', 'Understanding nutrition labels helps you make healthier choices. Look at serving size, calories, sugar, sodium, and fiber content.', 'product', 'fact_check', 99),
('Understand Ingredients List', 'Ingredients are listed by weight - first ingredient is the most. If sugar appears in the first 3 ingredients, the product is likely unhealthy.', 'product', 'list', 98),
('Look for Hidden Sugars', 'Sugar has many names: sucrose, fructose, corn syrup, honey, agave. If a product lists multiple sweeteners, it is likely high in sugar.', 'product', 'warning', 97),
('Choose Low Sodium Options', 'Look for products with less than 600mg sodium per serving. Too much sodium can increase blood pressure.', 'product', 'local_dining', 96),
('Check for Artificial Additives', 'Avoid products with long lists of artificial colors, preservatives, and flavors. Choose products with simple, recognizable ingredients.', 'product', 'science', 95),
('Compare Product Brands', 'Different brands of the same product can have very different nutritional values. Compare and choose the healthier option.', 'product', 'compare_arrows', 94),
('Verify Organic Labels', 'Look for certified organic labels if you want to avoid pesticides. In India, look for the FSSAI organic certification mark.', 'product', 'verified', 93),
('Check Allergen Information', 'If you have food allergies, always check the allergen information. Common allergens include nuts, dairy, gluten, and soy.', 'product', 'warning', 92),
('Nutri-Score Explained', 'Nutri-Score is a nutrition rating system from A (best) to E (worst). A and B rated products are generally healthier. Use TrueScan to check Nutri-Score!', 'product', 'grade', 91);

-- ============================================
-- INSERT SAMPLE ADS
-- ============================================

INSERT INTO ads (title, description, image_url, action_url, priority, is_active) VALUES
('Premium Membership', 'Unlock all features! Remove ads, unlimited scans, detailed analytics.', 'https://via.placeholder.com/400x200/667eea/ffffff?text=TrueScan+Premium', 'https://truescan.app/premium', 100, true),
('Healthy Recipe Book', 'Download our free healthy recipe ebook with 100+ recipes!', 'https://via.placeholder.com/400x200/10B981/ffffff?text=Free+Recipe+Book', 'https://truescan.app/recipes', 90, true),
('Health Consultation', 'Talk to a nutritionist. First consultation FREE!', 'https://via.placeholder.com/400x200/F59E0B/ffffff?text=Free+Consultation', 'https://truescan.app/consult', 80, true);

-- ============================================
-- VERIFY DATA
-- ============================================
-- SELECT COUNT(*) as tips_count FROM health_tips;
-- SELECT COUNT(*) as ads_count FROM ads;
-- SELECT * FROM health_tips LIMIT 5;
