import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY;

export const supabase = createClient(
    supabaseUrl,
    supabaseKey,
    {
        auth: {
            persistSession: true,
            autoRefreshToken: true,
            detectSessionInUrl: true
        }
    }
);

const isPublicKey = (key) => {
    if (key.startsWith('sb_publishable_')) return true;
    if (!key.startsWith('eyJ')) return false;

    try {
        const payload = JSON.parse(atob(key.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
        return payload.role === 'anon';
    } catch {
        return false;
    }
};

export const isKeyValid = () => {
    if (!supabaseUrl || !supabaseKey) return false;

    try {
        const url = new URL(supabaseUrl);
        const isProjectUrl = url.protocol === 'https:'
            && url.hostname.endsWith('.supabase.co')
            && url.pathname === '/'
            && !url.search
            && !url.hash;

        return isProjectUrl && isPublicKey(supabaseKey);
    } catch {
        return false;
    }
};
