import { supabase } from '../lib/supabase';
import type { Testimonial } from '../types/database';
import testimonialsBackup from '../data/testimonialsBackup.json';

const LOCAL_STORAGE_KEY = 'serendib_testimonials_override';

export const getTestimonials = async (): Promise<Testimonial[]> => {
  try {
    const { data, error } = await supabase
      .from('testimonials')
      .select('*')
      .eq('is_published', true)
      .order('sort_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (!error && data && data.length > 0) {
      return data as Testimonial[];
    }
  } catch (err) {
    console.warn('Supabase testimonials fetch failed, checking local fallback', err);
  }

  // Check localStorage overrides
  try {
    const local = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (local) {
      const parsed = JSON.parse(local);
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed.filter((t: any) => t.is_published !== false);
      }
    }
  } catch (e) {
    console.warn(e);
  }

  return testimonialsBackup as Testimonial[];
};

export const getAllTestimonialsAdmin = async (): Promise<Testimonial[]> => {
  try {
    const { data, error } = await supabase
      .from('testimonials')
      .select('*')
      .order('created_at', { ascending: false });

    if (!error && data && data.length > 0) {
      return data as Testimonial[];
    }
  } catch (err) {
    console.warn('Could not fetch admin testimonials from Supabase', err);
  }

  try {
    const local = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (local) {
      return JSON.parse(local);
    }
  } catch (e) {
    console.warn(e);
  }

  return testimonialsBackup as Testimonial[];
};

export const saveTestimonial = async (testimonial: Partial<Testimonial>) => {
  const current = await getAllTestimonialsAdmin();
  let updatedList: any[];

  if (testimonial.id) {
    updatedList = current.map(t => t.id === testimonial.id ? { ...t, ...testimonial } : t);
  } else {
    const newId = crypto.randomUUID();
    const newT = {
      id: newId,
      name: testimonial.name || 'Anonymous',
      country: testimonial.country || 'Global Traveller',
      text: testimonial.text || '',
      rating: testimonial.rating || 5,
      is_published: testimonial.is_published ?? true,
      created_at: new Date().toISOString()
    };
    updatedList = [newT, ...current];
  }

  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updatedList));

  try {
    const { error } = await supabase
      .from('testimonials')
      .upsert({
        id: testimonial.id || crypto.randomUUID(),
        name: testimonial.name,
        country: testimonial.country,
        text: testimonial.text,
        rating: testimonial.rating,
        is_published: testimonial.is_published ?? true
      });
    if (error) console.warn('Supabase testimonials upsert error:', error.message);
  } catch (e) {
    console.warn('Failed to upsert to Supabase', e);
  }

  return updatedList;
};

export const deleteTestimonial = async (id: string) => {
  const current = await getAllTestimonialsAdmin();
  const updatedList = current.filter(t => t.id !== id);
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updatedList));

  try {
    await supabase.from('testimonials').delete().eq('id', id);
  } catch (e) {
    console.warn('Delete from Supabase failed', e);
  }

  return updatedList;
};
