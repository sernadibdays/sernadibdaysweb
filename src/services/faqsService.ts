import { supabase } from '../lib/supabase';
import faqsBackup from '../data/faqsBackup.json';

export interface FAQItem {
  id: string;
  question: string;
  answer: string;
  sort_order: number;
  is_published: boolean;
}

const LOCAL_STORAGE_KEY = 'serendib_faqs_override';

export const getFaqs = async (): Promise<FAQItem[]> => {
  try {
    const { data, error } = await supabase
      .from('faqs')
      .select('*')
      .eq('is_published', true)
      .order('sort_order', { ascending: true });

    if (!error && data && data.length > 0) {
      return data as FAQItem[];
    }
  } catch (err) {
    console.warn('Supabase FAQs fetch failed, checking fallback', err);
  }

  // Check localStorage overrides
  try {
    const local = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (local) {
      const parsed = JSON.parse(local);
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed.filter((f: FAQItem) => f.is_published !== false);
      }
    }
  } catch (e) {
    console.warn(e);
  }

  return faqsBackup as FAQItem[];
};

export const getAllFaqsAdmin = async (): Promise<FAQItem[]> => {
  try {
    const { data, error } = await supabase
      .from('faqs')
      .select('*')
      .order('sort_order', { ascending: true });

    if (!error && data && data.length > 0) {
      return data as FAQItem[];
    }
  } catch (err) {
    console.warn('Could not fetch admin FAQs from Supabase', err);
  }

  try {
    const local = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (local) {
      return JSON.parse(local);
    }
  } catch (e) {
    console.warn(e);
  }

  return faqsBackup as FAQItem[];
};

export const saveFaq = async (faq: Partial<FAQItem>) => {
  const current = await getAllFaqsAdmin();
  let updatedList: FAQItem[];

  if (faq.id) {
    updatedList = current.map(f => f.id === faq.id ? { ...f, ...faq } as FAQItem : f);
  } else {
    const newFaq: FAQItem = {
      id: crypto.randomUUID(),
      question: faq.question || '',
      answer: faq.answer || '',
      sort_order: faq.sort_order ?? (current.length + 1),
      is_published: faq.is_published ?? true
    };
    updatedList = [...current, newFaq];
  }

  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updatedList));

  try {
    const { error } = await supabase
      .from('faqs')
      .upsert({
        id: faq.id || crypto.randomUUID(),
        question: faq.question,
        answer: faq.answer,
        sort_order: faq.sort_order ?? 0,
        is_published: faq.is_published ?? true
      });
    if (error) console.warn('Supabase FAQ upsert error:', error.message);
  } catch (e) {
    console.warn('Failed to upsert FAQ to Supabase', e);
  }

  return updatedList;
};

export const deleteFaq = async (id: string) => {
  const current = await getAllFaqsAdmin();
  const updatedList = current.filter(f => f.id !== id);
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updatedList));

  try {
    await supabase.from('faqs').delete().eq('id', id);
  } catch (e) {
    console.warn('Delete FAQ from Supabase failed', e);
  }

  return updatedList;
};
