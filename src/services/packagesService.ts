import { supabase } from '../lib/supabase';
import type { Package, PackageTier, ItineraryDay } from '../types/database';
import packagesBackup from '../data/packagesBackup.json';

const LOCAL_STORAGE_KEY = 'serendib_packages_override';

// Helper to get local override packages
const getLocalOverridePackages = (): Package[] => {
  try {
    const saved = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (saved) {
      const parsed = JSON.parse(saved);
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed as Package[];
      }
    }
  } catch (e) {
    console.warn('Error reading local packages override', e);
  }
  return packagesBackup as Package[];
};

export const getPackages = async (): Promise<Package[]> => {
  try {
    const { data, error } = await supabase
      .from('packages')
      .select('*, package_tiers(*), itinerary_days(*)')
      .eq('is_published', true)
      .order('sort_order', { ascending: true });

    if (!error && data && data.length > 0) {
      return data as Package[];
    }
  } catch (error) {
    console.warn('Supabase packages fetch failed, utilizing fallback dataset', error);
  }

  // Fallback to local storage overrides or static backup
  const all = getLocalOverridePackages();
  return all.filter(p => p.is_published !== false).sort((a, b) => a.sort_order - b.sort_order);
};

export const getFeaturedPackages = async (): Promise<Package[]> => {
  try {
    const { data, error } = await supabase
      .from('packages')
      .select('*, package_tiers(*)')
      .eq('is_published', true)
      .eq('is_featured', true)
      .order('sort_order', { ascending: true })
      .limit(6);

    if (!error && data && data.length > 0) {
      return data as Package[];
    }
  } catch (error) {
    console.warn('Supabase featured packages fetch failed, utilizing fallback dataset', error);
  }

  const all = getLocalOverridePackages();
  const featured = all.filter(p => p.is_published !== false && p.is_featured);
  return featured.length > 0 ? featured.slice(0, 6) : all.slice(0, 6);
};

export const getPackageBySlug = async (slug: string): Promise<Package | null> => {
  try {
    const { data, error } = await supabase
      .from('packages')
      .select('*, package_tiers(*), itinerary_days(*)')
      .eq('slug', slug)
      .eq('is_published', true)
      .single();

    if (!error && data) {
      if (data.itinerary_days) {
        data.itinerary_days.sort((a: ItineraryDay, b: ItineraryDay) => a.day_number - b.day_number);
      }
      return data as Package;
    }
  } catch (error) {
    console.warn(`Supabase getPackageBySlug for ${slug} failed, utilizing fallback dataset`, error);
  }

  const all = getLocalOverridePackages();
  const found = all.find(p => p.slug === slug);
  if (found) {
    if (found.itinerary_days) {
      found.itinerary_days.sort((a: ItineraryDay, b: ItineraryDay) => a.day_number - b.day_number);
    }
    return found;
  }
  return null;
};

// Admin Operations
export const getAllPackagesAdmin = async (): Promise<Package[]> => {
  try {
    const { data, error } = await supabase
      .from('packages')
      .select('*, package_tiers(*), itinerary_days(*)')
      .order('sort_order', { ascending: true });

    if (!error && data && data.length > 0) {
      return data as Package[];
    }
  } catch (error) {
    console.warn('Could not fetch admin packages from Supabase', error);
  }

  return getLocalOverridePackages();
};

export const savePackageFull = async (
  pkgData: Partial<Package>,
  tiers: Partial<PackageTier>[],
  days: Partial<ItineraryDay>[]
): Promise<Package> => {
  const current = getLocalOverridePackages();
  const packageId = pkgData.id || crypto.randomUUID();

  const formattedTiers: PackageTier[] = tiers.map((t, idx) => ({
    id: t.id || crypto.randomUUID(),
    package_id: packageId,
    tier: (t.tier || (idx === 0 ? 'essential' : idx === 1 ? 'comfort' : 'signature')) as any,
    price_usd: Number(t.price_usd) || 0,
    stay_details: t.stay_details || 'Boutique stay',
    transport_details: t.transport_details || 'Private vehicle',
    extras: t.extras || null
  }));

  const formattedDays: ItineraryDay[] = days.map((d, idx) => ({
    id: d.id || crypto.randomUUID(),
    package_id: packageId,
    day_number: idx + 1,
    title: d.title || `Day ${idx + 1}`,
    description: d.description || '',
    overnight_location: d.overnight_location || 'Local Hotel'
  }));

  const fullPackage: Package = {
    id: packageId,
    slug: pkgData.slug || (pkgData.title ? pkgData.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '') : `pkg-${Date.now()}`),
    title: pkgData.title || 'Untitled Journey',
    short_description: pkgData.short_description || '',
    description: pkgData.description || '',
    duration_days: Number(pkgData.duration_days) || (formattedDays.length > 0 ? formattedDays.length : 1),
    route: pkgData.route || 'Colombo & Beyond',
    best_time: pkgData.best_time || 'Year-round',
    interests: Array.isArray(pkgData.interests) ? pkgData.interests : ['Culture & Heritage'],
    cover_image: pkgData.cover_image || 'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=1200&q=80',
    gallery: Array.isArray(pkgData.gallery) ? pkgData.gallery : [],
    inclusions: Array.isArray(pkgData.inclusions) ? pkgData.inclusions : [
      'Private air-conditioned vehicle with fuel and insurance',
      'English-speaking chauffeur-guide throughout the journey',
      'Handpicked accommodations with daily breakfast',
      'Government taxes and service charges'
    ],
    exclusions: Array.isArray(pkgData.exclusions) ? pkgData.exclusions : [
      'International flight tickets and entry visa',
      'Personal expenses, tips and alcoholic drinks',
      'Optional adventure activities not mentioned in itinerary'
    ],
    notes: pkgData.notes || null,
    is_featured: !!pkgData.is_featured,
    is_published: pkgData.is_published !== false,
    sort_order: Number(pkgData.sort_order) || 1,
    package_tiers: formattedTiers,
    itinerary_days: formattedDays
  };

  // Update local storage
  const existingIdx = current.findIndex(p => p.id === packageId || p.slug === fullPackage.slug);
  let updatedList: Package[];
  if (existingIdx >= 0) {
    updatedList = [...current];
    updatedList[existingIdx] = fullPackage;
  } else {
    updatedList = [...current, fullPackage];
  }
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updatedList));

  // Sync to Supabase (using schema-exact columns)
  try {
    const packagePayload = {
      id: fullPackage.id,
      slug: fullPackage.slug,
      title: fullPackage.title,
      short_description: fullPackage.short_description,
      description: fullPackage.description,
      duration_days: fullPackage.duration_days,
      route: fullPackage.route,
      best_time: fullPackage.best_time,
      interests: fullPackage.interests,
      cover_image: fullPackage.cover_image,
      gallery: fullPackage.gallery,
      inclusions: fullPackage.inclusions,
      exclusions: fullPackage.exclusions,
      notes: fullPackage.notes,
      is_featured: fullPackage.is_featured,
      is_published: fullPackage.is_published,
      sort_order: fullPackage.sort_order
    };

    // Check if package already exists in Supabase
    const { data: existingPkg } = await supabase
      .from('packages')
      .select('id')
      .eq('id', fullPackage.id)
      .maybeSingle();

    let pkgError = null;
    if (existingPkg) {
      const { error } = await supabase
        .from('packages')
        .update(packagePayload)
        .eq('id', fullPackage.id);
      pkgError = error;
    } else {
      const { error } = await supabase
        .from('packages')
        .insert([packagePayload]);
      pkgError = error;
    }

    if (!pkgError) {
      // Sync tiers
      for (const tier of formattedTiers) {
        const tierPayload = {
          package_id: packageId,
          tier: tier.tier,
          price_usd: tier.price_usd,
          stay_details: tier.stay_details,
          transport_details: tier.transport_details,
          extras: tier.extras
        };

        const { data: existingTier } = await supabase
          .from('package_tiers')
          .select('id')
          .eq('package_id', packageId)
          .eq('tier', tier.tier)
          .maybeSingle();

        if (existingTier) {
          await supabase
            .from('package_tiers')
            .update(tierPayload)
            .eq('id', existingTier.id);
        } else {
          await supabase
            .from('package_tiers')
            .insert([{ ...tierPayload, id: tier.id }]);
        }
      }

      // Sync itinerary days
      for (const day of formattedDays) {
        const dayPayload = {
          package_id: packageId,
          day_number: day.day_number,
          title: day.title,
          description: day.description,
          overnight_location: day.overnight_location
        };

        const { data: existingDay } = await supabase
          .from('itinerary_days')
          .select('id')
          .eq('package_id', packageId)
          .eq('day_number', day.day_number)
          .maybeSingle();

        if (existingDay) {
          await supabase
            .from('itinerary_days')
            .update(dayPayload)
            .eq('id', existingDay.id);
        } else {
          await supabase
            .from('itinerary_days')
            .insert([{ ...dayPayload, id: day.id }]);
        }
      }
    } else {
      console.warn('Supabase package sync error (saved locally):', pkgError.message);
    }
  } catch (err) {
    console.warn('Could not sync package update to Supabase, saved locally:', err);
  }

  return fullPackage;
};

export const deletePackage = async (id: string): Promise<boolean> => {
  const current = getLocalOverridePackages();
  const updated = current.filter(p => p.id !== id);
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updated));

  try {
    await supabase.from('packages').delete().eq('id', id);
  } catch (e) {
    console.warn('Delete package from Supabase error', e);
  }

  return true;
};

export const togglePublishPackage = async (id: string, is_published: boolean) => {
  const current = getLocalOverridePackages();
  const updated = current.map(p => p.id === id ? { ...p, is_published } : p);
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updated));

  try {
    await supabase.from('packages').update({ is_published }).eq('id', id);
  } catch (e) {
    console.warn('Update publish status in Supabase error', e);
  }

  return true;
};

export const toggleFeaturedPackage = async (id: string, is_featured: boolean) => {
  const current = getLocalOverridePackages();
  const updated = current.map(p => p.id === id ? { ...p, is_featured } : p);
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(updated));

  try {
    await supabase.from('packages').update({ is_featured }).eq('id', id);
  } catch (e) {
    console.warn('Update featured status in Supabase error', e);
  }

  return true;
};
