import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY;

export const supabase = createClient(
    supabaseUrl || 'https://placeholder.supabase.co',
    supabaseKey || 'missing-supabase-key',
    {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: true
        }
    }
);

export const isKeyValid = () => {
    if (!supabaseUrl || !supabaseKey) return false;

    try {
        const url = new URL(supabaseUrl);
        const isSupportedKey = supabaseKey.startsWith('sb_publishable_') || supabaseKey.startsWith('eyJ');
        return url.protocol === 'https:' && isSupportedKey;
    } catch {
        return false;
    }
};
