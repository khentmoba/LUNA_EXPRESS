import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('[Garden] Supabase credentials missing. running in offline mode.');
}

export const supabase = (supabaseUrl && supabaseAnonKey) 
  ? createClient(supabaseUrl, supabaseAnonKey) 
  : null;

/**
 * DB helper to abstract common Supabase operations
 */
export const DB = {
  async select(table, options = {}) {
    if (!supabase) return [];
    let query = supabase.from(table).select('*');
    if (options.descending) query = query.order(options.orderField || 'id', { ascending: false });
    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  async insert(table, row) {
    if (!supabase) return null;
    const { data, error } = await supabase.from(table).insert([row]).select();
    if (error) throw error;
    return data;
  },

  async update(table, id, updates) {
    if (!supabase) return null;
    const { data, error } = await supabase.from(table).update(updates).eq('id', id).select();
    if (error) throw error;
    return data;
  },

  async del(table, id) {
    if (!supabase) return null;
    const { error } = await supabase.from(table).delete().eq('id', id);
    if (error) throw error;
    return true;
  },

  async uploadFile(bucket, path, file, type) {
    if (!supabase) throw new Error('Supabase client not initialized');
    const { data, error } = await supabase.storage.from(bucket).upload(path, file, {
      contentType: type,
      upsert: true
    });
    if (error) throw error;
    return data;
  },

  publicUrl(bucket, path) {
    if (!supabase) return '';
    const { data } = supabase.storage.from(bucket).getPublicUrl(path);
    return data.publicUrl;
  }
};
