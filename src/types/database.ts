export interface Package {
  id: string;
  slug: string;
  title: string;
  short_description: string;
  description: string;
  duration_days: number;
  route: string;
  best_time: string;
  interests: string[];
  cover_image: string;
  gallery: string[];
  inclusions: string[];
  exclusions: string[];
  notes: string | null;
  is_featured: boolean;
  is_published: boolean;
  sort_order: number;
}

export interface PackageTier {
  id: string;
  package_id: string;
  tier: 'essential' | 'comfort' | 'signature';
  price_usd: number;
  stay_details: string;
  transport_details: string;
  extras: string | null;
}

export interface ItineraryDay {
  id: string;
  package_id: string;
  day_number: number;
  title: string;
  description: string;
  overnight_location: string;
}

export interface Testimonial {
  id: string;
  name: string;
  country: string;
  text: string;
  rating: number;
}
