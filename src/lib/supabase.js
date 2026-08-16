
import { createClient } from '@supabase/supabase-js'

const defaultUrl = 'https://wbfpzixwytsrsnoswllm.supabase.co'
const defaultKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndiZnB6aXh3eXRzcnNub3N3bGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3MTQxMDcsImV4cCI6MjA4NjI5MDEwN30.5HOw3aAuWOj14-9-wZ9lI9yUj7VedM3Z8oA1J1h2N_E'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || defaultUrl;
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY || defaultKey;

export const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        persistSession: true, // Keep user logged in across refreshes
        autoRefreshToken: true,
        detectSessionInUrl: true
    }
});

export const isKeyValid = () => {
    return supabaseKey && supabaseKey !== 'your_supabase_anon_key_here' && supabaseKey !== 'placeholder';
};

