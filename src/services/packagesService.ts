import { supabase } from '../lib/supabase';
import type { Package, PackageTier, ItineraryDay } from '../types/database';

export const getPackages = async () => {
  const { data, error } = await supabase
    .from('packages')
    .select('*, package_tiers(*)')
    .eq('is_published', true)
    .order('sort_order', { ascending: true });
    
  if (error) throw error;
  return data;
};

export const getFeaturedPackages = async () => {
  const { data, error } = await supabase
    .from('packages')
    .select('*, package_tiers(*)')
    .eq('is_published', true)
    .eq('is_featured', true)
    .order('sort_order', { ascending: true })
    .limit(3);
    
  if (error) throw error;
  return data;
};

export const getPackageBySlug = async (slug: string) => {
  const { data, error } = await supabase
    .from('packages')
    .select('*, package_tiers(*), itinerary_days(*)')
    .eq('slug', slug)
    .eq('is_published', true)
    .single();
    
  if (error) throw error;
  
  if (data && data.itinerary_days) {
    data.itinerary_days.sort((a: ItineraryDay, b: ItineraryDay) => a.day_number - b.day_number);
  }
  
  return data;
};
