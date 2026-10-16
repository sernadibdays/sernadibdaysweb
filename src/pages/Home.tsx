import React, { useEffect, useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { Link } from 'react-router-dom';
import { Compass, ShieldCheck, Heart, Map, Star, ArrowRight } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { PackageCard } from '../components/packages/PackageCard';
import { getFeaturedPackages } from '../services/packagesService';
import { getTestimonials } from '../services/testimonialsService';

export default function Home() {
  const [featuredPackages, setFeaturedPackages] = useState<any[]>([]);
  const [testimonials, setTestimonials] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [pkgs, tests] = await Promise.all([
          getFeaturedPackages(),
          getTestimonials()
        ]);
        setFeaturedPackages(pkgs || []);
        setTestimonials(tests?.slice(0, 3) || []);
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

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
                "telephone": "+94-77-123-4567",
                "contactType": "customer service"
              }
            }
          `}
        </script>
      </Helmet>

      <section className="relative h-[80vh] min-h-[600px] flex items-center">
        <div className="absolute inset-0 z-0">
          <img
            src="https://images.travelandleisureasia.com/wp-content/uploads/sites/2/2023/11/22123004/galle-fort.jpeg?tr=w-1920"
            alt="Sri Lanka Sigiriya"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-slate-900/40"></div>
        </div>
        <Container className="relative z-10 text-center text-white">
          <h1 className="font-serif text-5xl md:text-7xl font-bold mb-6 drop-shadow-lg">
            Your days in Sri Lanka, <br className="hidden md:block" /> planned by locals.
          </h1>
          <p className="text-lg md:text-2xl mb-10 max-w-2xl mx-auto drop-shadow">
            Experience the vibrant culture, untamed wildlife, and pristine beaches of our island home.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button to="/packages" size="lg" className="w-full sm:w-auto">View Packages</Button>
            <Button to="/contact" variant="outline" size="lg" className="w-full sm:w-auto bg-white/10 text-white border-white hover:bg-white/20 hover:text-white backdrop-blur-sm">Enquire Now</Button>
          </div>
        </Container>
      </section>

      <section className="py-20 bg-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <Compass className="h-12 w-12 text-accent mx-auto mb-6" />
            <h2 className="font-serif text-3xl md:text-4xl font-bold text-slate-800 mb-6">Ayubowan! Welcome to Serendib Days.</h2>
            <p className="text-lg text-slate-600 leading-relaxed">
              We are a passionate team of local experts dedicated to showcasing the true magic of Sri Lanka.
              Whether you're seeking a short weekend getaway to ancient temples or a week-long adventure through the jungle,
              we curate unforgettable experiences tailored just for you. No hidden fees, just authentic journeys.
            </p>
          </div>
        </Container>
      </section>

      <section className="py-20 bg-offwhite">
        <Container>
          <div className="flex justify-between items-end mb-12">
            <div>
              <h2 className="font-serif text-3xl font-bold text-slate-800 mb-2">Featured Journeys</h2>
              <p className="text-slate-600">Our most popular itineraries handpicked for you.</p>
            </div>
            <Link to="/packages" className="hidden md:flex items-center gap-2 text-primary font-medium hover:underline">
              View all <ArrowRight className="h-4 w-4" />
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[1, 2, 3].map(i => (
                <div key={i} className="animate-pulse bg-slate-200 rounded-xl aspect-[3/4]"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {featuredPackages.map(pkg => (
                <PackageCard key={pkg.id} pkg={pkg} />
              ))}
            </div>
          )}

          <div className="mt-8 text-center md:hidden">
            <Button to="/packages" variant="outline" className="w-full">View all packages</Button>
          </div>
        </Container>
      </section>

      <section className="py-20 bg-primary text-white">
        <Container>
          <div className="text-center mb-16">
            <h2 className="font-serif text-3xl md:text-4xl font-bold mb-4">Why Serendib Days</h2>
            <p className="text-primary-100 max-w-2xl mx-auto">We do things differently to ensure you have the best possible experience.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
            <div className="text-center">
              <div className="bg-primary-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                <Map className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Local Guides</h3>
              <p className="text-primary-100">Travel with experienced local experts who know the island's best-kept secrets.</p>
            </div>
            <div className="text-center">
              <div className="bg-primary-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                <ShieldCheck className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Clear Prices</h3>
              <p className="text-primary-100">No hidden fees. We provide transparent pricing across different tier options.</p>
            </div>
            <div className="text-center">
              <div className="bg-primary-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                <Heart className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Personal Service</h3>
              <p className="text-primary-100">24/7 support throughout your journey, from planning until you fly back home.</p>
            </div>
            <div className="text-center">
              <div className="bg-primary-600 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                <Compass className="h-8 w-8 text-white" />
              </div>
              <h3 className="font-bold text-xl mb-3">Flexible Plans</h3>
              <p className="text-primary-100">Customize any package. Add days, upgrade hotels, or change the route entirely.</p>
            </div>
          </div>
        </Container>
      </section>

      <section className="py-20 bg-white border-b border-slate-100">
        <Container>
          <div className="text-center mb-12">
            <h2 className="font-serif text-3xl font-bold text-slate-800 mb-4">Find your perfect timeline</h2>
            <p className="text-slate-600">From quick day trips to immersive week-long tours.</p>
          </div>

          <div className="flex flex-wrap justify-center gap-4">
            {['1 Day', '2 Days', '3 Days', '4 Days', '7 Days'].map(duration => (
              <Link
                key={duration}
                to={`/packages?duration=${duration.split(' ')[0]}`}
                className="px-6 py-4 bg-offwhite border border-slate-200 rounded-lg hover:border-primary hover:bg-primary-50 hover:text-primary transition-all font-medium text-slate-700 text-center"
              >
                {duration} Tours
              </Link>
            ))}
          </div>
        </Container>
      </section>

      <section className="py-20 bg-offwhite">
        <Container>
          <div className="text-center mb-16">
            <h2 className="font-serif text-3xl font-bold text-slate-800 mb-4">What Our Guests Say</h2>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {[1, 2, 3].map(i => <div key={i} className="h-48 bg-slate-200 animate-pulse rounded-xl"></div>)}
            </div>
          ) : testimonials.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {testimonials.map(t => (
                <div key={t.id} className="bg-white p-8 rounded-xl shadow-sm border border-slate-100">
                  <div className="flex text-accent mb-4">
                    {[...Array(t.rating)].map((_, i) => (
                      <Star key={i} className="h-5 w-5 fill-current" />
                    ))}
                  </div>
                  <p className="text-slate-600 italic mb-6">"{t.text}"</p>
                  <div>
                    <p className="font-bold text-slate-800">{t.name}</p>
                    <p className="text-sm text-slate-500">{t.country}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Container>
      </section>

      <section className="py-24 bg-white text-center">
        <Container>
          <h2 className="font-serif text-4xl font-bold text-slate-800 mb-6">Ready to plan your Sri Lankan adventure?</h2>
          <p className="text-lg text-slate-600 mb-10 max-w-2xl mx-auto">
            Let us know your ideas, and we'll craft a personalized itinerary that fits your dreams and budget.
          </p>
          <Button to="/contact" size="lg" className="text-lg px-10">Start Planning</Button>
        </Container>
      </section>
    </div>
  );
}
