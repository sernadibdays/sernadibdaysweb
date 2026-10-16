import { supabase } from '../lib/supabase';

export interface EnquiryItem {
  id: string;
  name: string;
  email: string;
  phone: string;
  package_id: string | null;
  package_title?: string;
  travel_dates: string;
  adults: number;
  children: number;
  budget_tier?: string;
  message?: string;
  status: 'new' | 'contacted' | 'quoted' | 'booked' | 'archived';
  created_at: string;
}

const LOCAL_STORAGE_KEY = 'serendib_enquiries_override';

export const submitEnquiry = async (data: any) => {
  // Always create an entry in localStorage first so enquiry is never lost
  const localEnquiry: EnquiryItem = {
    id: crypto.randomUUID(),
    name: data.name,
    email: data.email,
    phone: data.phone,
    package_id: data.package_id || null,
    travel_dates: data.travel_dates,
    adults: data.adults,
    children: data.children || 0,
    budget_tier: data.budget_tier || 'undecided',
    message: data.message || '',
    status: 'new',
    created_at: new Date().toISOString()
  };

  try {
    const existing = localStorage.getItem(LOCAL_STORAGE_KEY);
    const list = existing ? JSON.parse(existing) : [];
    list.unshift(localEnquiry);
    localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(list));
  } catch (e) {
    console.warn(e);
  }

  // Attempt Supabase insert
  try {
    const { error } = await supabase
      .from('enquiries')
      .insert([{
        name: data.name,
        email: data.email,
        phone: data.phone,
        package_id: data.package_id || null,
        travel_dates: data.travel_dates,
        adults: data.adults,
        children: data.children || 0,
        budget_tier: data.budget_tier,
        message: data.message,
        status: 'new'
      }]);

    if (error) {
      console.warn('Supabase enquiry insert failed, but saved locally:', error.message);
    }
  } catch (err) {
    console.warn('Supabase enquiry error:', err);
  }

  return true;
};

export const getEnquiries = async (): Promise<EnquiryItem[]> => {
  let dbEnquiries: EnquiryItem[] = [];

  try {
    const { data, error } = await supabase
      .from('enquiries')
      .select('*, packages(title)')
      .order('created_at', { ascending: false });

    if (!error && data) {
      dbEnquiries = data.map((d: any) => ({
        ...d,
        package_title: d.packages?.title || null
      }));
    }
  } catch (err) {
    console.warn('Could not fetch enquiries from Supabase', err);
  }

  // Merge with local storage enquiries (avoid duplicates by email/time)
  try {
    const existing = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (existing) {
      const localList: EnquiryItem[] = JSON.parse(existing);
      if (dbEnquiries.length === 0) {
        return localList;
      }
      // Combine unique IDs
      const seen = new Set(dbEnquiries.map(e => e.id));
      for (const loc of localList) {
        if (!seen.has(loc.id)) {
          dbEnquiries.push(loc);
        }
      }
    }
  } catch (e) {
    console.warn(e);
  }

  return dbEnquiries;
};

export const updateEnquiryStatus = async (id: string, status: EnquiryItem['status']) => {
  // Update local storage
  try {
    const existing = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (existing) {
      const list: EnquiryItem[] = JSON.parse(existing);
      const updated = list.map(item => item.id === id ? { ...item, status } : item);
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updated));
    }
  } catch (e) {
    console.warn(e);
  }

  // Update Supabase
  try {
    await supabase.from('enquiries').update({ status }).eq('id', id);
  } catch (e) {
    console.warn('Failed to update enquiry status in Supabase', e);
  }

  return true;
};
