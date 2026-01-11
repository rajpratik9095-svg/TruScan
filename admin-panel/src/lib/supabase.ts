import { createClient } from '@supabase/supabase-js';

// Using same Supabase credentials as Flutter app
const supabaseUrl = 'https://csyddaddizizjtiqwxou.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzeWRkYWRkaXppemp0aXF3eG91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4MjkxNTUsImV4cCI6MjA4MzQwNTE1NX0.fwZ7-aemTfT9rBe8pc1cCQp4Ct-buZIw54XcJMhPFW4';

export const supabase = createClient(supabaseUrl, supabaseKey);
