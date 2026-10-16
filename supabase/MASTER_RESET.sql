-- ==========================================
-- MASTER RESET SCRIPT
-- ==========================================
-- This script will completely wipe the existing tables and recreate them from scratch.
-- It will then seed the 24 actual packages.

DROP TABLE IF EXISTS public.testimonials CASCADE;
DROP TABLE IF EXISTS public.faqs CASCADE;
DROP TABLE IF EXISTS public.hotel_options CASCADE;
DROP TABLE IF EXISTS public.itinerary_days CASCADE;
DROP TABLE IF EXISTS public.package_tiers CASCADE;
DROP TABLE IF EXISTS public.enquiries CASCADE;
DROP TABLE IF EXISTS public.packages CASCADE;

-- ==========================================
-- 1. CREATE TABLES & POLICIES
-- ==========================================
-- supabase/setup.sql

-- 1. Create tables
CREATE TABLE public.packages (
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
    is_published boolean DEFAULT false,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.package_tiers (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    package_id uuid REFERENCES public.packages(id) ON DELETE CASCADE,
    tier text NOT NULL CHECK (tier IN ('essential', 'comfort', 'signature')),
    price_usd numeric NOT NULL,
    stay_details text NOT NULL,
    transport_details text NOT NULL,
    extras text,
    UNIQUE(package_id, tier)
);

CREATE TABLE public.itinerary_days (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    package_id uuid REFERENCES public.packages(id) ON DELETE CASCADE,
    day_number integer NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    overnight_location text NOT NULL,
    UNIQUE(package_id, day_number)
);

CREATE TABLE public.testimonials (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    country text NOT NULL,
    text text NOT NULL,
    rating integer CHECK (rating >= 1 AND rating <= 5),
    is_published boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.faqs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    question text NOT NULL,
    answer text NOT NULL,
    sort_order integer DEFAULT 0,
    is_published boolean DEFAULT false
);

CREATE TABLE public.enquiries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    package_id uuid REFERENCES public.packages(id) ON DELETE SET NULL,
    travel_dates text NOT NULL,
    adults integer NOT NULL,
    children integer NOT NULL,
    budget_tier text,
    message text,
    status text DEFAULT 'new',
    created_at timestamp with time zone DEFAULT now()
);

-- 2. Row Level Security (RLS)
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enquiries ENABLE ROW LEVEL SECURITY;

-- 3. Policies
CREATE POLICY "Allow public read access to published packages" ON public.packages
    FOR SELECT USING (is_published = true);

CREATE POLICY "Allow public read access to package_tiers of published packages" ON public.package_tiers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.packages
            WHERE packages.id = package_tiers.package_id
            AND packages.is_published = true
        )
    );

CREATE POLICY "Allow public read access to itinerary_days of published packages" ON public.itinerary_days
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.packages
            WHERE packages.id = itinerary_days.package_id
            AND packages.is_published = true
        )
    );

CREATE POLICY "Allow public read access to published testimonials" ON public.testimonials
    FOR SELECT USING (is_published = true);

CREATE POLICY "Allow public read access to published faqs" ON public.faqs
    FOR SELECT USING (is_published = true);

CREATE POLICY "Allow anon insert to enquiries" ON public.enquiries
    FOR INSERT WITH CHECK (true);



-- ==========================================
-- 2. CREATE HOTEL OPTIONS & SEED 24 PACKAGES
-- ==========================================
-- 1. Create hotel_options table

CREATE TABLE IF NOT EXISTS public.hotel_options (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    stop text NOT NULL,
    tier text NOT NULL,
    hotel_name text NOT NULL,
    description text,
    price_difference_pp_per_night numeric DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.hotel_options ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to hotel_options" ON public.hotel_options;
CREATE POLICY "Allow public read access to hotel_options" ON public.hotel_options
    FOR SELECT USING (true);
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Sigiriya / Dambulla / Habarana', 'essential', 'Family guesthouse or homestay');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Sigiriya / Dambulla / Habarana', 'comfort', '3–4★ hotel or boutique lodge with pool');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Sigiriya / Dambulla / Habarana', 'signature', 'Jetwing Lake (Dambulla) or Heritance Kandalama');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Anuradhapura', 'essential', 'Budget guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Anuradhapura', 'comfort', '3★ heritage hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Anuradhapura', 'signature', 'Boutique heritage resort');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Wilpattu', 'essential', 'Safari guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Wilpattu', 'comfort', 'Safari lodge');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Wilpattu', 'signature', 'Luxury tented camp');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Kandy', 'essential', 'Guesthouse with a view');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Kandy', 'comfort', '3–4★ city hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Kandy', 'signature', 'Jetwing Kandy Gallery');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Nuwara Eliya', 'essential', 'Budget hotel or homestay');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Nuwara Eliya', 'comfort', 'Tea-country boutique hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Nuwara Eliya', 'signature', 'Jetwing St Andrew''s or a restored tea bungalow');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Ella', 'essential', 'Homestay');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Ella', 'comfort', 'Boutique hotel with valley view');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Ella', 'signature', 'Luxury villa or resort');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Udawalawe', 'essential', 'Safari guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Udawalawe', 'comfort', 'Safari lodge');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Udawalawe', 'signature', 'Luxury lodge');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Yala / Tissamaharama', 'essential', 'Safari guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Yala / Tissamaharama', 'comfort', 'Safari lodge or 3–4★ hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Yala / Tissamaharama', 'signature', 'Jetwing Yala or a luxury tented camp');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Mirissa', 'essential', 'Beach guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Mirissa', 'comfort', 'Boutique beach hotel or villa');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Mirissa', 'signature', 'Luxury cliff or beach villa');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Galle', 'essential', 'Fort or town guesthouse');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Galle', 'comfort', 'Boutique fort hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Galle', 'signature', 'Jetwing Lighthouse or Amangalla');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Colombo / Negombo', 'essential', 'Budget city hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Colombo / Negombo', 'comfort', '4★ hotel');
INSERT INTO public.hotel_options (stop, tier, hotel_name) VALUES ('Colombo / Negombo', 'signature', '5★ hotel');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '90155180-556f-4003-b876-b04e42ff7b77',
        'sigiriya-dambulla-day',
        'Sigiriya & Dambulla Day',
        'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.',
        'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.',
        1,
        'Sigiriya area → Sigiriya Rock → Dambulla Cave Temple → village lunch',
        'Year-round; start early to beat the heat',
        ARRAY['Culture & Heritage','Adventure'],
        'https://images.unsplash.com/photo-1544253139-65313a48e426?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        1,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya ticket (5) and Dambulla ticket (about )'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 5, 'car and guide, entrance fees, lunch not included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 15, 'SUV, village lunch and cooking demo included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 75, 'premium vehicle, private lunch at a heritage lodge, bullock-cart ride and sunset village walk', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('90155180-556f-4003-b876-b04e42ff7b77', 1, 'Rock, Caves and Village', 'Early pickup from your hotel in the Sigiriya, Dambulla or Habarana area. Climb Sigiriya Rock Fortress in the cool morning to beat the heat, admiring the mirror wall and ancient frescoes. Afterwards, visit the Dambulla Cave Temple with its five caves of Buddha statues and frescoes. Enjoy lunch in a nearby village with a short cooking demonstration. Drop-off at your hotel.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'b79b560a-0842-4f72-b938-287ad3578a59',
        'kandy-culture-day',
        'Kandy Culture Day',
        'Sri Lanka''s hill capital in a day: the sacred Temple of the Tooth Relic, the royal botanical gardens, the lakeside and an evening of traditional Kandyan dance.',
        'Sri Lanka''s hill capital in a day: the sacred Temple of the Tooth Relic, the royal botanical gardens, the lakeside and an evening of traditional Kandyan dance.',
        1,
        'Kandy → Temple of the Tooth → Peradeniya Botanical Gardens → Kandy Lake → cultural show',
        'Year-round; July–August for the Esala Perahera festival',
        ARRAY['Culture & Heritage','Hill Country'],
        'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        2,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Temple of the Tooth ticket, Peradeniya Botanical Gardens ticket, cultural show ticket (about 5 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 5, 'car, guide and all tickets', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 5, 'SUV, lunch at a local restaurant with a lake view', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 50, 'premium vehicle, private guide for the temple, lunch at a heritage hotel, front-row show seats', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('b79b560a-0842-4f72-b938-287ad3578a59', 1, 'Sacred Kandy', 'Morning visit to the Temple of the Tooth Relic. Drive around Kandy Lake and browse the town market. Lunch, then a walk through the Royal Botanical Gardens at Peradeniya. Evening Kandyan cultural dance performance and drop-off.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '671fee26-d4b5-4a8a-87fc-a4732810c75d',
        'galle-fort-coast-day',
        'Galle Fort & Coast Day',
        'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.',
        'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.',
        1,
        'Bentota / Galle → Madu River → mask factory → turtle hatchery → Galle Fort → Unawatuna',
        'December to April (calmest seas)',
        ARRAY['Beaches','Culture & Heritage'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        3,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Madu River boat ride and turtle hatchery ticket (about 5)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 5, 'car, guide, boat ride and hatchery', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 5, 'SUV, seafood lunch by the beach', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 50, 'premium vehicle, private boat, lunch at a Galle Fort boutique hotel, sunset drinks on the ramparts', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('671fee26-d4b5-4a8a-87fc-a4732810c75d', 1, 'Mangroves, Masks, Turtles and the Fort', 'Pickup in the Bentota or Galle area. Boat ride through the Madu River mangroves. Visit a traditional mask factory and museum to experience local wood carving and folklore masks. Visit a sea turtle conservation hatchery. Walk the ramparts of Galle Fort, the lighthouse and the old Dutch streets. Seafood lunch on Unawatuna beach and free time to swim.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '1f4f7bc9-9a1f-42db-a8af-217d06ade5ac',
        'udawalawe-elephant-safari-day',
        'Udawalawe Elephant Safari Day',
        'Udawalawe is one of the most reliable places in Asia to see wild elephants up close. Combine a morning jeep safari with the Elephant Transit Home, where orphaned calves are cared for.',
        'Udawalawe is one of the most reliable places in Asia to see wild elephants up close. Combine a morning jeep safari with the Elephant Transit Home, where orphaned calves are cared for.',
        1,
        'Udawalawe area → Elephant Transit Home → jeep safari',
        'Year-round; dry season for the best sightings',
        ARRAY['Wildlife'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        4,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','National park entrance fee, jeep hire and tracker (estimate, about 0 per person for two sharing)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 5, 'shared jeep safari, lunch not included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 25, 'private jeep, lunch included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 90, 'private jeep with naturalist guide, breakfast in the park and lunch at a lodge', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('1f4f7bc9-9a1f-42db-a8af-217d06ade5ac', 1, 'Elephants Up Close', 'Early start from your hotel in the Udawalawe, Tissamaharama or Galle area. Half-day jeep safari to spot elephants, water buffalo, crocodiles and birds. Visit the Elephant Transit Home at feeding time. Lunch and return.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '0ecb8994-4914-4158-be5a-2fc680ab4dfa',
        'cultural-triangle-escape',
        'Cultural Triangle Escape',
        'The best of the ancient heartland in a short break: a sunrise climb of Sigiriya, the ruined royal city of Polonnaruwa and an evening elephant safari at Minneriya.',
        'The best of the ancient heartland in a short break: a sunrise climb of Sigiriya, the ruined royal city of Polonnaruwa and an evening elephant safari at Minneriya.',
        2,
        'Colombo → Sigiriya → Minneriya → Polonnaruwa → Colombo',
        'Year-round; June–October for the elephant gathering',
        ARRAY['Culture & Heritage','Wildlife'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        5,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya (5), Polonnaruwa (0), Minneriya safari (about 0; optional add-on for Essential)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 75, 'guesthouse, sites included, safari as add-on (about 5)', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 95, '3–4★ hotel with pool, safari, dinner at the hotel', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 80, 'boutique hotel, half board, private jeep with naturalist guide', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 1, 'Into the Ancient Heartland', 'Pickup in Colombo or at the airport and scenic drive north. Lunch on the way. Check in at Sigiriya. Evening jeep safari at Minneriya National Park to see wild elephants. Overnight in Sigiriya.', 'Check route'),
('0ecb8994-4914-4158-be5a-2fc680ab4dfa', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Breakfast, then explore Polonnaruwa''s ancient city (Royal Palace, Gal Vihara, Vatadage). Lunch, then return to Colombo (about 5 hours), arriving in the evening.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '742bac80-9ab1-4482-9c6f-c245c15c917e',
        'tea-country-escape',
        'Tea Country Escape (Nuwara Eliya & Horton Plains)',
        'Cool air, green hills and a famous cliff edge. Visit a working tea factory, stroll through "Little England" and hike to World''s End at sunrise.',
        'Cool air, green hills and a famous cliff edge. Visit a working tea factory, stroll through "Little England" and hike to World''s End at sunrise.',
        2,
        'Colombo / Kandy → Ramboda Falls → Nuwara Eliya → Horton Plains → return',
        'January to March (clearest views); mornings are best year-round',
        ARRAY['Hill Country','Adventure'],
        'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        6,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Tea factory tour, Horton Plains entrance (estimate, about 5)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 45, 'budget hotel or homestay, sites included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 15, 'tea-country boutique hotel, dinner included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 95, 'restored tea bungalow, half board, private tea tasting and picnic breakfast in Horton Plains', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('742bac80-9ab1-4482-9c6f-c245c15c917e', 1, 'Into the Hills', 'Pickup in Colombo or Kandy and drive up through the tea country. Stop at Ramboda Falls and a tea factory for a tasting. Afternoon walk around Gregory Lake and the old colonial centre of Nuwara Eliya. Overnight in Nuwara Eliya.', 'Check route'),
('742bac80-9ab1-4482-9c6f-c245c15c917e', 2, 'World''s End', 'Very early start for Horton Plains National Park. Hike the loop to World''s End and Baker''s Falls. Breakfast, then descend and return to Kandy or Colombo in the late afternoon.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'd43f9a0f-724c-4b87-9e56-c02f373b228f',
        'south-coast-beach-escape',
        'South Coast Beach Escape',
        'A quick beach break with Galle Fort, the Madu River, a night at Mirissa and (in season) a morning of whale watching.',
        'A quick beach break with Galle Fort, the Madu River, a night at Mirissa and (in season) a morning of whale watching.',
        2,
        'Colombo → Galle → Mirissa → Colombo',
        'November to April',
        ARRAY['Beaches','Wildlife'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        7,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Turtle hatchery and river boat (about 5), whale watching boat (about 5; Comfort and Signature)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 25, 'beach guesthouse, whale watching as add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 65, 'boutique beach hotel, whale watching, dinner included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 55, 'villa with sea view, half board, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('d43f9a0f-724c-4b87-9e56-c02f373b228f', 1, 'Fort and Coast', 'Pickup in Colombo and drive south by expressway. Visit a turtle hatchery and the Madu River, then walk Galle Fort. Sunset at Mirissa and overnight by the beach.', 'Check route'),
('d43f9a0f-724c-4b87-9e56-c02f373b228f', 2, 'Whales and Waves', 'Early morning whale watching boat trip from Mirissa (November–April), or a beach morning at other times. Coconut Tree Hill and Weligama, then return to Colombo by expressway.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '163778b1-6125-4ab1-bcda-ecce8816c332',
        'yala-safari-escape',
        'Yala Safari Escape',
        'Two safaris, one night in the wild. Yala has one of the highest leopard densities in the world, with elephants, sloth bears and crocodiles too.',
        'Two safaris, one night in the wild. Yala has one of the highest leopard densities in the world, with elephants, sloth bears and crocodiles too.',
        2,
        'Colombo / Galle → Tissamaharama → Yala → return',
        'February to July for leopards; check park closure dates in September–October',
        ARRAY['Wildlife','Adventure'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        8,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Park entrance fees and jeep hire (about 0–85 pp per safari when two people share a jeep)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 95, 'guesthouse, one safari included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 65, 'safari lodge, two safaris, dinner included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 65, 'luxury lodge or tented camp, half board, two private jeep safaris with a naturalist guide', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('163778b1-6125-4ab1-bcda-ecce8816c332', 1, 'Into the Wild', 'Pickup in Colombo or Galle and drive to Tissamaharama. Check in, then head out on an afternoon jeep safari in Yala National Park. Overnight near the park.', 'Check route'),
('163778b1-6125-4ab1-bcda-ecce8816c332', 2, 'Dawn Safari', 'Pre-dawn start for a morning safari, the best time for leopards. Breakfast at the hotel and return journey.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '8ebd3463-082c-4f94-a29e-b7cb1f177d45',
        'hill-country-highlights',
        'Hill Country Highlights',
        'Temples, tea and one of the world''s great train journeys. Kandy''s sacred sights, the misty hills of Nuwara Eliya and the viewpoints of Ella.',
        'Temples, tea and one of the world''s great train journeys. Kandy''s sacred sights, the misty hills of Nuwara Eliya and the viewpoints of Ella.',
        3,
        'Colombo → Kandy → Nuwara Eliya → Ella',
        'December to March',
        ARRAY['Hill Country','Culture & Heritage'],
        'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        9,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Temple of the Tooth, Peradeniya, dance show, train ticket, tea factory (about 5 in total). Train tickets sell out early, so the owner should book in advance.'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 95, 'guesthouses, second-class reserved train seats', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 30, '3–4★ hotels, reserved seats, dinners in Kandy and Nuwara Eliya', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 60, 'boutique hotels, first-class or observation-car seats where available, half board, private tea tasting', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 1, 'Kandy', 'Pickup in Colombo or at the airport. Visit the Temple of the Tooth and Peradeniya Botanical Gardens. Evening Kandyan dance show. Overnight in Kandy.', 'Check route'),
('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 2, 'Train to the Tea Country', 'Ride the scenic hill-country train from Kandy to Nanu Oya while the driver meets you with the car. Tea factory visit and tasting, then a walk around Nuwara Eliya. Overnight in Nuwara Eliya.', 'Check route'),
('8ebd3463-082c-4f94-a29e-b7cb1f177d45', 3, 'Ella', 'Drive through the hills to Ella. Walk to the Nine Arch Bridge, Little Adam''s Peak and Ravana Falls. Drop-off in Ella, or continue to the south coast or back to Colombo (about 6–7 hours; supplement applies).', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '07c78f95-bdcb-4909-b56f-36fcb883a896',
        'south-coast-galle-fort',
        'South Coast & Galle Fort',
        'Golden beaches, a colonial fort, mangrove rivers and, in season, blue whales. The classic south coast, unhurried.',
        'Golden beaches, a colonial fort, mangrove rivers and, in season, blue whales. The classic south coast, unhurried.',
        3,
        'Colombo → Bentota → Galle → Mirissa → Colombo',
        'November to April',
        ARRAY['Beaches','Culture & Heritage','Wildlife'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        10,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Turtle hatchery and river boat (about 5), whale watching boat (about 5; Comfort and Signature)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 85, 'guesthouses in Galle and Mirissa', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 85, 'boutique hotels, whale watching, dinner at Mirissa', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 15, 'fort boutique hotel and cliff villa, half board, private whale watching boat, sunset dinner on the beach', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('07c78f95-bdcb-4909-b56f-36fcb883a896', 1, 'Bentota to Galle', 'Pickup in Colombo and drive south. Turtle hatchery and Madu River boat ride. Afternoon in Galle Fort, ramparts and sunset. Overnight in Galle.', 'Check route'),
('07c78f95-bdcb-4909-b56f-36fcb883a896', 2, 'Mirissa', 'Morning whale watching (November–April) or a beach and surf morning. Coconut Tree Hill and Weligama. Free afternoon on the beach. Overnight in Mirissa.', 'Check route'),
('07c78f95-bdcb-4909-b56f-36fcb883a896', 3, 'Coast to Colombo', 'Relaxed morning, optional snorkelling or a cooking class, then return by expressway.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '48e6d264-45e3-47a9-882a-4444079079d7',
        'cultural-triangle-and-kandy',
        'Cultural Triangle & Kandy',
        'Sri Lanka''s greatest historic sites in one loop: cave temples, a rock fortress, a ruined capital and the last royal city.',
        'Sri Lanka''s greatest historic sites in one loop: cave temples, a rock fortress, a ruined capital and the last royal city.',
        3,
        'Colombo → Dambulla → Sigiriya → Polonnaruwa → Kandy → Colombo',
        'Year-round',
        ARRAY['Culture & Heritage'],
        'https://images.unsplash.com/photo-1579730591523-28957cdbd045?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        11,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya (5), Polonnaruwa (0), Dambulla (about ), Temple of the Tooth, Peradeniya, dance show (about 9 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 75, 'guesthouses', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 05, '3–4★ hotels, dinners at both hotels', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 35, 'boutique hotels, half board, private village lunch experience', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('48e6d264-45e3-47a9-882a-4444079079d7', 1, 'Dambulla and Sigiriya', 'Pickup in Colombo and drive north. Visit the Dambulla Cave Temple. Late afternoon at Sigiriya''s gardens and village. Overnight in Sigiriya.', 'Check route'),
('48e6d264-45e3-47a9-882a-4444079079d7', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Afternoon at Polonnaruwa''s ruins. Drive to Kandy via a spice garden in Matale. Evening dance show. Overnight in Kandy.', 'Check route'),
('48e6d264-45e3-47a9-882a-4444079079d7', 3, 'Sacred Kandy', 'Temple of the Tooth and Peradeniya Botanical Gardens, then return to Colombo.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '00e5c863-62ed-4057-a7fa-0ff069a4cffc',
        'yala-udawalawe-safari-trail',
        'Yala & Udawalawe Safari Trail',
        'Two parks, two very different safaris: elephants in Udawalawe and leopards in Yala, with a stop at Galle Fort on the way home.',
        'Two parks, two very different safaris: elephants in Udawalawe and leopards in Yala, with a stop at Galle Fort on the way home.',
        3,
        'Colombo → Udawalawe → Yala → Galle → Colombo',
        'February to July for leopards; check Yala closure dates (September–October)',
        ARRAY['Wildlife','Adventure'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        12,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Udawalawe safari (estimate, about 0 pp), Yala safari (about 2 pp when two share a jeep)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 25, 'safari guesthouses, shared or standard jeeps', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 60, 'safari lodges, private jeeps, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 20, 'luxury lodges or tented camp, half board, private jeeps with naturalist guide', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 1, 'Elephants', 'Pickup in Colombo and drive to Udawalawe. Lunch, then afternoon safari and the Elephant Transit Home. Overnight in Udawalawe.', 'Check route'),
('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 2, 'Leopard Country', 'Drive to Yala. Safari in the late afternoon. Overnight near the park.', 'Check route'),
('00e5c863-62ed-4057-a7fa-0ff069a4cffc', 3, 'Dawn and Galle', 'Early morning Yala safari. Breakfast, then drive to Galle Fort for lunch and a walk, and return to Colombo.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '2106c2f3-e4f1-4342-be5c-5f57d1641f25',
        'glimpse-of-sri-lanka',
        'Glimpse of Sri Lanka',
        'A first taste of the island in four days: elephants, a rock fortress, spice gardens, the Temple of the Tooth and a night in Colombo. Ideal as a short stopover.',
        'A first taste of the island in four days: elephants, a rock fortress, spice gardens, the Temple of the Tooth and a night in Colombo. Ideal as a short stopover.',
        4,
        'Airport → Habarana / Sigiriya → Kandy → Colombo',
        'Year-round',
        ARRAY['Culture & Heritage','Wildlife'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        13,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Minneriya safari (about 0), Sigiriya (5), Temple of the Tooth, Peradeniya, dance show (about 00 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 35, 'guesthouses and a budget city hotel', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 25, '3–4★ hotels, dinners in Habarana and Kandy', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 000, 'boutique hotels, half board, private jeep with naturalist guide', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening jeep safari at Minneriya National Park. Overnight in Habarana or Sigiriya.', 'Check route'),
('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 2, 'Lion Rock and Kandy', 'Sunrise climb of Sigiriya Rock. Visit a spice garden in Matale. Arrive in Kandy and enjoy an evening dance show. Overnight in Kandy.', 'Check route'),
('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 3, 'Sacred Kandy and Colombo', 'Temple of the Tooth and Peradeniya Botanical Gardens. Drive to Colombo for a city tour (Fort, Pettah, Galle Face). Overnight in Colombo.', 'Check route'),
('2106c2f3-e4f1-4342-be5c-5f57d1641f25', 4, 'Departure', 'Breakfast and transfer to the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'fab1db1c-1d61-4845-90f9-e522c4298481',
        'hill-country-tea-trails',
        'Hill Country & Tea Trails',
        'Ride the famous hill-country train, taste fresh Ceylon tea, hike World''s End and cross the Nine Arch Bridge.',
        'Ride the famous hill-country train, taste fresh Ceylon tea, hike World''s End and cross the Nine Arch Bridge.',
        4,
        'Colombo → Kandy → Nuwara Eliya → Ella → Colombo',
        'December to March',
        ARRAY['Hill Country','Adventure'],
        'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        14,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains (about 0 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 10, 'guesthouses and homestays', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 05, 'boutique hotels, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 85, 'tea bungalow and luxury villa, half board, first-class train seats where available, private tea tasting', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('fab1db1c-1d61-4845-90f9-e522c4298481', 1, 'Kandy', 'Pickup and drive to Kandy. Temple of the Tooth and Peradeniya Botanical Gardens. Overnight in Kandy.', 'Check route'),
('fab1db1c-1d61-4845-90f9-e522c4298481', 2, 'Train to Tea Country', 'Scenic train from Kandy to Nanu Oya. Tea factory visit. Explore Nuwara Eliya. Overnight there.', 'Check route'),
('fab1db1c-1d61-4845-90f9-e522c4298481', 3, 'World''s End and Ella', 'Sunrise hike at Horton Plains. Drive to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route'),
('fab1db1c-1d61-4845-90f9-e522c4298481', 4, 'Ella to Colombo', 'Morning at the Nine Arch Bridge and Ravana Falls, then the long drive back (about 6–7 hours).', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'ee7c72e6-90ce-48a7-937d-9b3e33012abd',
        'south-coast-beaches-yala',
        'South Coast Beaches & Yala',
        'Sand, sea and safari. Explore Galle Fort, whale watch from Mirissa and finish with a jeep safari in Yala.',
        'Sand, sea and safari. Explore Galle Fort, whale watch from Mirissa and finish with a jeep safari in Yala.',
        4,
        'Colombo → Galle → Mirissa → Yala → Colombo',
        'November to April',
        ARRAY['Beaches','Wildlife'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        15,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Hatchery and river boat (about 5), whale watching (about 5; Comfort and Signature), Yala safari (about 2)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 45, 'guesthouses, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 00, 'boutique hotels, safari lodge, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 080, 'luxury villas and tented camp, half board, private whale watching boat, private safari', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 1, 'Galle Fort', 'Pickup in Colombo, coastal stops at a turtle hatchery and the Madu River, then Galle Fort. Overnight in Galle.', 'Check route'),
('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 2, 'Whales and Beaches', 'Morning whale watching from Mirissa (November–April), beach time and Weligama. Overnight in Mirissa.', 'Check route'),
('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 3, 'Yala', 'Drive to Yala and go on an afternoon safari. Overnight near the park.', 'Check route'),
('ee7c72e6-90ce-48a7-937d-9b3e33012abd', 4, 'Dawn and Home', 'Early morning safari, breakfast and return to Colombo.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '68cc07d5-3c1c-4655-9412-4672b1df745f',
        'ancient-cities-deep-dive',
        'Ancient Cities Deep Dive',
        'For history lovers: Sri Lanka''s first capital Anuradhapura, the sacred hill of Mihintale, Sigiriya, Polonnaruwa and the cave temples of Dambulla.',
        'For history lovers: Sri Lanka''s first capital Anuradhapura, the sacred hill of Mihintale, Sigiriya, Polonnaruwa and the cave temples of Dambulla.',
        4,
        'Colombo → Anuradhapura → Sigiriya → Polonnaruwa → Dambulla → Colombo',
        'Year-round',
        ARRAY['Culture & Heritage','Wildlife'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        16,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Anuradhapura (0), Sigiriya (5), Polonnaruwa (0), Dambulla (about ), Minneriya safari (about 0)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 85, 'guesthouses', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 75, 'heritage hotels, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 045, 'boutique heritage resorts, half board, private archaeology-specialist guide for one day', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('68cc07d5-3c1c-4655-9412-4672b1df745f', 1, 'Anuradhapura', 'Pickup in Colombo and drive to Anuradhapura. Visit the Sri Maha Bodhi tree, great stupas and ancient ponds. Overnight there.', 'Check route'),
('68cc07d5-3c1c-4655-9412-4672b1df745f', 2, 'Mihintale and Sigiriya', 'Sunrise at Mihintale, the cradle of Buddhism in Sri Lanka. Drive to Sigiriya and take an afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('68cc07d5-3c1c-4655-9412-4672b1df745f', 3, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock. Afternoon exploring Polonnaruwa. Overnight in Sigiriya.', 'Check route'),
('68cc07d5-3c1c-4655-9412-4672b1df745f', 4, 'Dambulla and Home', 'Visit the Dambulla Cave Temple, then drive back to Colombo.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '6548eb1e-1350-4af0-99e2-10744750fdea',
        'culture-hill-country-5-days',
        'Culture & Hill Country (5 Days)',
        'Ancient rock fortress, sacred Kandy and the tea hills, connected by a scenic train ride. A well-paced first trip.',
        'Ancient rock fortress, sacred Kandy and the tea hills, connected by a scenic train ride. A well-paced first trip.',
        5,
        'Airport → Sigiriya → Kandy → Nuwara Eliya → Colombo',
        'December to March',
        ARRAY['Culture & Heritage','Hill Country','Wildlife'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        17,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Minneriya safari, Sigiriya, Tooth temple, Peradeniya, dance show, train ticket (about 17 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 15, 'guesthouses, budget city hotel', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 65, '3–4★ hotels, four dinners', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 320, 'boutique hotels, half board, private jeep, first-class train seats where available', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('6548eb1e-1350-4af0-99e2-10744750fdea', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('6548eb1e-1350-4af0-99e2-10744750fdea', 2, 'Lion Rock to Kandy', 'Sunrise climb of Sigiriya Rock, spice garden stop and arrival in Kandy. Evening dance show. Overnight in Kandy.', 'Check route'),
('6548eb1e-1350-4af0-99e2-10744750fdea', 3, 'Kandy to the Hills', 'Temple of the Tooth and Peradeniya Gardens, then scenic train from Kandy to Nanu Oya. Overnight in Nuwara Eliya.', 'Check route'),
('6548eb1e-1350-4af0-99e2-10744750fdea', 4, 'Tea and Return', 'Tea factory visit and colonial town walk, then drive to Colombo via the tea country. Overnight in Colombo.', 'Check route'),
('6548eb1e-1350-4af0-99e2-10744750fdea', 5, 'Departure', 'Breakfast and transfer to the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '85393f3f-cc1f-43ca-a119-323370659b72',
        'hills-tea-beach-6-days',
        'Hills, Tea & Beach (6 Days)',
        'Mountains first, then the sea. Trains, tea, waterfalls and viewpoints, followed by two nights on the south coast.',
        'Mountains first, then the sea. Trains, tea, waterfalls and viewpoints, followed by two nights on the south coast.',
        6,
        'Colombo → Kandy → Nuwara Eliya → Ella → Mirissa → Colombo',
        'December to April',
        ARRAY['Hill Country','Beaches','Adventure'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        18,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains (about 0–135 in total), whale watching for Comfort and Signature'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 30, 'guesthouses, whale watching as add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 05, 'boutique hotels, whale watching, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 615, 'tea bungalow, luxury villas, half board, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('85393f3f-cc1f-43ca-a119-323370659b72', 1, 'Kandy', 'Pickup and drive to Kandy. Temple of the Tooth and lake. Overnight in Kandy.', 'Check route'),
('85393f3f-cc1f-43ca-a119-323370659b72', 2, 'Train to Nuwara Eliya', 'Peradeniya Gardens, then train to Nanu Oya and tea factory visit. Overnight in Nuwara Eliya.', 'Check route'),
('85393f3f-cc1f-43ca-a119-323370659b72', 3, 'World''s End and Ella', 'Sunrise at Horton Plains, then drive to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route'),
('85393f3f-cc1f-43ca-a119-323370659b72', 4, 'Ella to the Coast', 'Nine Arch Bridge, then a scenic drive down to the south coast. Overnight in Mirissa.', 'Check route'),
('85393f3f-cc1f-43ca-a119-323370659b72', 5, 'Whales and Beach', 'Whale watching (November–April) and free beach time. Overnight in Mirissa.', 'Check route'),
('85393f3f-cc1f-43ca-a119-323370659b72', 6, 'Departure', 'Galle Fort stop on the way to Colombo or the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'f19cefb2-64ed-4ae2-8f2c-11810a529da2',
        'sri-lanka-essentials-7-days',
        'Sri Lanka Essentials (7 Days)',
        'Our signature week: ancient cities, sacred temples, tea hills, a leopard safari and a night in Galle Fort. Everything a first-time visitor wants to see.',
        'Our signature week: ancient cities, sacred temples, tea hills, a leopard safari and a night in Galle Fort. Everything a first-time visitor wants to see.',
        7,
        'Airport → Sigiriya → Kandy → Nuwara Eliya → Yala → Galle → Airport',
        'December to March',
        ARRAY['Culture & Heritage','Wildlife','Hill Country'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        19,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya, Polonnaruwa, Minneriya safari, Tooth temple, Peradeniya, dance show, train ticket, Yala safari (about 34 in total)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 75, 'guesthouses and simple hotels', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 040, '3–4★ hotels, safari lodge, six dinners', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 000, 'boutique hotels and luxury lodge, half board, private jeeps with naturalist guides, first-class train seats where available', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 1, 'Arrival and Elephants', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock, then explore Polonnaruwa. Overnight in Sigiriya.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 3, 'Kandy', 'Dambulla Cave Temple or spice garden on the way. Temple of the Tooth, Peradeniya Gardens and the evening dance show. Overnight in Kandy.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 4, 'Train to the Hills', 'Scenic train from Kandy to Nanu Oya, tea factory visit and a colonial walk in Nuwara Eliya. Overnight there.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 5, 'Down to Yala', 'Descend from the hills to Yala. Evening safari for leopards and elephants. Overnight near the park.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 6, 'Galle Fort', 'Drive to the south coast. Explore Galle Fort''s ramparts and streets. Overnight in Galle.', 'Check route'),
('f19cefb2-64ed-4ae2-8f2c-11810a529da2', 7, 'Departure', 'Breakfast and transfer to the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '14ff027f-df19-4d0e-8af2-f064eafbe220',
        'wildlife-beaches-7-days',
        'Wildlife & Beaches (7 Days)',
        'Elephants and leopards, then whales and beaches. A week on the wild south of the island.',
        'Elephants and leopards, then whales and beaches. A week on the wild south of the island.',
        7,
        'Colombo → Udawalawe → Yala → Mirissa → Galle → Colombo',
        'November to April',
        ARRAY['Wildlife','Beaches'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        20,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Udawalawe and Yala safaris, Elephant Transit Home, Galle Fort (about 50–300 depending on tier), whale watching for Comfort and Signature'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 80, 'guesthouses, one Yala safari, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 120, 'safari lodges and boutique hotels, two Yala safaris, whale watching, dinners included', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 130, 'luxury lodges and villas, half board, private jeeps with naturalist guides, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('14ff027f-df19-4d0e-8af2-f064eafbe220', 1, 'Elephants', 'Pickup and drive to Udawalawe. Evening safari. Overnight there.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 2, 'Transit Home and Yala', 'Visit the Elephant Transit Home, then drive to Yala. Overnight near the park.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 3, 'Leopard Day', 'Dawn safari in Yala, rest at the lodge and optional second safari (Comfort and Signature). Overnight near the park.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 4, 'To the Coast', 'Drive to Mirissa. Beach afternoon and sunset. Overnight in Mirissa.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 5, 'Whales', 'Morning whale watching (November–April), beach or surf lesson in the afternoon. Overnight in Mirissa.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 6, 'Galle Fort', 'Coastal drive to Galle. Explore the Fort. Overnight in Galle.', 'Check route'),
('14ff027f-df19-4d0e-8af2-f064eafbe220', 7, 'Departure', 'Transfer to Colombo or the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '4c79a484-75ae-4265-bd03-c7e338ef17f6',
        'romance-in-paradise-8-days',
        'Romance in Paradise (8 Days)',
        'A honeymoon or anniversary trip: ancient wonders, misty tea hills, a scenic train and a beach finale. Romantic touches are built into the Comfort and Signature tiers.',
        'A honeymoon or anniversary trip: ancient wonders, misty tea hills, a scenic train and a beach finale. Romantic touches are built into the Comfort and Signature tiers.',
        8,
        'Airport → Sigiriya → Kandy → Nuwara Eliya → Ella → Mirissa → Airport',
        'December to April',
        ARRAY['Beaches','Hill Country','Culture & Heritage'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        21,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya, Tooth temple, Peradeniya, train ticket, tea factory, Horton Plains, Galle Fort (about 17 for Essential, 72 with whale watching for Comfort and Signature)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 95, 'guesthouses, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 090, 'boutique hotels, room decoration on arrival, one candlelit dinner, whale watching', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 305, 'luxury villas, half board, private sunset dinner on the beach, couple''s spa session, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 1, 'Arrival', 'Airport welcome, drive north and settle in at Sigiriya.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 2, 'Lion Rock', 'Sunrise climb of Sigiriya Rock, afternoon at leisure. Overnight in Sigiriya.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 3, 'Kandy', 'Temple of the Tooth, botanical gardens and evening dance show. Overnight in Kandy.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 4, 'Train to Nuwara Eliya', 'Scenic train, tea factory and colonial walk. Overnight there.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 5, 'World''s End and Ella', 'Sunrise at Horton Plains, then on to Ella. Sunset at Little Adam''s Peak. Overnight in Ella.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 6, 'To the Coast', 'Nine Arch Bridge, then a scenic drive to Mirissa. Overnight there.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 7, 'Whales and Beach', 'Whale watching (November–April) and a beach afternoon. Overnight in Mirissa.', 'Check route'),
('4c79a484-75ae-4265-bd03-c7e338ef17f6', 8, 'Departure', 'Galle Fort stop on the way to the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '682b42bd-b050-4957-a46b-88b72485a3a2',
        'wildlife-grand-safari-9-days',
        'Wildlife Grand Safari (9 Days)',
        'Five national parks in nine days: leopards and sloth bears in Wilpattu, elephants at Minneriya, Horton Plains, Udawalawe and Yala, with whale watching to finish.',
        'Five national parks in nine days: leopards and sloth bears in Wilpattu, elephants at Minneriya, Horton Plains, Udawalawe and Yala, with whale watching to finish.',
        9,
        'Airport → Wilpattu → Sigiriya → Nuwara Eliya → Udawalawe → Yala → Mirissa → Galle → Airport',
        'February to July (check Yala closure dates in September–October)',
        ARRAY['Wildlife','Adventure','Hill Country'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        22,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Wilpattu, Minneriya, Udawalawe and Yala safaris, Sigiriya, Horton Plains, Galle Fort (about 52 for Essential, 07 with whale watching for Comfort and Signature). Wilpattu and Udawalawe costs are estimates.'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 40, 'guesthouses and simple lodges, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 490, 'safari lodges and boutique hotels, dinners included, whale watching', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 810, 'luxury tented camps and lodges, half board, private jeeps with naturalist guides, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('682b42bd-b050-4957-a46b-88b72485a3a2', 1, 'To the Northwest', 'Airport welcome and drive to Wilpattu. Overnight there.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 2, 'Wilpattu', 'Morning jeep safari, then transfer to Sigiriya. Overnight there.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 3, 'Minneriya', 'Sunrise at Sigiriya Rock, then an afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 4, 'To the Hills', 'Drive to Nuwara Eliya via Kandy. Overnight there.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 5, 'Horton Plains and Udawalawe', 'Sunrise hike at World''s End, then descend to Udawalawe for an evening safari. Overnight there.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 6, 'Elephants to Leopards', 'Transit Home visit, then drive to Yala for an afternoon safari. Overnight near the park.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 7, 'Dawn in Yala', 'Early safari, then drive to Mirissa. Overnight there.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 8, 'Whales and Galle', 'Whale watching (November–April), then Galle Fort. Overnight in Galle.', 'Check route'),
('682b42bd-b050-4957-a46b-88b72485a3a2', 9, 'Departure', 'Transfer to the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        'd92adba4-eedf-4bc6-8037-a29b88309800',
        'grand-island-loop-10-days',
        'Grand Island Loop (10 Days)',
        'The full island in ten days: heritage cities, tea hills, the Ella train, a leopard safari and the southern beaches. Our most complete round trip.',
        'The full island in ten days: heritage cities, tea hills, the Ella train, a leopard safari and the southern beaches. Our most complete round trip.',
        10,
        'Airport → Sigiriya → Kandy → Nuwara Eliya → Ella → Yala → Mirissa → Galle → Colombo',
        'December to March',
        ARRAY['Culture & Heritage','Wildlife','Hill Country','Beaches'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        23,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Sigiriya, Polonnaruwa, Minneriya, Dambulla, Tooth temple, Peradeniya, train ticket, Horton Plains, tea factory, Yala safari, Galle Fort (about 76 for Essential, 31 with whale watching for Comfort and Signature)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 05, 'guesthouses and homestays, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 515, '3–4★ hotels and lodges, dinners included, whale watching', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 990, 'boutique hotels and luxury lodges, half board, private jeeps, first-class train seats where available, private whale watching boat', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('d92adba4-eedf-4bc6-8037-a29b88309800', 1, 'Arrival', 'Airport welcome and drive north. Evening safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 2, 'Lion Rock and Polonnaruwa', 'Sunrise climb of Sigiriya Rock, afternoon at Polonnaruwa. Overnight in Sigiriya.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 3, 'Dambulla and Kandy', 'Dambulla Cave Temple, Matale spice garden, then Kandy and the dance show. Overnight in Kandy.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 4, 'Sacred Kandy and the Train', 'Temple of the Tooth and Peradeniya Gardens, then the scenic train to Nanu Oya. Overnight in Nuwara Eliya.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 5, 'Tea and World''s End', 'Horton Plains at sunrise, then a tea factory visit and a colonial walk. Overnight in Nuwara Eliya.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 6, 'Ella', 'Scenic route to Ella. Nine Arch Bridge, Little Adam''s Peak, Ravana Falls. Overnight in Ella.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 7, 'Yala', 'Drive to Yala for an afternoon safari. Overnight near the park.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 8, 'Dawn Safari and Mirissa', 'Early safari, then drive to Mirissa. Overnight there.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 9, 'Whales and Galle', 'Whale watching (November–April), then Galle Fort. Overnight in Galle.', 'Check route'),
('d92adba4-eedf-4bc6-8037-a29b88309800', 10, 'Departure', 'Transfer to Colombo or the airport.', 'Check route');


WITH new_package AS (
    INSERT INTO public.packages (id, slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order, inclusions, exclusions)
    VALUES (
        '7722a939-ac20-42d9-b3b4-1524ab7a9770',
        'complete-sri-lanka-14-days',
        'Complete Sri Lanka (14 Days)',
        'Two weeks at a relaxed pace with two-night stays at the key stops. Ancient capitals, tea country, two safaris and time to unwind on the south coast.',
        'Two weeks at a relaxed pace with two-night stays at the key stops. Ancient capitals, tea country, two safaris and time to unwind on the south coast.',
        14,
        'Airport → Anuradhapura → Sigiriya → Kandy → Nuwara Eliya → Ella → Udawalawe / Yala → Mirissa → Galle → Airport',
        'December to March',
        ARRAY['Culture & Heritage','Wildlife','Hill Country','Beaches','Adventure'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        24,
        ARRAY['Private air-conditioned vehicle with an English-speaking chauffeur-guide for the whole itinerary','Fuel, highway tolls, parking, driver meals and accommodation','Airport or Colombo pickup on the first day and drop-off on the last day for multi-day plans','Accommodation as per the chosen tier, on twin-share basis with breakfast','Entrance fees for the main sites listed under ''Extra inclusions'' for each plan','Government taxes and service charges at hotels','Bottled water in the vehicle','24-hour WhatsApp support from the Serendib Days team','Anuradhapura, Sigiriya, Polonnaruwa, Minneriya, Dambulla, Tooth temple, Peradeniya, train ticket, Horton Plains, tea factory, Udawalawe, Yala, Galle (about 66 for Essential, 21 with whale watching for Comfort and Signature)'],
        ARRAY['International flights and travel insurance','Meals not mentioned, drinks and personal expenses','Entrance fees and activities not listed','Camera or video permit fees at some sites','Tips (drivers and guides are usually tipped about $5–10 per day, given at the end of the trip)','Peak-season hotel supplements (Dec–Apr and Jul–Aug)','Single room supplement']
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 255, 'guesthouses and homestays, whale watching as an add-on', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'comfort', 100, 'boutique hotels and safari lodges, dinners included, whale watching', 'See description', 'None' FROM new_package UNION ALL 
SELECT id, 'signature', 140, 'luxury hotels and villas, half board, private jeeps with naturalist guides, first-class train seats where available, private whale watching boat, one cooking class or spa session', 'See description', 'None' FROM new_package;

INSERT INTO public.itinerary_days (package_id, day_number, title, description, overnight_location) VALUES 
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 1, 'Arrival', 'Airport welcome and drive to Anuradhapura. Overnight there.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 2, 'Sacred City', 'Anuradhapura''s stupas and Bodhi tree, and Mihintale at sunset. Drive to Sigiriya. Overnight there.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 3, 'Lion Rock', 'Sunrise climb of Sigiriya Rock and afternoon safari at Minneriya. Overnight in Sigiriya.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 4, 'Polonnaruwa and Kandy', 'Explore Polonnaruwa, then drive to Kandy via Dambulla. Overnight in Kandy.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 5, 'Kandy at Leisure', 'Temple of the Tooth, Peradeniya Gardens, dance show. Overnight in Kandy.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 6, 'Train to Tea Country', 'Scenic train to Nanu Oya and tea factory visit. Overnight in Nuwara Eliya.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 7, 'World''s End', 'Sunrise hike at Horton Plains, afternoon at leisure. Overnight in Nuwara Eliya.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 8, 'Ella', 'Scenic drive to Ella. Little Adam''s Peak. Overnight in Ella.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 9, 'Ella at Leisure', 'Nine Arch Bridge, Ravana Falls, optional cooking class. Overnight in Ella.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 10, 'Udawalawe and Yala', 'Udawalawe safari on the way, then on to Yala. Overnight near the park.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 11, 'Dawn Safari and Mirissa', 'Early safari in Yala, then the drive to Mirissa. Overnight there.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 12, 'Whales and Beach', 'Whale watching (November–April) and free time. Overnight in Mirissa.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 13, 'Galle', 'Galle Fort, turtle hatchery and Madu River. Overnight in Galle.', 'Check route'),
('7722a939-ac20-42d9-b3b4-1524ab7a9770', 14, 'Departure', 'Transfer to the airport.', 'Check route');

