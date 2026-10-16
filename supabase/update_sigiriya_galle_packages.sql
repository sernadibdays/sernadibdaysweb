-- ==============================================================================
-- Serandib Days: Update Sigiriya & Dambulla Day and Galle Fort & Coast Day
-- ==============================================================================

-- 1. Update Sigiriya & Dambulla Day (visit Sigiriya Rock first)
UPDATE public.packages
SET 
  short_description = 'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.',
  description = 'Two of Sri Lanka''s great UNESCO sites in one day: start early to climb the sky-high Lion Rock at Sigiriya in the cool morning, followed by the ancient painted caves of Dambulla, finished with a home-cooked village lunch.',
  route = 'Sigiriya area → Sigiriya Rock → Dambulla Cave Temple → village lunch'
WHERE slug = 'sigiriya-dambulla-day';

UPDATE public.itinerary_days
SET 
  title = 'Rock, Caves and Village',
  description = 'Early pickup from your hotel in the Sigiriya, Dambulla or Habarana area. Climb Sigiriya Rock Fortress in the cool morning to beat the heat, admiring the mirror wall and ancient frescoes. Afterwards, visit the Dambulla Cave Temple with its five caves of Buddha statues and frescoes. Enjoy lunch in a nearby village with a short cooking demonstration. Drop-off at your hotel.'
WHERE package_id IN (SELECT id FROM public.packages WHERE slug = 'sigiriya-dambulla-day')
  AND day_number = 1;


-- 2. Update Galle Fort & Coast Day (add visit to mask factory)
UPDATE public.packages
SET 
  short_description = 'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.',
  description = 'A relaxed day on the south-west coast: a boat trip through the Madu River mangroves, a visit to a traditional mask factory, a turtle hatchery, the cobbled streets of Galle Fort and a beach lunch at Unawatuna.',
  route = 'Bentota / Galle → Madu River → mask factory → turtle hatchery → Galle Fort → Unawatuna'
WHERE slug = 'galle-fort-coast-day';

UPDATE public.itinerary_days
SET 
  title = 'Mangroves, Masks, Turtles and the Fort',
  description = 'Pickup in the Bentota or Galle area. Boat ride through the Madu River mangroves. Visit a traditional mask factory and museum to experience local wood carving and folklore masks. Visit a sea turtle conservation hatchery. Walk the ramparts of Galle Fort, the lighthouse and the old Dutch streets. Seafood lunch on Unawatuna beach and free time to swim.'
WHERE package_id IN (SELECT id FROM public.packages WHERE slug = 'galle-fort-coast-day')
  AND day_number = 1;
