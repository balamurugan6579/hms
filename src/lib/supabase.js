import { createClient } from '@supabase/supabase-js'
import { isSupabaseConfigValid } from './supabaseConfig.js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY;

export const isKeyValid = () => isSupabaseConfigValid(supabaseUrl, supabaseKey);

export const supabase = isKeyValid()
    ? createClient(
        supabaseUrl,
        supabaseKey,
        {
            auth: {
                persistSession: true,
                autoRefreshToken: true,
                detectSessionInUrl: true
            }
        }
    )
    : null;
