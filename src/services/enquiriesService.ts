import { supabase } from '../lib/supabase';

export const submitEnquiry = async (data: any) => {
  const { error } = await supabase
    .from('enquiries')
    .insert([{
      name: data.name,
      email: data.email,
      phone: data.phone,
      package_id: data.package_id || null,
      travel_dates: data.travel_dates,
      adults: data.adults,
      children: data.children,
      budget_tier: data.budget_tier,
      message: data.message
    }]);

  if (error) throw error;
  return true;
};
