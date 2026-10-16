-- ==============================================================================
-- Serendib Days: Complete Supabase CMS Schema & Full Content Migration
-- ==============================================================================

-- 1. Create tables if they do not exist
CREATE TABLE IF NOT EXISTS public.packages (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    slug text UNIQUE NOT NULL,
    title text NOT NULL,
    short_description text NOT NULL,
    description text NOT NULL,
    duration_days integer NOT NULL,
    route text NOT NULL,
    best_time text NOT NULL,
    interests text[] DEFAULT '{}',
    cover_image text NOT NULL,
    gallery text[] DEFAULT '{}',
    inclusions text[] DEFAULT '{}',
    exclusions text[] DEFAULT '{}',
    notes text,
    is_featured boolean DEFAULT false,
    is_published boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.package_tiers (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    package_id uuid REFERENCES public.packages(id) ON DELETE CASCADE,
    tier text NOT NULL CHECK (tier IN ('essential', 'comfort', 'signature')),
    price_usd numeric NOT NULL,
    stay_details text NOT NULL,
    transport_details text NOT NULL,
    extras text,
    UNIQUE(package_id, tier)
);

CREATE TABLE IF NOT EXISTS public.itinerary_days (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    package_id uuid REFERENCES public.packages(id) ON DELETE CASCADE,
    day_number integer NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    overnight_location text NOT NULL,
    UNIQUE(package_id, day_number)
);

CREATE TABLE IF NOT EXISTS public.testimonials (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    country text NOT NULL,
    text text NOT NULL,
    rating integer CHECK (rating >= 1 AND rating <= 5),
    is_published boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.faqs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    question text NOT NULL,
    answer text NOT NULL,
    sort_order integer DEFAULT 0,
    is_published boolean DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.enquiries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    package_id uuid REFERENCES public.packages(id) ON DELETE SET NULL,
    travel_dates text NOT NULL,
    adults integer NOT NULL,
    children integer NOT NULL DEFAULT 0,
    budget_tier text,
    message text,
    status text DEFAULT 'new',
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.site_content (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    key text UNIQUE NOT NULL,
    title text NOT NULL,
    value text NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now()
);

-- 2. Row Level Security & Policies
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_content ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();

DROP POLICY IF EXISTS "Public read packages" ON public.packages;
DROP POLICY IF EXISTS "Admin manage packages" ON public.packages;
DROP POLICY IF EXISTS "Allow all manage packages" ON public.packages;
CREATE POLICY "Allow all manage packages" ON public.packages FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read tiers" ON public.package_tiers;
DROP POLICY IF EXISTS "Admin manage tiers" ON public.package_tiers;
DROP POLICY IF EXISTS "Allow all manage tiers" ON public.package_tiers;
CREATE POLICY "Allow all manage tiers" ON public.package_tiers FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read itinerary" ON public.itinerary_days;
DROP POLICY IF EXISTS "Admin manage itinerary" ON public.itinerary_days;
DROP POLICY IF EXISTS "Allow all manage itinerary" ON public.itinerary_days;
CREATE POLICY "Allow all manage itinerary" ON public.itinerary_days FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Admin manage testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Allow all manage testimonials" ON public.testimonials;
CREATE POLICY "Allow all manage testimonials" ON public.testimonials FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read faqs" ON public.faqs;
DROP POLICY IF EXISTS "Admin manage faqs" ON public.faqs;
DROP POLICY IF EXISTS "Allow all manage faqs" ON public.faqs;
CREATE POLICY "Allow all manage faqs" ON public.faqs FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon insert enquiries" ON public.enquiries;
DROP POLICY IF EXISTS "Admin manage enquiries" ON public.enquiries;
DROP POLICY IF EXISTS "Allow all manage enquiries" ON public.enquiries;
CREATE POLICY "Allow all manage enquiries" ON public.enquiries FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public read site_content" ON public.site_content;
DROP POLICY IF EXISTS "Admin manage site_content" ON public.site_content;
DROP POLICY IF EXISTS "Allow all manage site_content" ON public.site_content;
CREATE POLICY "Allow all manage site_content" ON public.site_content FOR ALL USING (true) WITH CHECK (true);

-- 3. Seed Site Content
INSERT INTO public.site_content (key, title, value) VALUES ('hero_title', 'Hero Title', 'Authentic Sri Lanka, Tailored For You') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('hero_subtitle', 'Hero Subtitle', 'Experience the vibrant culture, untamed wildlife, mist-shrouded tea mountains, and pristine tropical beaches of our island home — planned by local experts.') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('welcome_title', 'Welcome Title', 'Ayubowan! Welcome to Serendib Days.') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('welcome_body', 'Welcome Body', 'We are a passionate team of local Sri Lankan travel designers dedicated to showcasing the authentic magic of our island. Whether you seek a short day trip to ancient UNESCO temples or an immersive two-week island loop, we curate genuine, responsible journeys tailored specifically for your pace and budget.') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('contact_phone', 'Contact Phone', '+94 77 123 4567') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('contact_whatsapp', 'Contact Whatsapp', '+94771234567') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('contact_email', 'Contact Email', 'hello@serendibdays.com') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('contact_address', 'Contact Address', 'Colombo, Sri Lanka') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
INSERT INTO public.site_content (key, title, value) VALUES ('about_story', 'About Story', 'Born from a deep love for our island home, Serendib Days was created to offer a better way to experience Sri Lanka. We are not a faceless global aggregator; we are locals who know the hidden trails, the best time to spot leopards, and where to taste the most authentic village curries.') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 4. Seed Testimonials
INSERT INTO public.testimonials (id, name, country, text, rating, is_published) VALUES ('11111111-1111-1111-1111-111111111111', 'Sarah & Mark', 'United Kingdom', 'Serendib Days planned our honeymoon perfectly. The driver was so knowledgeable and the boutique hotels were fantastic! From the Sigiriya climb to the Ella train ride, every moment was effortless.', 5, TRUE) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country, text = EXCLUDED.text, rating = EXCLUDED.rating, is_published = EXCLUDED.is_published;
INSERT INTO public.testimonials (id, name, country, text, rating, is_published) VALUES ('22222222-2222-2222-2222-222222222222', 'The Johnson Family', 'Australia', 'Traveling with kids can be tough, but the local insights, thoughtful pace, and flexibility made this the best family trip we have ever had. The safari at Udawalawe was unforgettable!', 5, TRUE) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country, text = EXCLUDED.text, rating = EXCLUDED.rating, is_published = EXCLUDED.is_published;
INSERT INTO public.testimonials (id, name, country, text, rating, is_published) VALUES ('33333333-3333-3333-3333-333333333333', 'Emma Lindqvist', 'Sweden', 'I loved the balance of culture, nature, and peaceful relaxation. Having a dedicated local chauffeur guide made all the difference. Highest recommendation for authentic Sri Lanka.', 5, TRUE) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country, text = EXCLUDED.text, rating = EXCLUDED.rating, is_published = EXCLUDED.is_published;
INSERT INTO public.testimonials (id, name, country, text, rating, is_published) VALUES ('44444444-4444-4444-4444-444444444444', 'David & Clara Miller', 'United States', 'Great service, completely transparent pricing, and 24/7 care. We always felt safe, pampered, and truly welcomed like family. Serendib Days is the only way to see this paradise.', 5, TRUE) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country, text = EXCLUDED.text, rating = EXCLUDED.rating, is_published = EXCLUDED.is_published;

-- 5. Seed FAQs
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f1111111-1111-1111-1111-111111111111', 'Do I need a visa for Sri Lanka?', 'Yes, most nationalities need an ETA (Electronic Travel Authorization) which can easily be applied for online at eta.gov.lk before arrival. The standard tourist visa is valid for 30 days.', 1, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f2222222-2222-2222-2222-222222222222', 'When is the best time to visit Sri Lanka?', 'Sri Lanka is a year-round destination! Because the island experiences two separate monsoon seasons, the south, west coasts and hill country shine bright from November to April, while the eastern and northern regions are magnificent from May to September.', 2, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f3333333-3333-3333-3333-333333333333', 'Are the package prices per person?', 'Yes, prices displayed are starting prices per person based on two travelers sharing a room. For solo travelers or groups of 3 or more, we customize the pricing accordingly with special group rates.', 3, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f4444444-4444-4444-4444-444444444444', 'Is Sri Lanka safe for tourists?', 'Yes, Sri Lanka is widely recognized as one of the safest and most welcoming travel destinations in the world. Our verified local guides ensure you are safe, comfortable, and well taken care of around the clock.', 4, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f5555555-5555-5555-5555-555555555555', 'Can I customize any of these itineraries?', 'Absolutely! Every single package is 100% customizable. You can adjust the duration, swap hotels, add extra rest days, include specialized activities like surfing or cooking classes, or create a bespoke loop from scratch.', 5, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;
INSERT INTO public.faqs (id, question, answer, sort_order, is_published) VALUES ('f6666666-6666-6666-6666-666666666666', 'What are the differences between Essential, Comfort, and Signature tiers?', 'Essential provides comfortable 3-star guesthouses and clean air-conditioned sedan travel. Comfort upgrades to 4-star boutique hotels with swimming pools and an SUV vehicle. Signature provides 5-star luxury heritage resorts, premium luxury vehicles, private naturalists, and exclusive dining.', 6, TRUE) ON CONFLICT (id) DO UPDATE SET question = EXCLUDED.question, answer = EXCLUDED.answer, sort_order = EXCLUDED.sort_order, is_published = EXCLUDED.is_published;

-- 6. Seed All 25 Packages, Tiers, and Itineraries
-- Package: Sigiriya & Dambulla Day (sigiriya-dambulla-day)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('90155180-556f-4003-b876-b04e42ff7b77', 'sigiriya-dambulla-day', 'Sigiriya & Dambulla Day', 'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.', 'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.', 1, 'Sigiriya area → Sigiriya Rock → Dambulla Cave Temple → village lunch', 'Year-round; start early to beat the heat', ARRAY['Culture & Heritage', 'Adventure']::text[], 'blob:https://gemini.google.com/5c18f023-b537-44ed-8a0d-85767083e716', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya ticket (5) and Dambulla ticket (about )']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 1)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('90155180-556f-4003-b876-b04e42ff7b77', 'essential', 5, 'car and guide, entrance fees, lunch not included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('90155180-556f-4003-b876-b04e42ff7b77', 'comfort', 15, 'SUV, village lunch and cooking demo included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('90155180-556f-4003-b876-b04e42ff7b77', 'signature', 75, 'premium vehicle, private lunch at a heritage lodge, bullock-cart ride and sunset village walk', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('90155180-556f-4003-b876-b04e42ff7b77', 1, 'Rock, Caves and Village', 'Early pickup from your hotel in the Sigiriya, Dambulla or Habarana area. Climb Sigiriya Rock Fortress in the cool morning to beat the heat, admiring the mirror wall and ancient frescoes. Afterwards, visit the Dambulla Cave Temple with its five caves of Buddha statues and frescoes. Enjoy lunch in a nearby village with a short cooking demonstration. Drop-off at your hotel.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: 5-Day Sri Lanka Highlights Tour (5-day-sri-lanka-highlights)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', '5-day-sri-lanka-highlights', '5-Day Sri Lanka Highlights Tour', 'Experience the highlights of Sri Lanka on an unforgettable 5-day journey through vibrant cities, historic heritage, incredible wildlife, misty mountains, scenic train rides and the world-famous Ceylon Tea.', 'Experience the highlights of Sri Lanka on an unforgettable 5-day journey through vibrant cities, historic heritage, incredible wildlife, misty mountains, scenic train rides and the world-famous Ceylon Tea.', 5, 'Airport → Colombo → Galle → Udawalawe → Haputale → Nuwara Eliya → Kandy → Airport', 'Year-round', ARRAY['Culture & Heritage', 'Wildlife', 'Hill Country']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 1)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 'essential', 20, 'Guesthouses, budget city hotels', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 'comfort', 80, '3–4★ hotels, boutique lodges', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 'signature', 350, 'Boutique hotels, luxury resorts', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 1, 'Arrival, Colombo & Historic Galle', 'Airport pickup and Colombo city tour. Continue to Galle and visit the historic Galle Fort, a UNESCO World Heritage Site.', 'Galle')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 2, 'Galle Heritage & Udawalawe Wildlife', 'Visit the Elephant Transit Home in Udawalawe and learn about elephant conservation. Continue to the beautiful hill country of Haputale.', 'Haputale')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 3, 'Scenic Train Journey & Nuwara Eliya', 'Enjoy a memorable train journey from Haputale to Nanu Oya. Explore Nuwara Eliya town, known for its cool climate and colonial atmosphere.', 'Nuwara Eliya')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 4, 'Kandy: Nature, Culture & Tradition', 'Explore the Royal Botanic Gardens, discover a Gem Factory, visit the Temple of the Sacred Tooth Relic, and enjoy a traditional cultural dance.', 'Kandy')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('e6c53ea2-8c26-46aa-984c-fba287b1c865', 5, 'Ceylon Tea, Spices & Departure', 'Visit a traditional tea factory and a spice garden. Continue to the airport for your departure.', 'Airport')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Kandy Culture Day (kandy-culture-day)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('b79b560a-0842-4f72-b938-287ad3578a59', 'kandy-culture-day', 'Kandy Culture Day', 'Sri Lanka''s hill capital in a day: the sacred Temple of the Tooth Relic, the royal botanical gardens, the lakeside and an evening of traditional Kandyan dance.', 'Sri Lanka''s hill capital in a day: the sacred Temple of the Tooth Relic, the royal botanical gardens, the lakeside and an evening of traditional Kandyan dance.', 1, 'Kandy → Temple of the Tooth → Peradeniya Botanical Gardens → Kandy Lake → cultural show', 'Year-round; July–August for the Esala Perahera festival', ARRAY['Culture & Heritage', 'Hill Country']::text[], 'https://drive.google.com/file/d/168GKwkB-ripRD2RTG5Wj9L3cnRIJMXMq/view?usp=drive_link', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Temple of the Tooth ticket, Peradeniya Botanical Gardens ticket, cultural show ticket (about 5 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 2)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('b79b560a-0842-4f72-b938-287ad3578a59', 'essential', 5, 'car, guide and all tickets', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('b79b560a-0842-4f72-b938-287ad3578a59', 'comfort', 5, 'SUV, lunch at a local restaurant with a lake view', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('b79b560a-0842-4f72-b938-287ad3578a59', 'signature', 50, 'premium vehicle, private guide for the temple, lunch at a heritage hotel, front-row show seats', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('b79b560a-0842-4f72-b938-287ad3578a59', 1, 'Sacred Kandy', 'Morning visit to the Temple of the Tooth Relic. Drive around Kandy Lake and browse the town market. Lunch, then a walk through the Royal Botanical Gardens at Peradeniya. Evening Kandyan cultural dance performance and drop-off.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Galle Fort & Coast Day (galle-fort-coast-day)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('671fee26-d4b5-4a8a-87fc-a4732810c75d', 'galle-fort-coast-day', 'Galle Fort & Coast Day', 'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.', 'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.', 1, 'Bentota / Galle → Madu River → mask factory → turtle hatchery → Galle Fort → Unawatuna', 'December to April (calmest seas)', ARRAY['Beaches', 'Culture & Heritage']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Madu River boat ride and turtle hatchery ticket (about 5)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 3)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('671fee26-d4b5-4a8a-87fc-a4732810c75d', 'essential', 5, 'car, guide, boat ride and hatchery', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('671fee26-d4b5-4a8a-87fc-a4732810c75d', 'comfort', 5, 'SUV, seafood lunch by the beach', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('671fee26-d4b5-4a8a-87fc-a4732810c75d', 'signature', 50, 'premium vehicle, private boat, lunch at a Galle Fort boutique hotel, sunset drinks on the ramparts', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('671fee26-d4b5-4a8a-87fc-a4732810c75d', 1, 'Mangroves, Masks, Turtles and the Fort', 'Pickup in the Bentota or Galle area. Boat ride through the Madu River mangroves. Visit a traditional mask factory and museum to experience local wood carving and folklore masks. Visit a sea turtle conservation hatchery. Walk the ramparts of Galle Fort, the lighthouse and the old Dutch streets. Seafood lunch on Unawatuna beach and free time to swim.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Udawalawe Elephant Safari Day (udawalawe-elephant-safari-day)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 'udawalawe-elephant-safari-day', 'Udawalawe Elephant Safari Day', 'Udawalawe is one of the most reliable places in Asia to see wild elephants up close. Combine a morning jeep safari with the Elephant Transit Home, where orphaned calves are cared for.', 'Udawalawe is one of the most reliable places in Asia to see wild elephants up close. Combine a morning jeep safari with the Elephant Transit Home, where orphaned calves are cared for.', 1, 'Udawalawe area → Elephant Transit Home → jeep safari', 'Year-round; dry season for the best sightings', ARRAY['Wildlife']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'National park entrance fee, jeep hire and tracker (estimate, about 0 per person for two sharing)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 4)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 'essential', 5, 'shared jeep safari, lunch not included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 'comfort', 25, 'private jeep, lunch included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 'signature', 90, 'private jeep with naturalist guide, breakfast in the park and lunch at a lodge', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 1, 'Elephants Up Close', 'Early start from your hotel in the Udawalawe, Tissamaharama or Galle area. Half-day jeep safari to spot elephants, water buffalo, crocodiles and birds. Visit the Elephant Transit Home at feeding time. Lunch and return.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Cultural Triangle Escape (cultural-triangle-escape)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 'cultural-triangle-escape', 'Cultural Triangle Escape', 'The best of the ancient heartland in a short break: a sunrise climb of Sigiriya, the ruined royal city of Polonnaruwa and an evening elephant safari at Minneriya.', 'The best of the ancient heartland in a short break: a sunrise climb of Sigiriya, the ruined royal city of Polonnaruwa and an evening elephant safari at Minneriya.', 2, 'Colombo → Sigiriya → Minneriya → Polonnaruwa → Colombo', 'Year-round; June–October for the elephant gathering', ARRAY['Culture & Heritage', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya (5), Polonnaruwa (0), Minneriya safari (about 0; optional add-on for Essential)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 5)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 'essential', 75, 'guesthouse, sites included, safari as add-on (about 5)', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 'comfort', 95, '3–4★ hotel with pool, safari, dinner at the hotel', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 'signature', 80, 'boutique hotel, half board, private jeep with naturalist guide', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 1, 'Into the Ancient Heartland', 'Pickup in Colombo or at the airport and scenic drive north. Lunch on the way. Check in at Sigiriya. Evening jeep safari at Minneriya National Park to see wild elephants. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Breakfast, then explore Polonnaruwa''s ancient city (Royal Palace, Gal Vihara, Vatadage). Lunch, then return to Colombo (about 5 hours), arriving in the evening.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Tea Country Escape (Nuwara Eliya & Horton Plains) (tea-country-escape)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 'tea-country-escape', 'Tea Country Escape (Nuwara Eliya & Horton Plains)', 'Cool air, green hills and a famous cliff edge. Visit a working tea factory, stroll through "Little England" and hike to World''s End at sunrise.', 'Cool air, green hills and a famous cliff edge. Visit a working tea factory, stroll through "Little England" and hike to World''s End at sunrise.', 2, 'Colombo / Kandy → Ramboda Falls → Nuwara Eliya → Horton Plains → return', 'January to March (clearest views); mornings are best year-round', ARRAY['Hill Country', 'Adventure']::text[], 'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Tea factory tour, Horton Plains entrance (estimate, about 5)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 6)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 'essential', 45, 'budget hotel or homestay, sites included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 'comfort', 15, 'tea-country boutique hotel, dinner included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 'signature', 95, 'restored tea bungalow, half board, private tea tasting and picnic breakfast in Horton Plains', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 1, 'Into the Hills', 'Pickup in Colombo or Kandy and drive up through the tea country. Stop at Ramboda Falls and a tea factory for a tasting. Afternoon walk around Gregory Lake and the old colonial centre of Nuwara Eliya. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('742bac80-9ab1-4482-9c6f-c245c15c917e', 2, 'World''s End', 'Very early start for Horton Plains National Park. Hike the loop to World''s End and Baker''s Falls. Breakfast, then descend and return to Kandy or Colombo in the late afternoon.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: South Coast Beach Escape (south-coast-beach-escape)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 'south-coast-beach-escape', 'South Coast Beach Escape', 'A quick beach break with Galle Fort, the Madu River, a night at Mirissa and (in season) a morning of whale watching.', 'A quick beach break with Galle Fort, the Madu River, a night at Mirissa and (in season) a morning of whale watching.', 2, 'Colombo → Galle → Mirissa → Colombo', 'November to April', ARRAY['Beaches', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Turtle hatchery and river boat (about 5), whale watching boat (about 5; Comfort and Signature)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 7)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 'essential', 25, 'beach guesthouse, whale watching as add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 'comfort', 65, 'boutique beach hotel, whale watching, dinner included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 'signature', 55, 'villa with sea view, half board, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 1, 'Fort and Coast', 'Pickup in Colombo and drive south by expressway. Visit a turtle hatchery and the Madu River, then walk Galle Fort. Sunset at Mirissa and overnight by the beach.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d43f9a0f-724c-4b87-9e56-c02f373b228f', 2, 'Whales and Waves', 'Early morning whale watching boat trip from Mirissa (November–April), or a beach morning at other times. Coconut Tree Hill and Weligama, then return to Colombo by expressway.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Yala Safari Escape (yala-safari-escape)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 'yala-safari-escape', 'Yala Safari Escape', 'Two safaris, one night in the wild. Yala has one of the highest leopard densities in the world, with elephants, sloth bears and crocodiles too.', 'Two safaris, one night in the wild. Yala has one of the highest leopard densities in the world, with elephants, sloth bears and crocodiles too.', 2, 'Colombo / Galle → Tissamaharama → Yala → return', 'February to July for leopards; check park closure dates in September–October', ARRAY['Wildlife', 'Adventure']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Park entrance fees and jeep hire (about 0–85 pp per safari when two people share a jeep)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 8)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 'essential', 95, 'guesthouse, one safari included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 'comfort', 65, 'safari lodge, two safaris, dinner included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 'signature', 65, 'luxury lodge or tented camp, half board, two private jeep safaris with a naturalist guide', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 1, 'Into the Wild', 'Pickup in Colombo or Galle and drive to Tissamaharama. Check in, then head out on an afternoon jeep safari in Yala National Park. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('163778b1-6125-4ab1-bcda-ecce8816c332', 2, 'Dawn Safari', 'Pre-dawn start for a morning safari, the best time for leopards. Breakfast at the hotel and return journey.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Hill Country Highlights (hill-country-highlights)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 'hill-country-highlights', 'Hill Country Highlights', 'Temples, tea and one of the world''s great train journeys. Kandy''s sacred sights, the misty hills of Nuwara Eliya and the viewpoints of Ella.', 'Temples, tea and one of the world''s great train journeys. Kandy''s sacred sights, the misty hills of Nuwara Eliya and the viewpoints of Ella.', 3, 'Colombo → Kandy → Nuwara Eliya → Ella', 'December to March', ARRAY['Hill Country', 'Culture & Heritage']::text[], 'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Temple of the Tooth, Peradeniya, dance show, train ticket, tea factory (about 5 in total). Train tickets sell out early, so the owner should book in advance.']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 9)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 'essential', 95, 'guesthouses, second-class reserved train seats', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 'comfort', 30, '3–4★ hotels, reserved seats, dinners in Kandy and Nuwara Eliya', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 'signature', 60, 'boutique hotels, first-class or observation-car seats where available, half board, private tea tasting', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 1, 'Kandy', 'Pickup in Colombo or at the airport. Visit the Temple of the Tooth and Peradeniya Botanical Gardens. Evening Kandyan dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 2, 'Train to the Tea Country', 'Ride the scenic hill-country train from Kandy to Nanu Oya while the driver meets you with the car. Tea factory visit and tasting, then a walk around Nuwara Eliya. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 3, 'Ella', 'Drive through the hills to Ella. Walk to the Nine Arch Bridge, Little Adam''s Peak and Ravana Falls. Drop-off in Ella, or continue to the south coast or back to Colombo (about 6–7 hours; supplement applies).', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: South Coast & Galle Fort (south-coast-galle-fort)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 'south-coast-galle-fort', 'South Coast & Galle Fort', 'Golden beaches, a colonial fort, mangrove rivers and, in season, blue whales. The classic south coast, unhurried.', 'Golden beaches, a colonial fort, mangrove rivers and, in season, blue whales. The classic south coast, unhurried.', 3, 'Colombo → Bentota → Galle → Mirissa → Colombo', 'November to April', ARRAY['Beaches', 'Culture & Heritage', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Turtle hatchery and river boat (about 5), whale watching boat (about 5; Comfort and Signature)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 10)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 'essential', 85, 'guesthouses in Galle and Mirissa', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 'comfort', 85, 'boutique hotels, whale watching, dinner at Mirissa', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 'signature', 15, 'fort boutique hotel and cliff villa, half board, private whale watching boat, sunset dinner on the beach', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 1, 'Bentota to Galle', 'Pickup in Colombo and drive south. Turtle hatchery and Madu River boat ride. Afternoon in Galle Fort, ramparts and sunset. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 2, 'Mirissa', 'Morning whale watching (November–April) or a beach and surf morning. Coconut Tree Hill and Weligama. Free afternoon on the beach. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('07c78f95-bdcb-4909-b56f-36fcb883a896', 3, 'Coast to Colombo', 'Relaxed morning, optional snorkelling or a cooking class, then return by expressway.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Cultural Triangle & Kandy (cultural-triangle-and-kandy)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 'cultural-triangle-and-kandy', 'Cultural Triangle & Kandy', 'Sri Lanka''s greatest historic sites in one loop: cave temples, a rock fortress, a ruined capital and the last royal city.', 'Sri Lanka''s greatest historic sites in one loop: cave temples, a rock fortress, a ruined capital and the last royal city.', 3, 'Colombo → Dambulla → Sigiriya → Polonnaruwa → Kandy → Colombo', 'Year-round', ARRAY['Culture & Heritage']::text[], 'https://images.unsplash.com/photo-1579730591523-28957cdbd045?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya (5), Polonnaruwa (0), Dambulla (about ), Temple of the Tooth, Peradeniya, dance show (about 9 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 11)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 'essential', 75, 'guesthouses', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 'comfort', 5, '3–4★ hotels, dinners at both hotels', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 'signature', 35, 'boutique hotels, half board, private village lunch experience', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 1, 'Dambulla and Sigiriya', 'Pickup in Colombo and drive north. Visit the Dambulla Cave Temple. Late afternoon at Sigiriya''s gardens and village. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Afternoon at Polonnaruwa''s ruins. Drive to Kandy via a spice garden in Matale. Evening dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('48e6d264-45e3-47a9-882a-4444079079d7', 3, 'Sacred Kandy', 'Temple of the Tooth and Peradeniya Botanical Gardens, then return to Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Yala & Udawalawe Safari Trail (yala-udawalawe-safari-trail)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 'yala-udawalawe-safari-trail', 'Yala & Udawalawe Safari Trail', 'Two parks, two very different safaris: elephants in Udawalawe and leopards in Yala, with a stop at Galle Fort on the way home.', 'Two parks, two very different safaris: elephants in Udawalawe and leopards in Yala, with a stop at Galle Fort on the way home.', 3, 'Colombo → Udawalawe → Yala → Galle → Colombo', 'February to July for leopards; check Yala closure dates (September–October)', ARRAY['Wildlife', 'Adventure']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Udawalawe safari (estimate, about 0 pp), Yala safari (about 2 pp when two share a jeep)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 12)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 'essential', 25, 'safari guesthouses, shared or standard jeeps', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 'comfort', 60, 'safari lodges, private jeeps, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 'signature', 20, 'luxury lodges or tented camp, half board, private jeeps with naturalist guide', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 1, 'Elephants', 'Pickup in Colombo and drive to Udawalawe. Lunch, then afternoon safari and the Elephant Transit Home. Overnight in Udawalawe.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 2, 'Leopard Country', 'Drive to Yala. Safari in the late afternoon. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 3, 'Dawn and Galle', 'Early morning Yala safari. Breakfast, then drive to Galle Fort for lunch and a walk, and return to Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Glimpse of Sri Lanka (glimpse-of-sri-lanka)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 'glimpse-of-sri-lanka', 'Glimpse of Sri Lanka', 'A first taste of the island in four days: elephants, a rock fortress, spice gardens, the Temple of the Tooth and a night in Colombo. Ideal as a short stopover.', 'A first taste of the island in four days: elephants, a rock fortress, spice gardens, the Temple of the Tooth and a night in Colombo. Ideal as a short stopover.', 4, 'Airport → Habarana / Sigiriya → Kandy → Colombo', 'Year-round', ARRAY['Culture & Heritage', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Minneriya safari (about 0), Sigiriya (5), Temple of the Tooth, Peradeniya, dance show (about 00 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 13)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 'essential', 35, 'guesthouses and a budget city hotel', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 'comfort', 25, '3–4★ hotels, dinners in Habarana and Kandy', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 'signature', 0, 'boutique hotels, half board, private jeep with naturalist guide', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening jeep safari at Minneriya National Park. Overnight in Habarana or Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 2, 'Lion Rock and Kandy', 'Sunrise climb of Sigiriya Rock. Visit a spice garden in Matale. Arrive in Kandy and enjoy an evening dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 3, 'Sacred Kandy and Colombo', 'Temple of the Tooth and Peradeniya Botanical Gardens. Drive to Colombo for a city tour (Fort, Pettah, Galle Face). Overnight in Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 4, 'Departure', 'Breakfast and transfer to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Hill Country & Tea Trails (hill-country-tea-trails)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 'hill-country-tea-trails', 'Hill Country & Tea Trails', 'Ride the famous hill-country train, taste fresh Ceylon tea, hike World''s End and cross the Nine Arch Bridge.', 'Ride the famous hill-country train, taste fresh Ceylon tea, hike World''s End and cross the Nine Arch Bridge.', 4, 'Colombo → Kandy → Nuwara Eliya → Ella → Colombo', 'December to March', ARRAY['Hill Country', 'Adventure']::text[], 'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains (about 0 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 14)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 'essential', 10, 'guesthouses and homestays', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 'comfort', 5, 'boutique hotels, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 'signature', 85, 'tea bungalow and luxury villa, half board, first-class train seats where available, private tea tasting', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 1, 'Kandy', 'Pickup and drive to Kandy. Temple of the Tooth and Peradeniya Botanical Gardens. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 2, 'Train to Tea Country', 'Scenic train from Kandy to Nanu Oya. Tea factory visit. Explore Nuwara Eliya. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 3, 'World''s End and Ella', 'Sunrise hike at Horton Plains. Drive to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('fab1db1c-1d61-4845-90f9-e522c4298481', 4, 'Ella to Colombo', 'Morning at the Nine Arch Bridge and Ravana Falls, then the long drive back (about 6–7 hours).', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: South Coast Beaches & Yala (south-coast-beaches-yala)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 'south-coast-beaches-yala', 'South Coast Beaches & Yala', 'Sand, sea and safari. Explore Galle Fort, whale watch from Mirissa and finish with a jeep safari in Yala.', 'Sand, sea and safari. Explore Galle Fort, whale watch from Mirissa and finish with a jeep safari in Yala.', 4, 'Colombo → Galle → Mirissa → Yala → Colombo', 'November to April', ARRAY['Beaches', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Hatchery and river boat (about 5), whale watching (about 5; Comfort and Signature), Yala safari (about 2)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 15)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 'essential', 45, 'guesthouses, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 'comfort', 0, 'boutique hotels, safari lodge, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 'signature', 80, 'luxury villas and tented camp, half board, private whale watching boat, private safari', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 1, 'Galle Fort', 'Pickup in Colombo, coastal stops at a turtle hatchery and the Madu River, then Galle Fort. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 2, 'Whales and Beaches', 'Morning whale watching from Mirissa (November–April), beach time and Weligama. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 3, 'Yala', 'Drive to Yala and go on an afternoon safari. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 4, 'Dawn and Home', 'Early morning safari, breakfast and return to Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Ancient Cities Deep Dive (ancient-cities-deep-dive)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 'ancient-cities-deep-dive', 'Ancient Cities Deep Dive', 'For history lovers: Sri Lanka''s first capital Anuradhapura, the sacred hill of Mihintale, Sigiriya, Polonnaruwa and the cave temples of Dambulla.', 'For history lovers: Sri Lanka''s first capital Anuradhapura, the sacred hill of Mihintale, Sigiriya, Polonnaruwa and the cave temples of Dambulla.', 4, 'Colombo → Anuradhapura → Sigiriya → Polonnaruwa → Dambulla → Colombo', 'Year-round', ARRAY['Culture & Heritage', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Anuradhapura (0), Sigiriya (5), Polonnaruwa (0), Dambulla (about ), Minneriya safari (about 0)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 16)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 'essential', 85, 'guesthouses', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 'comfort', 75, 'heritage hotels, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 'signature', 45, 'boutique heritage resorts, half board, private archaeology-specialist guide for one day', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 1, 'Anuradhapura', 'Pickup in Colombo and drive to Anuradhapura. Visit the Sri Maha Bodhi tree, great stupas and ancient ponds. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 2, 'Mihintale and Sigiriya', 'Sunrise at Mihintale, the cradle of Buddhism in Sri Lanka. Drive to Sigiriya and take an afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 3, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Afternoon exploring Polonnaruwa. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('68cc07d5-3c1c-4655-9412-4672b1df745f', 4, 'Dambulla and Home', 'Visit the Dambulla Cave Temple, then drive back to Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Culture & Hill Country (5 Days) (culture-hill-country-5-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 'culture-hill-country-5-days', 'Culture & Hill Country (5 Days)', 'Ancient rock fortress, sacred Kandy and the tea hills, connected by a scenic train ride. A well-paced first trip.', 'Ancient rock fortress, sacred Kandy and the tea hills, connected by a scenic train ride. A well-paced first trip.', 5, 'Airport → Sigiriya → Kandy → Nuwara Eliya → Colombo', 'December to March', ARRAY['Culture & Heritage', 'Hill Country', 'Wildlife']::text[], 'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Minneriya safari, Sigiriya, Tooth temple, Peradeniya, dance show, train ticket (about 17 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 17)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 'essential', 15, 'guesthouses, budget city hotel', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 'comfort', 65, '3–4★ hotels, four dinners', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 'signature', 320, 'boutique hotels, half board, private jeep, first-class train seats where available', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 2, 'Lion Rock to Kandy', 'Sunrise climb of Sigiriya Rock, spice garden stop and arrival in Kandy. Evening dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 3, 'Kandy to the Hills', 'Temple of the Tooth and Peradeniya Gardens, then scenic train from Kandy to Nanu Oya. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 4, 'Tea and Return', 'Tea factory visit and colonial town walk, then drive to Colombo via the tea country. Overnight in Colombo.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('6548eb1e-1350-4af0-99e2-10744750fdea', 5, 'Departure', 'Breakfast and transfer to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Hills, Tea & Beach (6 Days) (hills-tea-beach-6-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 'hills-tea-beach-6-days', 'Hills, Tea & Beach (6 Days)', 'Mountains first, then the sea. Trains, tea, waterfalls and viewpoints, followed by two nights on the south coast.', 'Mountains first, then the sea. Trains, tea, waterfalls and viewpoints, followed by two nights on the south coast.', 6, 'Colombo → Kandy → Nuwara Eliya → Ella → Mirissa → Colombo', 'December to April', ARRAY['Hill Country', 'Beaches', 'Adventure']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains (about 0–135 in total), whale watching for Comfort and Signature']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 18)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 'essential', 30, 'guesthouses, whale watching as add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 'comfort', 5, 'boutique hotels, whale watching, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 'signature', 615, 'tea bungalow, luxury villas, half board, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 1, 'Kandy', 'Pickup and drive to Kandy. Temple of the Tooth and lake. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 2, 'Train to Nuwara Eliya', 'Peradeniya Gardens, then train to Nanu Oya and tea factory visit. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 3, 'World''s End and Ella', 'Sunrise at Horton Plains, then drive to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 4, 'Ella to the Coast', 'Nine Arch Bridge, then a scenic drive down to the south coast. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 5, 'Whales and Beach', 'Whale watching (November–April) and free beach time. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('85393f3f-cc1f-43ca-a119-323370659b72', 6, 'Departure', 'Galle Fort stop on the way to Colombo or the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Sri Lanka Essentials (7 Days) (sri-lanka-essentials-7-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 'sri-lanka-essentials-7-days', 'Sri Lanka Essentials (7 Days)', 'Our signature week: ancient cities, sacred temples, tea hills, a leopard safari and a night in Galle Fort. Everything a first-time visitor wants to see.', 'Our signature week: ancient cities, sacred temples, tea hills, a leopard safari and a night in Galle Fort. Everything a first-time visitor wants to see.', 7, 'Airport → Sigiriya → Kandy → Nuwara Eliya → Yala → Galle → Airport', 'December to March', ARRAY['Culture & Heritage', 'Wildlife', 'Hill Country']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya, Polonnaruwa, Minneriya safari, Tooth temple, Peradeniya, dance show, train ticket, Yala safari (about 34 in total)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 19)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 'essential', 75, 'guesthouses and simple hotels', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 'comfort', 40, '3–4★ hotels, safari lodge, six dinners', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 'signature', 0, 'boutique hotels and luxury lodge, half board, private jeeps with naturalist guides, first-class train seats where available', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock, then explore Polonnaruwa. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 3, 'Kandy', 'Dambulla Cave Temple or spice garden on the way. Temple of the Tooth, Peradeniya Gardens and the evening dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 4, 'Train to the Hills', 'Scenic train from Kandy to Nanu Oya, tea factory visit and a colonial walk in Nuwara Eliya. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 5, 'Down to Yala', 'Descend from the hills to Yala. Evening safari for leopards and elephants. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 6, 'Galle Fort', 'Drive to the south coast. Explore Galle Fort''s ramparts and streets. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 7, 'Departure', 'Breakfast and transfer to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Wildlife & Beaches (7 Days) (wildlife-beaches-7-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 'wildlife-beaches-7-days', 'Wildlife & Beaches (7 Days)', 'Elephants and leopards, then whales and beaches. A week on the wild south of the island.', 'Elephants and leopards, then whales and beaches. A week on the wild south of the island.', 7, 'Colombo → Udawalawe → Yala → Mirissa → Galle → Colombo', 'November to April', ARRAY['Wildlife', 'Beaches']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Udawalawe and Yala safaris, Elephant Transit Home, Galle Fort (about 50–300 depending on tier), whale watching for Comfort and Signature']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 20)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 'essential', 80, 'guesthouses, one Yala safari, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 'comfort', 120, 'safari lodges and boutique hotels, two Yala safaris, whale watching, dinners included', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 'signature', 130, 'luxury lodges and villas, half board, private jeeps with naturalist guides, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 1, 'Elephants', 'Pickup and drive to Udawalawe. Evening safari. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 2, 'Transit Home and Yala', 'Visit the Elephant Transit Home, then drive to Yala. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 3, 'Leopard Day', 'Dawn safari in Yala, rest at the lodge and optional second safari (Comfort and Signature). Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 4, 'To the Coast', 'Drive to Mirissa. Beach afternoon and sunset. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 5, 'Whales', 'Morning whale watching (November–April), beach or surf lesson in the afternoon. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 6, 'Galle Fort', 'Coastal drive to Galle. Explore the Fort. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('14ff027f-df19-4d0e-8af2-f064eafbe220', 7, 'Departure', 'Transfer to Colombo or the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Romance in Paradise (8 Days) (romance-in-paradise-8-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 'romance-in-paradise-8-days', 'Romance in Paradise (8 Days)', 'A honeymoon or anniversary trip: ancient wonders, misty tea hills, a scenic train and a beach finale. Romantic touches are built into the Comfort and Signature tiers.', 'A honeymoon or anniversary trip: ancient wonders, misty tea hills, a scenic train and a beach finale. Romantic touches are built into the Comfort and Signature tiers.', 8, 'Airport → Sigiriya → Kandy → Nuwara Eliya → Ella → Mirissa → Airport', 'December to April', ARRAY['Beaches', 'Hill Country', 'Culture & Heritage']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya, Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains, Galle Fort (about 17 for Essential, 72 with whale watching for Comfort and Signature)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 21)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 'essential', 95, 'guesthouses, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 'comfort', 90, 'boutique hotels, room decoration on arrival, one candlelit dinner, whale watching', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 'signature', 305, 'luxury villas, half board, private sunset dinner on the beach, couple''s spa session, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 1, 'Arrival', 'Airport welcome, drive north and settle in at Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 2, 'Lion Rock', 'Sunrise climb of Sigiriya Rock, afternoon at leisure. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 3, 'Kandy', 'Temple of the Tooth, botanical gardens and evening dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 4, 'Train to Nuwara Eliya', 'Scenic train, tea factory and colonial walk. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 5, 'World''s End and Ella', 'Sunrise at Horton Plains, then on to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 6, 'To the Coast', 'Nine Arch Bridge, then a scenic drive to Mirissa. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 7, 'Whales and Beach', 'Whale watching (November–April) and a beach afternoon. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('4c79a484-75ae-4265-bd03-c7e338ef17f6', 8, 'Departure', 'Galle Fort stop on the way to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Wildlife Grand Safari (9 Days) (wildlife-grand-safari-9-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 'wildlife-grand-safari-9-days', 'Wildlife Grand Safari (9 Days)', 'Five national parks in nine days: leopards and sloth bears in Wilpattu, elephants at Minneriya, Horton Plains, Udawalawe and Yala, with whale watching to finish.', 'Five national parks in nine days: leopards and sloth bears in Wilpattu, elephants at Minneriya, Horton Plains, Udawalawe and Yala, with whale watching to finish.', 9, 'Airport → Wilpattu → Sigiriya → Nuwara Eliya → Udawalawe → Yala → Mirissa → Galle → Airport', 'February to July (check Yala closure dates in September–October)', ARRAY['Wildlife', 'Adventure', 'Hill Country']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Wilpattu, Minneriya, Udawalawe and Yala safaris, Sigiriya, Horton Plains, Galle Fort (about 52 for Essential, 07 with whale watching for Comfort and Signature). Wilpattu and Udawalawe costs are estimates.']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 22)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 'essential', 40, 'guesthouses and simple lodges, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 'comfort', 490, 'safari lodges and boutique hotels, dinners included, whale watching', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 'signature', 810, 'luxury tented camps and lodges, half board, private jeeps with naturalist guides, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 1, 'To the Northwest', 'Airport welcome and drive to Wilpattu. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 2, 'Wilpattu', 'Morning jeep safari, then transfer to Sigiriya. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 3, 'Minneriya', 'Sunrise at Sigiriya Rock, then an afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 4, 'To the Hills', 'Drive to Nuwara Eliya via Kandy. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 5, 'Horton Plains and Udawalawe', 'Sunrise hike at World''s End, then descend to Udawalawe for an evening safari. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 6, 'Elephants to Leopards', 'Transit Home visit, then drive to Yala for an afternoon safari. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 7, 'Dawn in Yala', 'Early safari, then drive to Mirissa. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 8, 'Whales and Galle', 'Whale watching (November–April), then Galle Fort. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('682b42bd-b050-4957-a46b-88b72485a3a2', 9, 'Departure', 'Transfer to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Grand Island Loop (10 Days) (grand-island-loop-10-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 'grand-island-loop-10-days', 'Grand Island Loop (10 Days)', 'The full island in ten days: heritage cities, tea hills, the Ella train, a leopard safari and the southern beaches. Our most complete round trip.', 'The full island in ten days: heritage cities, tea hills, the Ella train, a leopard safari and the southern beaches. Our most complete round trip.', 10, 'Airport → Sigiriya → Kandy → Nuwara Eliya → Ella → Yala → Mirissa → Galle → Colombo', 'December to March', ARRAY['Culture & Heritage', 'Wildlife', 'Hill Country', 'Beaches']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Sigiriya, Polonnaruwa, Minneriya, Dambulla, Tooth temple, Peradeniya, train ticket, Horton Plains, tea factory, Yala safari, Galle Fort (about 76 for Essential, 31 with whale watching for Comfort and Signature)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, TRUE, TRUE, 23)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 'essential', 5, 'guesthouses and homestays, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 'comfort', 515, '3–4★ hotels and lodges, dinners included, whale watching', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 'signature', 990, 'boutique hotels and luxury lodges, half board, private jeeps, first-class train seats where available, private whale watching boat', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 1, 'Arrival', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock, afternoon at Polonnaruwa. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 3, 'Dambulla and Kandy', 'Dambulla Cave Temple, Matale spice garden, then Kandy and the dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 4, 'Sacred Kandy and the Train', 'Temple of the Tooth and Peradeniya Gardens, then the scenic train to Nanu Oya. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 5, 'Tea and World''s End', 'Horton Plains at sunrise, then a tea factory visit and a colonial walk. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 6, 'Ella', 'Scenic route to Ella. Nine Arch Bridge, Little Adam''s Peak, Ravana Falls. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 7, 'Yala', 'Drive to Yala for an afternoon safari. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 8, 'Dawn Safari and Mirissa', 'Early safari, then drive to Mirissa. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 9, 'Whales and Galle', 'Whale watching (November–April), then Galle Fort. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('d92adba4-eedf-4bc6-8037-a29b88309800', 10, 'Departure', 'Transfer to Colombo or the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;

-- Package: Complete Sri Lanka (14 Days) (complete-sri-lanka-14-days)
INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, gallery, inclusions, exclusions, notes, is_featured, is_published, sort_order)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 'complete-sri-lanka-14-days', 'Complete Sri Lanka (14 Days)', 'Two weeks at a relaxed pace with two-night stays at the key stops. Ancient capitals, tea country, two safaris and time to unwind on the south coast.', 'Two weeks at a relaxed pace with two-night stays at the key stops. Ancient capitals, tea country, two safaris and time to unwind on the south coast.', 14, 'Airport → Anuradhapura → Sigiriya → Kandy → Nuwara Eliya → Ella → Udawalawe / Yala → Mirissa → Galle → Airport', 'December to March', ARRAY['Culture & Heritage', 'Wildlife', 'Hill Country', 'Beaches', 'Adventure']::text[], 'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80', ARRAY[]::text[], ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary', 'Fuel, highway tolls, parking, driver meals and accommodation', 'Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans', 'Accommodation as per the chosen tier, on twin-share basis with breakfast', 'Entrance fees for the main sites listed under ''Extra inclusions'' for each plan', 'Government taxes and service charges at hotels', 'Bottled water in the vehicle', '24-hour WhatsApp support from the Serendib Days team', 'Anuradhapura, Sigiriya, Polonnaruwa, Minneriya, Dambulla, Tooth temple, Peradeniya, train ticket, Horton Plains, tea factory, Udawalawe, Yala, Galle (about 66 for Essential, 21 with whale watching for Comfort and Signature)']::text[], ARRAY['International flights and travel insurance', 'Meals not mentioned, drinks and personal expenses', 'Entrance fees and activities not listed', 'Camera or video permit fees at some sites', 'Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)', 'Peak-season hotel supplements (Dec–Apr and Jul–Aug)', 'Single room supplement']::text[], NULL, FALSE, TRUE, 24)
ON CONFLICT (slug) DO UPDATE SET title = EXCLUDED.title, short_description = EXCLUDED.short_description, description = EXCLUDED.description, duration_days = EXCLUDED.duration_days, route = EXCLUDED.route, best_time = EXCLUDED.best_time, interests = EXCLUDED.interests, cover_image = EXCLUDED.cover_image, gallery = EXCLUDED.gallery, inclusions = EXCLUDED.inclusions, exclusions = EXCLUDED.exclusions, notes = EXCLUDED.notes, is_featured = EXCLUDED.is_featured, is_published = EXCLUDED.is_published, sort_order = EXCLUDED.sort_order;

INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 'essential', 255, 'guesthouses and homestays, whale watching as an add-on', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 'comfort', 100, 'boutique hotels and safari lodges, dinners included, whale watching', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 'signature', 140, 'luxury hotels and villas, half board, private jeeps with naturalist guides, first-class train seats where available, private whale watching boat, one cooking class or spa session', 'See description', 'None')
ON CONFLICT (package_id, tier) DO UPDATE SET price_usd = EXCLUDED.price_usd, stay_details = EXCLUDED.stay_details, transport_details = EXCLUDED.transport_details, extras = EXCLUDED.extras;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 1, 'Arrival', 'Airport welcome and drive to Anuradhapura. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 2, 'Sacred City', 'Anuradhapura''s stupas and Bodhi tree, and Mihintale at sunset. Drive to Sigiriya. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 3, 'Lion Rock', 'Sunrise climb of Sigiriya Rock and afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 4, 'Polonnaruwa and Kandy', 'Explore Polonnaruwa, then drive to Kandy via Dambulla. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 5, 'Kandy at Leisure', 'Temple of the Tooth, Peradeniya Gardens, dance show. Overnight in Kandy.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 6, 'Train to Tea Country', 'Scenic train to Nanu Oya and tea factory visit. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 7, 'World''s End', 'Sunrise hike at Horton Plains, afternoon at leisure. Overnight in Nuwara Eliya.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 8, 'Ella', 'Scenic drive to Ella. Little Adam''s Peak. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 9, 'Ella at Leisure', 'Nine Arch Bridge, Ravana Falls, optional cooking class. Overnight in Ella.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 10, 'Udawalawe and Yala', 'Udawalawe safari on the way, then on to Yala. Overnight near the park.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 11, 'Dawn Safari and Mirissa', 'Early safari in Yala, then the drive to Mirissa. Overnight there.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 12, 'Whales and Beach', 'Whale watching (November–April) and free time. Overnight in Mirissa.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 13, 'Galle', 'Galle Fort, turtle hatchery and Madu River. Overnight in Galle.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location)
VALUES ('7722a939-ac20-42d9-b3b4-1524ab7a9770', 14, 'Departure', 'Transfer to the airport.', 'Check route')
ON CONFLICT (package_id, day_number) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, overnight_location = EXCLUDED.overnight_location;
