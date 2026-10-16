import { supabase } from '../lib/supabase';

export const getTestimonials = async () => {
  const { data, error } = await supabase
    .from('testimonials')
    .select('*')
    .eq('is_published', true)
    .order('created_at', { ascending: false });
    
  if (error) throw error;
  return data;
};
