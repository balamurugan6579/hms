import { describe, expect, it } from 'vitest';
import { isSupabaseConfigValid } from '../src/lib/supabaseConfig.js';

describe('Supabase production configuration', () => {
    it('rejects missing project credentials without requiring a client to initialize', () => {
        expect(isSupabaseConfigValid(undefined, undefined)).toBe(false);
        expect(isSupabaseConfigValid('https://hospital.supabase.co', undefined)).toBe(false);
        expect(isSupabaseConfigValid(undefined, 'sb_publishable_example')).toBe(false);
    });

    it('accepts a project URL and a publishable key', () => {
        expect(isSupabaseConfigValid('https://hospital.supabase.co', 'sb_publishable_example')).toBe(true);
    });

    it('rejects malformed project URLs and non-public keys', () => {
        expect(isSupabaseConfigValid('not-a-url', 'sb_publishable_example')).toBe(false);
        expect(isSupabaseConfigValid('https://hospital.supabase.co', 'not-a-public-key')).toBe(false);
    });
});
