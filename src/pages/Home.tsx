import React, { useEffect, useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { Compass, ShieldCheck, Heart, Map, Star, ArrowRight, Sparkles } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { PackageCard } from '../components/packages/PackageCard';
import { getFeaturedPackages } from '../services/packagesService';
import { getTestimonials } from '../services/testimonialsService';
import { getSiteContent } from '../services/siteContentService';

export default function Home() {
  const [featuredPackages, setFeaturedPackages] = useState<any[]>([]);
  const [testimonials, setTestimonials] = useState<any[]>([]);
  const [siteContent, setSiteContent] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [pkgs, tests, content] = await Promise.all([
          getFeaturedPackages(),
          getTestimonials(),
          getSiteContent()
        ]);
        setFeaturedPackages(pkgs || []);
        setTestimonials(tests?.slice(0, 3) || []);
        setSiteContent(content || {});
      } catch (error) {
        console.error('Error fetching home data:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const heroTitle = siteContent['hero_title'] || 'Your days in Sri Lanka, planned by locals.';
  const heroSubtitle = siteContent['hero_subtitle'] || 'Experience the vibrant culture, untamed wildlife, and pristine beaches of our island home.';
  const welcomeTitle = siteContent['welcome_title'] || 'Ayubowan! Welcome to Serendib Days.';
  const welcomeBody = siteContent['welcome_body'] || "We are a passionate team of local experts dedicated to showcasing the true magic of Sri Lanka. Whether you're seeking a short weekend getaway to ancient temples or a week-long adventure through the jungle, we curate unforgettable experiences tailored just for you. No hidden fees, just authentic journeys.";

  return (
    <div>
      <Helmet>
        <title>Serendib Days | Your days in Sri Lanka, planned by locals.</title>
        <meta name="description" content="Discover the best of Sri Lanka with our expertly crafted tour packages. Authentic, flexible, and unforgettable travel experiences." />
        <script type="application/ld+json">
          {`
            {
              "@context": "https://schema.org",
              "@type": "Organization",
              "name": "Serendib Days",
              "url": "https://serendibdays.com",
              "logo": "https://serendibdays.com/logo.png",
              "contactPoint": {
                "@type": "ContactPoint",
                "telephone": "${siteContent['contact_phone'] || '+94-77-123-4567'}",
                "contactType": "customer service"
              }
            }
          `}
        </script>
      </Helmet>

      {/* Hero Section */}
      <section className="relative h-[85vh] min-h-[620px] flex items-center">
        <div className="absolute inset-0 z-0 overflow-hidden">
          <img
            src="https://images.travelandleisureasia.com/wp-content/uploads/sites/2/2023/11/22123004/galle-fort.jpeg?tr=w-1920"
            alt="Sri Lanka Galle Fort & Coast"
            className="w-full h-full object-cover scale-105 animate-pulse duration-[10000ms]"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-slate-900/90 via-slate-900/40 to-slate-900/30"></div>
        </div>

        <Container className="relative z-10 text-center text-white pt-8">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/15 backdrop-blur-md border border-white/25 text-xs font-semibold text-white mb-6 uppercase tracking-wider">
            <Sparkles className="w-3.5 h-3.5 text-accent" />
            <span>Authentic Island Journeys</span>
          </div>

          <h1 className="font-serif text-4xl sm:text-5xl md:text-7xl font-bold mb-6 drop-shadow-lg leading-tight max-w-4xl mx-auto">
            {heroTitle}
          </h1>

          <p className="text-base sm:text-lg md:text-2xl mb-10 max-w-2xl mx-auto drop-shadow-md text-white/95 leading-relaxed">
            {heroSubtitle}
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button to="/packages" size="lg" className="w-full sm:w-auto shadow-xl hover:shadow-2xl hover:scale-105 transition-all text-base px-8 py-4">
              Explore 25 Packages
            </Button>
            <Button to="/contact" variant="outline" size="lg" className="w-full sm:w-auto bg-white/10 text-white border-white/80 hover:bg-white/20 hover:text-white backdrop-blur-md text-base px-8 py-4">
              Plan Custom Itinerary
            </Button>
          </div>
        </Container>
      </section>

      {/* Welcome / Story Section */}
      <section className="py-24 bg-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <Compass className="h-12 w-12 text-accent mx-auto mb-6" />
            <h2 className="font-serif text-3xl md:text-4xl font-bold text-slate-800 mb-6">{welcomeTitle}</h2>
            <p className="text-lg text-slate-600 leading-relaxed font-normal">
              {welcomeBody}
            </p>
          </div>
        </Container>
      </section>

      {/* Featured Packages Section */}
      <section className="py-24 bg-offwhite">
        <Container>
          <div className="flex flex-col md:flex-row justify-between items-start md:items-end mb-12 gap-4">
            <div>
              <div className="text-xs uppercase font-bold text-primary tracking-wider mb-2">Handpicked Itineraries</div>
              <h2 className="font-serif text-3xl md:text-4xl font-bold text-slate-800 mb-2">Featured Journeys</h2>
              <p className="text-slate-600">Our most celebrated routes handpicked for travelers seeking authentic beauty.</p>
            </div>
            <Link to="/packages" className="flex items-center gap-2 text-primary font-semibold hover:underline group">
              <span>View all 25 packages</span>
              <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[1, 2, 3].map(i => (
                <div key={i} className="animate-pulse bg-slate-200 rounded-2xl aspect-[3/4]"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {featuredPackages.map(pkg => (
                <PackageCard key={pkg.id} pkg={pkg} />
              ))}
            </div>
          )}

          <div className="mt-10 text-center md:hidden">
            <Button to="/packages" variant="outline" className="w-full">View all 25 packages</Button>
          </div>
        </Container>
      </section>

      {/* Why Serendib Days Section */}
      <section className="py-24 bg-primary text-white">
        <Container>
          <div className="text-center mb-16">
            <h2 className="font-serif text-3xl md:text-4xl font-bold mb-4">Why Serendib Days</h2>
            <p className="text-primary-100 max-w-2xl mx-auto text-lg">
              We do things differently to ensure you have an effortless, unforgettable holiday.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="bg-primary-800/40 p-8 rounded-2xl border border-primary-600/30 text-center hover:bg-primary-800/60 transition-colors">
              <div className="bg-primary-600 w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-md">
                <Map className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Local Guides</h3>
              <p className="text-primary-100 text-sm leading-relaxed">
                Travel with licensed chauffeur-guides who grew up here and know the island's best-kept secrets.
              </p>
            </div>

            <div className="bg-primary-800/40 p-8 rounded-2xl border border-primary-600/30 text-center hover:bg-primary-800/60 transition-colors">
              <div className="bg-primary-600 w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-md">
                <ShieldCheck className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Clear Prices</h3>
              <p className="text-primary-100 text-sm leading-relaxed">
                No hidden surprises. We offer transparent pricing across Essential, Comfort, and Signature tiers.
              </p>
            </div>

            <div className="bg-primary-800/40 p-8 rounded-2xl border border-primary-600/30 text-center hover:bg-primary-800/60 transition-colors">
              <div className="bg-primary-600 w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-md">
                <Heart className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Personal Service</h3>
              <p className="text-primary-100 text-sm leading-relaxed">
                24/7 dedicated concierge support throughout your journey, from landing until you fly home.
              </p>
            </div>

            <div className="bg-primary-800/40 p-8 rounded-2xl border border-primary-600/30 text-center hover:bg-primary-800/60 transition-colors">
              <div className="bg-primary-600 w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-md">
                <Compass className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Flexible Plans</h3>
              <p className="text-primary-100 text-sm leading-relaxed">
                Customize every single itinerary. Add nights, swap boutique hotels, or adjust the route completely.
              </p>
            </div>
          </div>
        </Container>
      </section>

      {/* Timeline Finder Section */}
      <section className="py-24 bg-white border-b border-slate-100">
        <Container>
          <div className="text-center mb-12">
            <h2 className="font-serif text-3xl md:text-4xl font-bold text-slate-800 mb-4">Find your perfect timeline</h2>
            <p className="text-slate-600 text-lg">From quick day trips to immersive multi-week grand island loops.</p>
          </div>

          <div className="flex flex-wrap justify-center gap-4">
            {[
              { duration: '1 Day', filter: '1' },
              { duration: '2 Days', filter: '2' },
              { duration: '3 Days', filter: '3' },
              { duration: '4 Days', filter: '4' },
              { duration: '5–7 Days', filter: '5-7' },
              { duration: '8+ Days', filter: '8+' },
            ].map(item => (
              <Link
                key={item.filter}
                to={`/packages?duration=${item.filter}`}
                className="px-8 py-5 bg-offwhite border border-slate-200 rounded-2xl hover:border-primary hover:bg-primary-50 hover:text-primary transition-all font-semibold text-slate-700 text-center hover:shadow-md hover:-translate-y-0.5"
              >
                {item.duration} Tours
              </Link>
            ))}
          </div>
        </Container>
      </section>

      {/* Testimonials Section */}
      <section className="py-24 bg-offwhite">
        <Container>
          <div className="text-center mb-16">
            <div className="text-xs uppercase font-bold text-primary tracking-wider mb-2">Verified Traveler Experiences</div>
            <h2 className="font-serif text-3xl md:text-4xl font-bold text-slate-800 mb-4">What Our Guests Say</h2>
            <p className="text-slate-600 max-w-xl mx-auto">
              Real stories from travelers who explored Sri Lanka with Serendib Days.
            </p>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[1, 2, 3].map(i => <div key={i} className="h-56 bg-slate-200 animate-pulse rounded-2xl"></div>)}
            </div>
          ) : testimonials.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {testimonials.map(t => (
                <div key={t.id} className="bg-white p-8 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow">
                  <div>
                    <div className="flex text-accent mb-4">
                      {[...Array(t.rating || 5)].map((_, i) => (
                        <Star key={i} className="h-5 w-5 fill-current" />
                      ))}
                    </div>
                    <p className="text-slate-700 italic mb-6 leading-relaxed text-sm">"{t.text}"</p>
                  </div>
                  <div className="pt-4 border-t border-slate-100">
                    <p className="font-bold text-slate-800">{t.name}</p>
                    <p className="text-xs text-slate-500 font-medium">{t.country}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Container>
      </section>

      {/* Ready to Plan CTA */}
      <section className="py-24 bg-white text-center border-t border-slate-100">
        <Container>
          <h2 className="font-serif text-3xl md:text-5xl font-bold text-slate-800 mb-6 max-w-3xl mx-auto">
            Ready to plan your unforgettable Sri Lankan adventure?
          </h2>
          <p className="text-lg text-slate-600 mb-10 max-w-2xl mx-auto leading-relaxed">
            Let us know your ideas, dates, and must-see destinations. We'll craft a customized itinerary that fits your dreams and budget within 24 hours.
          </p>
          <Button to="/contact" size="lg" className="text-lg px-10 py-4 shadow-xl hover:shadow-2xl">
            Start Planning With a Local
          </Button>
        </Container>
      </section>
    </div>
  );
}
