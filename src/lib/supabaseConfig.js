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

export const isSupabaseConfigValid = (supabaseUrl, supabaseKey) => {
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
