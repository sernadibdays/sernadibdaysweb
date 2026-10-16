import React, { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { Clock, MapPin, Calendar, Check, X, Info, ArrowLeft, MessageCircle, ShieldCheck, Sparkles, Share2 } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { PackageCard } from '../components/packages/PackageCard';
import { getPackageBySlug, getPackages } from '../services/packagesService';
import { formatCurrency } from '../utils/currency';
import type { Package, PackageTier, ItineraryDay } from '../types/database';

export default function PackageDetail() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [pkg, setPkg] = useState<Package | null>(null);
  const [relatedPkgs, setRelatedPkgs] = useState<Package[]>([]);
  const [selectedTier, setSelectedTier] = useState<'essential' | 'comfort' | 'signature'>('comfort');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    const fetchPkg = async () => {
      try {
        setLoading(true);
        if (slug) {
          const data = await getPackageBySlug(slug);
          if (data) {
            setPkg(data);
            // Fetch related packages
            const all = await getPackages();
            const related = all
              .filter(p => p.slug !== slug && (p.duration_days === data.duration_days || p.interests.some(i => data.interests.includes(i))))
              .slice(0, 3);
            setRelatedPkgs(related.length > 0 ? related : all.filter(p => p.slug !== slug).slice(0, 3));
          } else {
            setError(true);
          }
        }
      } catch (err) {
        console.error('Error fetching package', err);
        setError(true);
      } finally {
        setLoading(false);
      }
    };
    fetchPkg();
  }, [slug]);

  if (loading) {
    return (
      <div className="min-h-screen pt-32 flex justify-center bg-offwhite">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    );
  }

  if (error || !pkg) {
    return (
      <div className="min-h-screen py-32 bg-offwhite text-center">
        <Container>
          <h2 className="font-serif text-3xl font-bold mb-4 text-slate-900">Package not found</h2>
          <p className="text-slate-600 mb-8 max-w-md mx-auto">
            The itinerary you are looking for is currently being updated or has moved.
          </p>
          <Button to="/packages">Explore All 25 Packages</Button>
        </Container>
      </div>
    );
  }

  const activeTierObj = pkg.package_tiers?.find(t => t.tier === selectedTier) || pkg.package_tiers?.[0];
  const startingPrice = pkg.package_tiers?.length ? Math.min(...pkg.package_tiers.map(t => t.price_usd)) : 0;
  const whatsappNumber = import.meta.env.VITE_WHATSAPP_NUMBER || '+94771234567';
  const whatsappUrl = `https://wa.me/${whatsappNumber.replace(/[^0-9]/g, '')}?text=${encodeURIComponent(`Hello Serendib Days! I'm interested in booking the "${pkg.title}" (${pkg.duration_days} days). Could you share more details?`)}`;

  return (
    <div className="bg-slate-50 pb-24">
      <Helmet>
        <title>{`${pkg.title} (${pkg.duration_days} Days) | Serendib Days`}</title>
        <meta name="description" content={pkg.short_description} />
        <script type="application/ld+json">
          {`
            {
              "@context": "https://schema.org",
              "@type": "TouristTrip",
              "name": "${pkg.title}",
              "description": "${pkg.short_description}",
              "touristType": [
                ${pkg.interests?.map((i: string) => `"${i}"`).join(', ')}
              ],
              "provider": {
                "@type": "Organization",
                "name": "Serendib Days",
                "url": "https://serendibdays.com"
              }
            }
          `}
        </script>
      </Helmet>

      {/* Hero Banner with Photography */}
      <div className="relative h-[60vh] min-h-[460px] max-h-[600px] overflow-hidden">
        <img 
          src={pkg.cover_image} 
          alt={pkg.title} 
          className="w-full h-full object-cover"
          onError={(e) => {
            (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=1600&q=80';
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-slate-900/90 via-slate-900/50 to-slate-900/30"></div>
        
        <Container className="absolute bottom-0 left-0 right-0 p-6 sm:p-10 text-white z-10">
          <Link to="/packages" className="inline-flex items-center gap-2 text-white/80 hover:text-white mb-4 text-xs font-bold uppercase tracking-wider bg-black/30 backdrop-blur-md px-3 py-1.5 rounded-full border border-white/20 transition-colors">
            <ArrowLeft className="h-3.5 w-3.5" /> Back to Packages
          </Link>

          <div className="flex flex-wrap gap-2 mb-3">
            {pkg.interests?.map((interest: string) => (
              <span key={interest} className="text-[11px] font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-accent text-slate-900 shadow-sm">
                {interest}
              </span>
            ))}
          </div>

          <h1 className="font-serif text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight max-w-4xl drop-shadow-md">
            {pkg.title}
          </h1>

          <div className="flex flex-wrap gap-6 text-xs sm:text-sm font-semibold text-slate-200">
            <div className="flex items-center gap-2 bg-white/10 backdrop-blur-md px-3 py-1.5 rounded-xl border border-white/15">
              <Clock className="h-4 w-4 text-accent" />
              <span>{pkg.duration_days} {pkg.duration_days === 1 ? 'Day Excursion' : 'Days Tour'}</span>
            </div>
            <div className="flex items-center gap-2 bg-white/10 backdrop-blur-md px-3 py-1.5 rounded-xl border border-white/15">
              <MapPin className="h-4 w-4 text-accent" />
              <span className="truncate max-w-xs">{pkg.route}</span>
            </div>
            <div className="flex items-center gap-2 bg-white/10 backdrop-blur-md px-3 py-1.5 rounded-xl border border-white/15">
              <Calendar className="h-4 w-4 text-accent" />
              <span>Best: {pkg.best_time}</span>
            </div>
          </div>
        </Container>
      </div>

      <Container className="mt-12">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
          
          {/* Main Content (Left 2 cols) */}
          <div className="lg:col-span-2 space-y-10">
            
            {/* Overview Card */}
            <section className="bg-white p-8 rounded-3xl shadow-sm border border-slate-200">
              <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-primary mb-2">
                <Sparkles className="w-4 h-4" />
                <span>Tour Overview</span>
              </div>
              <h2 className="font-serif text-2xl font-bold text-slate-900 mb-4">Journey Highlights</h2>
              <p className="text-slate-600 leading-relaxed text-base whitespace-pre-line font-normal">
                {pkg.description || pkg.short_description}
              </p>

              <div className="mt-6 pt-6 border-t border-slate-100 flex flex-wrap gap-4 text-xs font-medium text-slate-500">
                <div className="flex items-center gap-1.5">
                  <ShieldCheck className="w-4 h-4 text-primary" />
                  <span>Private Chauffeur-Guide Included</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <ShieldCheck className="w-4 h-4 text-primary" />
                  <span>100% Customizable Itinerary</span>
                </div>
              </div>
            </section>

            {/* Day by Day Itinerary */}
            {pkg.itinerary_days && pkg.itinerary_days.length > 0 && (
              <section className="bg-white p-8 rounded-3xl shadow-sm border border-slate-200">
                <div className="flex items-center justify-between mb-8">
                  <div>
                    <div className="text-xs font-bold uppercase tracking-wider text-primary mb-1">Step-by-Step Experience</div>
                    <h2 className="font-serif text-2xl font-bold text-slate-900">Daily Itinerary</h2>
                  </div>
                  <span className="text-xs font-semibold px-3 py-1 rounded-full bg-slate-100 text-slate-600">
                    {pkg.itinerary_days.length} {pkg.itinerary_days.length === 1 ? 'Day' : 'Days'}
                  </span>
                </div>

                <div className="space-y-8 relative before:absolute before:inset-0 before:left-3.5 before:w-0.5 before:bg-slate-200">
                  {pkg.itinerary_days.map((day: ItineraryDay) => (
                    <div key={day.id || day.day_number} className="relative pl-10">
                      <div className="absolute left-1.5 top-1.5 w-5 h-5 rounded-full bg-primary border-4 border-white shadow-md"></div>
                      
                      <div className="bg-slate-50 p-6 rounded-2xl border border-slate-200 hover:border-primary/40 transition-colors">
                        <div className="flex flex-wrap items-center justify-between gap-2 mb-2">
                          <span className="text-xs font-bold text-primary uppercase tracking-wider">
                            Day {day.day_number}
                          </span>
                          {day.overnight_location && day.overnight_location !== 'Not applicable' && (
                            <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-white text-slate-600 border border-slate-200">
                              Overnight: {day.overnight_location}
                            </span>
                          )}
                        </div>

                        <h3 className="font-serif text-xl font-bold text-slate-900 mb-2">
                          {day.title}
                        </h3>

                        <p className="text-slate-600 text-sm leading-relaxed whitespace-pre-line">
                          {day.description}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}

            {/* Inclusions & Exclusions */}
            <section className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-white p-8 rounded-3xl shadow-sm border border-slate-200">
                <h3 className="font-serif text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                  <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center">
                    <Check className="h-4 w-4" />
                  </div>
                  <span>What's Included</span>
                </h3>
                <ul className="space-y-3">
                  {pkg.inclusions && pkg.inclusions.length > 0 ? (
                    pkg.inclusions.map((item: string, i: number) => (
                      <li key={i} className="flex items-start gap-2.5 text-xs sm:text-sm text-slate-600">
                        <span className="text-emerald-500 font-bold mt-0.5">✓</span>
                        <span>{item}</span>
                      </li>
                    ))
                  ) : (
                    <li className="text-sm text-slate-500">Private vehicle, certified driver-guide, and hotel stays with daily breakfast.</li>
                  )}
                </ul>
              </div>

              <div className="bg-white p-8 rounded-3xl shadow-sm border border-slate-200">
                <h3 className="font-serif text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
                  <div className="w-7 h-7 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center">
                    <X className="h-4 w-4" />
                  </div>
                  <span>Not Included</span>
                </h3>
                <ul className="space-y-3">
                  {pkg.exclusions && pkg.exclusions.length > 0 ? (
                    pkg.exclusions.map((item: string, i: number) => (
                      <li key={i} className="flex items-start gap-2.5 text-xs sm:text-sm text-slate-600">
                        <span className="text-rose-400 font-bold mt-0.5">✕</span>
                        <span>{item}</span>
                      </li>
                    ))
                  ) : (
                    <li className="text-sm text-slate-500">International air tickets, visas, alcoholic drinks, and personal gratuities.</li>
                  )}
                </ul>
              </div>
            </section>

            {/* Important Notes */}
            {pkg.notes && (
              <section className="bg-amber-50/70 p-6 rounded-2xl border border-amber-200/80 text-amber-950 flex gap-4">
                <Info className="h-6 w-6 shrink-0 text-amber-600" />
                <div>
                  <h4 className="font-bold text-sm mb-1 text-amber-900">Local Travel Tip</h4>
                  <p className="text-xs sm:text-sm text-amber-800 leading-relaxed">{pkg.notes}</p>
                </div>
              </section>
            )}

          </div>

          {/* Sticky Booking Sidebar (Right 1 col) */}
          <div className="lg:col-span-1">
            <div className="sticky top-28 space-y-6">
              
              {/* Pricing & Tier Selector Card */}
              <div className="bg-white rounded-3xl shadow-lg border border-slate-200 overflow-hidden">
                <div className="bg-primary p-6 text-white text-center">
                  <span className="text-[10px] uppercase font-bold tracking-widest text-primary-200 block mb-1">
                    Price Options (Per Person)
                  </span>
                  <div className="text-3xl font-serif font-bold">
                    {formatCurrency(activeTierObj ? activeTierObj.price_usd : startingPrice)}
                  </div>
                  <p className="text-primary-100 text-xs mt-1">Based on 2 guests sharing a twin room</p>
                </div>

                {/* Tier Tabs */}
                <div className="p-4 border-b border-slate-100 flex gap-1.5 bg-slate-50">
                  {['essential', 'comfort', 'signature'].map(tierKey => (
                    <button
                      key={tierKey}
                      onClick={() => setSelectedTier(tierKey as any)}
                      className={`flex-1 py-2 text-xs font-bold uppercase rounded-xl transition-all ${
                        selectedTier === tierKey 
                          ? 'bg-primary text-white shadow-sm' 
                          : 'bg-white text-slate-600 hover:bg-slate-200 border border-slate-200'
                      }`}
                    >
                      {tierKey}
                    </button>
                  ))}
                </div>
                
                {/* Active Tier Details */}
                <div className="p-6 space-y-4">
                  {activeTierObj ? (
                    <div className="space-y-3 text-xs sm:text-sm text-slate-600">
                      <div>
                        <strong className="text-slate-900 block font-semibold text-xs uppercase text-slate-400 mb-0.5">Accommodation:</strong>
                        <span>{activeTierObj.stay_details}</span>
                      </div>
                      <div>
                        <strong className="text-slate-900 block font-semibold text-xs uppercase text-slate-400 mb-0.5">Transportation:</strong>
                        <span>{activeTierObj.transport_details}</span>
                      </div>
                      {activeTierObj.extras && activeTierObj.extras !== 'None' && (
                        <div>
                          <strong className="text-slate-900 block font-semibold text-xs uppercase text-slate-400 mb-0.5">Included Extras:</strong>
                          <span>{activeTierObj.extras}</span>
                        </div>
                      )}
                    </div>
                  ) : (
                    <p className="text-xs text-slate-400">Custom pricing available upon request.</p>
                  )}

                  <div className="pt-4 border-t border-slate-100 space-y-3">
                    <Button 
                      onClick={() => navigate(`/contact?package=${pkg.id}`)}
                      size="lg"
                      className="w-full shadow-md"
                    >
                      Enquire About This Package
                    </Button>

                    <a 
                      href={whatsappUrl} 
                      target="_blank" 
                      rel="noreferrer"
                      className="w-full py-3 px-4 rounded-xl border border-emerald-500 text-emerald-700 hover:bg-emerald-50 transition-colors flex items-center justify-center gap-2 text-xs font-bold"
                    >
                      <MessageCircle className="w-4 h-4" />
                      <span>Chat on WhatsApp</span>
                    </a>
                  </div>
                </div>

                <div className="bg-slate-50 p-4 border-t border-slate-100 text-center">
                  <p className="text-[11px] text-slate-400">
                    Solo traveler? Family with kids? We'll tailor the quotation specifically to your group size.
                  </p>
                </div>
              </div>

              {/* Guarantees Box */}
              <div className="bg-white p-6 rounded-3xl border border-slate-200 text-slate-600 text-xs space-y-3 shadow-sm">
                <div className="flex items-center gap-3 font-semibold text-slate-800">
                  <ShieldCheck className="w-5 h-5 text-primary" />
                  <span>Licensed Sri Lanka Tour Operator</span>
                </div>
                <p className="text-slate-500 leading-relaxed">
                  Every booking is backed by 24/7 on-the-ground support and direct contact with your dedicated travel designer.
                </p>
              </div>

            </div>
          </div>

        </div>

        {/* Related Packages Section */}
        {relatedPkgs.length > 0 && (
          <div className="mt-24 pt-16 border-t border-slate-200">
            <div className="flex justify-between items-end mb-8">
              <div>
                <h3 className="font-serif text-2xl font-bold text-slate-900">Similar Journeys You Might Love</h3>
                <p className="text-slate-500 text-sm">Other travelers also explored these alternative routes.</p>
              </div>
              <Link to="/packages" className="text-xs font-bold text-primary hover:underline">
                View all packages →
              </Link>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {relatedPkgs.map(r => (
                <PackageCard key={r.id} pkg={r} />
              ))}
            </div>
          </div>
        )}

      </Container>
    </div>
  );
}
