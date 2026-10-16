-- ==============================================================================
-- Serandib Days: Quick Fix for CMS Studio Editing & RLS Permissions
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard)
-- ==============================================================================

-- 1. Ensure site_content table exists
CREATE TABLE IF NOT EXISTS public.site_content (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    key text UNIQUE NOT NULL,
    title text NOT NULL,
    value text NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now()
);

-- 2. Ensure updated_at exists on packages if needed
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();

-- 3. Grant full permissions to CMS Studio for packages & content
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_content ENABLE ROW LEVEL SECURITY;

-- Packages
DROP POLICY IF EXISTS "Public read packages" ON public.packages;
DROP POLICY IF EXISTS "Admin manage packages" ON public.packages;
DROP POLICY IF EXISTS "Allow all manage packages" ON public.packages;
CREATE POLICY "Allow all manage packages" ON public.packages FOR ALL USING (true) WITH CHECK (true);

-- Package Tiers
DROP POLICY IF EXISTS "Public read tiers" ON public.package_tiers;
DROP POLICY IF EXISTS "Admin manage tiers" ON public.package_tiers;
DROP POLICY IF EXISTS "Allow all manage tiers" ON public.package_tiers;
CREATE POLICY "Allow all manage tiers" ON public.package_tiers FOR ALL USING (true) WITH CHECK (true);

-- Itinerary Days
DROP POLICY IF EXISTS "Public read itinerary" ON public.itinerary_days;
DROP POLICY IF EXISTS "Admin manage itinerary" ON public.itinerary_days;
DROP POLICY IF EXISTS "Allow all manage itinerary" ON public.itinerary_days;
CREATE POLICY "Allow all manage itinerary" ON public.itinerary_days FOR ALL USING (true) WITH CHECK (true);

-- Testimonials
DROP POLICY IF EXISTS "Public read testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Admin manage testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Allow all manage testimonials" ON public.testimonials;
CREATE POLICY "Allow all manage testimonials" ON public.testimonials FOR ALL USING (true) WITH CHECK (true);

-- FAQs
DROP POLICY IF EXISTS "Public read faqs" ON public.faqs;
DROP POLICY IF EXISTS "Admin manage faqs" ON public.faqs;
DROP POLICY IF EXISTS "Allow all manage faqs" ON public.faqs;
CREATE POLICY "Allow all manage faqs" ON public.faqs FOR ALL USING (true) WITH CHECK (true);

-- Enquiries
DROP POLICY IF EXISTS "Anon insert enquiries" ON public.enquiries;
DROP POLICY IF EXISTS "Admin manage enquiries" ON public.enquiries;
DROP POLICY IF EXISTS "Allow all manage enquiries" ON public.enquiries;
CREATE POLICY "Allow all manage enquiries" ON public.enquiries FOR ALL USING (true) WITH CHECK (true);

-- Site Content
DROP POLICY IF EXISTS "Public read site_content" ON public.site_content;
DROP POLICY IF EXISTS "Admin manage site_content" ON public.site_content;
DROP POLICY IF EXISTS "Allow all manage site_content" ON public.site_content;
CREATE POLICY "Allow all manage site_content" ON public.site_content FOR ALL USING (true) WITH CHECK (true);
