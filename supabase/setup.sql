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

-- 4. Seed Data
-- Insert 1 Package (Essentials)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'sri-lanka-essentials',
        'Sri Lanka Essentials',
        'A perfect 7-day introduction to Sri Lanka covering culture, wildlife, and the coast.',
        'Experience the highlights of Sri Lanka in an unforgettable week. This journey takes you from the ancient marvels of the Cultural Triangle to the cool tea-covered hills of the central province, concluding with a classic wildlife safari and relaxing beach time on the south coast.',
        7,
        'Negombo - Sigiriya - Kandy - Ella - Yala - South Coast',
        'December to April',
        ARRAY['culture', 'wildlife', 'hill country', 'beach'],
        'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        1
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 750, 'Comfortable 3-star guesthouses and boutique hotels.', 'Air-conditioned car with an English-speaking driver.', 'Standard entrance tickets.' FROM new_package
UNION ALL
SELECT id, 'comfort', 1100, 'Premium 4-star hotels with swimming pools.', 'Comfortable SUV with an English-speaking driver-guide.', 'Guided tours included.' FROM new_package
UNION ALL
SELECT id, 'signature', 1800, 'Luxury 5-star and boutique heritage properties.', 'Luxury vehicle with an expert local guide.', 'Exclusive dining and private safari jeep.' FROM new_package;

-- Insert testimonials
INSERT INTO public.testimonials (name, country, text, rating, is_published) VALUES
('Sarah & Mark', 'UK', 'Serendib Days planned our honeymoon perfectly. The driver was so knowledgeable and the hotels were fantastic!', 5, true),
('The Johnson Family', 'Australia', 'Traveling with kids can be tough, but the local insights and flexibility made this the best family trip we have had.', 5, true),
('Emma', 'Germany', 'I loved the balance of culture and nature. The train ride to Ella was a core memory. Highly recommend.', 5, true),
('David', 'USA', 'Great service, clear communication. We always felt safe and well taken care of.', 4, true);

-- Insert FAQs
INSERT INTO public.faqs (question, answer, sort_order, is_published) VALUES
('Do I need a visa for Sri Lanka?', 'Yes, most nationalities need an ETA (Electronic Travel Authorization) which can be applied for online before arrival.', 1, true),
('When is the best time to visit?', 'Sri Lanka is a year-round destination! The south and west coasts are best from December to April, while the east coast shines from May to September.', 2, true),
('Are the prices per person?', 'Prices are generally indicative starting prices per person based on two people sharing. Exact prices depend on your dates and group size.', 3, true),
('Is Sri Lanka safe for tourists?', 'Yes, Sri Lanka is very safe and welcoming for tourists. Our local guides ensure you are always in good hands.', 4, true),
('Can I customize a package?', 'Absolutely! All our packages can be tailored. Just mention your preferences in the enquiry form.', 5, true),
('What is the difference between tiers?', 'Tiers mainly determine the level of accommodation (3-star vs 5-star) and transport type. All tiers include our 24/7 local support.', 6, true);

-- 2. Sigiriya & Dambulla (1 day)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'sigiriya-dambulla-day',
        'Sigiriya & Dambulla',
        'A full-day excursion to two of Sri Lanka’s most iconic UNESCO World Heritage sites.',
        'Climb the spectacular Lion Rock fortress of Sigiriya in the morning, and explore the ancient painted cave temples of Dambulla in the afternoon. A perfect day trip for history and culture enthusiasts.',
        1,
        'Colombo/Kandy - Sigiriya - Dambulla - Return',
        'Year-round',
        ARRAY['culture'],
        'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        2
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 120, 'Not applicable (Day Tour)', 'Standard A/C car', 'Basic guide' FROM new_package
UNION ALL
SELECT id, 'comfort', 180, 'Not applicable (Day Tour)', 'Comfortable SUV', 'Experienced Guide & Lunch' FROM new_package
UNION ALL
SELECT id, 'signature', 280, 'Not applicable (Day Tour)', 'Luxury Vehicle', 'Premium Guide, Lunch & Refreshments' FROM new_package;

-- 3. Kandy Culture Day (1 day)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'kandy-culture-day',
        'Kandy Culture Day',
        'Experience the spiritual heart of Sri Lanka in this immersive day tour.',
        'Visit the sacred Temple of the Tooth Relic, stroll through the Royal Botanical Gardens in Peradeniya, and enjoy a traditional Kandyan cultural dance performance in the evening.',
        1,
        'Colombo - Kandy - Colombo',
        'Year-round',
        ARRAY['culture'],
        'https://images.unsplash.com/photo-1579730591523-28957cdbd045?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        3
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 90, 'Not applicable', 'Standard A/C car', 'None' FROM new_package
UNION ALL
SELECT id, 'comfort', 140, 'Not applicable', 'SUV with guide', 'Lunch included' FROM new_package
UNION ALL
SELECT id, 'signature', 210, 'Not applicable', 'Luxury Vehicle', 'Fine dining lunch' FROM new_package;

-- 4. Cultural Triangle Escape (2 days)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'cultural-triangle-escape',
        'Cultural Triangle Escape',
        'Two days uncovering ancient capitals and majestic rock fortresses.',
        'Immerse yourself in history as you visit Anuradhapura, Polonnaruwa, and Sigiriya. Perfect for a short weekend getaway from the coast.',
        2,
        'Anuradhapura - Polonnaruwa - Sigiriya',
        'December to August',
        ARRAY['culture'],
        'https://images.unsplash.com/photo-1625736173004-9426f862308e?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        4
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 250, '3-star hotel', 'Standard Car', 'None' FROM new_package
UNION ALL
SELECT id, 'comfort', 350, '4-star hotel', 'SUV', 'Guided tours' FROM new_package
UNION ALL
SELECT id, 'signature', 550, '5-star boutique', 'Luxury Car', 'Exclusive access' FROM new_package;

-- 5. Hill Country Highlights (3 days)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'hill-country-highlights',
        'Hill Country Highlights',
        'A scenic 3-day journey through misty tea plantations and waterfalls.',
        'Ride the famous train from Kandy to Ella, hike Little Adam''s Peak, and visit working tea factories. Enjoy the cool climate and stunning vistas of central Sri Lanka.',
        3,
        'Kandy - Nuwara Eliya - Ella',
        'December to April',
        ARRAY['hill country', 'adventure'],
        'https://images.unsplash.com/photo-1624614138166-724f8d9c5780?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        5
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 300, 'Guesthouses', 'Car & Train', 'None' FROM new_package
UNION ALL
SELECT id, 'comfort', 450, '4-star hotels', 'SUV & 1st Class Train', 'Guided hikes' FROM new_package
UNION ALL
SELECT id, 'signature', 700, 'Luxury Tea Trails', 'Luxury Car & Observation Car', 'High tea included' FROM new_package;

-- 6. South Coast & Galle Fort (3 days)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'south-coast-galle',
        'South Coast & Galle Fort',
        'Relax on golden beaches and stroll the cobbled streets of historic Galle.',
        'Spend three days unwinding by the Indian Ocean. Surf, swim, and explore the colonial Dutch architecture of Galle Fort, a UNESCO World Heritage site.',
        3,
        'Mirissa - Unawatuna - Galle',
        'December to April',
        ARRAY['beach', 'culture'],
        'https://images.unsplash.com/photo-1588665069279-d10e5bd73b22?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        6
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 280, '3-star beach hotels', 'Standard Car', 'None' FROM new_package
UNION ALL
SELECT id, 'comfort', 450, '4-star beach resorts', 'SUV', 'Sunset cruise' FROM new_package
UNION ALL
SELECT id, 'signature', 800, '5-star villas', 'Luxury Car', 'Private dining' FROM new_package;

-- 7. Glimpse of Sri Lanka (4 days)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'glimpse-of-sri-lanka',
        'Glimpse of Sri Lanka',
        'A fast-paced 4-day tour combining the best of culture and nature.',
        'An ideal itinerary for those with limited time. Visit Sigiriya, take a quick trip up to Kandy, and finish with a relaxing day on a west coast beach.',
        4,
        'Sigiriya - Kandy - Bentota',
        'Year-round',
        ARRAY['culture', 'beach'],
        'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
        false,
        true,
        7
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 400, '3-star', 'Standard Car', 'None' FROM new_package
UNION ALL
SELECT id, 'comfort', 600, '4-star', 'SUV', 'Guided tours' FROM new_package
UNION ALL
SELECT id, 'signature', 950, '5-star', 'Luxury Car', 'Spa treatment' FROM new_package;

-- 8. Wildlife & Beaches (7 days)
WITH new_package AS (
    INSERT INTO public.packages (slug, title, short_description, description, duration_days, route, best_time, interests, cover_image, is_featured, is_published, sort_order)
    VALUES (
        'wildlife-and-beaches',
        'Wildlife & Beaches',
        'A week dedicated to spotting leopards and elephants, followed by pristine beaches.',
        'Explore the wilderness of Yala and Udawalawe national parks. Then, head to the southern beaches for surfing, whale watching, and total relaxation.',
        7,
        'Udawalawe - Yala - Mirissa - Tangalle',
        'December to April',
        ARRAY['wildlife', 'beach'],
        'https://images.unsplash.com/photo-1544626154-db27e5ec0150?auto=format&fit=crop&w=800&q=80',
        true,
        true,
        8
    ) RETURNING id
)
INSERT INTO public.package_tiers (package_id, tier, price_usd, stay_details, transport_details, extras)
SELECT id, 'essential', 850, 'Eco-lodges and 3-star', 'Standard Car', 'Group safaris' FROM new_package
UNION ALL
SELECT id, 'comfort', 1250, '4-star resorts', 'SUV', 'Private safaris' FROM new_package
UNION ALL
SELECT id, 'signature', 2100, 'Luxury Tented Camps', 'Luxury Car', 'Premium safaris' FROM new_package;
