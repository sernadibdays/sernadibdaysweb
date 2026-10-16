import { supabase } from '../lib/supabase';

export const getFaqs = async () => {
  const { data, error } = await supabase
    .from('faqs')
    .select('*')
    .eq('is_published', true)
    .order('sort_order', { ascending: true });
    
  if (error) throw error;
  return data;
};
