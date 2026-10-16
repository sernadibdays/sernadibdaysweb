import { supabase } from '../lib/supabase';
import siteContentBackup from '../data/siteContentBackup.json';

export interface SiteContentItem {
  id?: string;
  key: string;
  title: string;
  value: string;
  description?: string;
}

const LOCAL_STORAGE_KEY = 'serendib_site_content_override';

export const getSiteContent = async (): Promise<Record<string, string>> => {
  // Start with default backup values
  const contentMap: Record<string, string> = { ...siteContentBackup };

  // Check localStorage for any local admin overrides
  try {
    const saved = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (saved) {
      Object.assign(contentMap, JSON.parse(saved));
    }
  } catch (e) {
    console.warn('Could not read local content override', e);
  }

  // Try fetching from Supabase site_content table
  try {
    const { data, error } = await supabase
      .from('site_content')
      .select('key, value');

    if (!error && data && data.length > 0) {
      data.forEach((item: { key: string; value: string }) => {
        contentMap[item.key] = item.value;
      });
    }
  } catch (err) {
    console.warn('Using fallback site content', err);
  }

  return contentMap;
};

export const updateSiteContent = async (key: string, value: string, title?: string) => {
  // Save to localStorage immediately for instant UI responsiveness
  try {
    const current = localStorage.getItem(LOCAL_STORAGE_KEY);
    const map = current ? JSON.parse(current) : {};
    map[key] = value;
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(map));
  } catch (e) {
    console.error(e);
  }

  // Persist to Supabase if table exists
  try {
    const { error } = await supabase
      .from('site_content')
      .upsert({
        key,
        value,
        title: title || key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
        updated_at: new Date().toISOString()
      }, { onConflict: 'key' });

    if (error) {
      console.warn('Supabase site_content table might not be initialized yet:', error.message);
    }
  } catch (err) {
    console.warn('Error saving site content to Supabase', err);
  }

  return true;
};
