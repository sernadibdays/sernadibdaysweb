import React, { useEffect, useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { Clock, MapPin, Calendar, Check, X, Info, ArrowLeft } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { getPackageBySlug } from '../services/packagesService';
import { formatCurrency } from '../utils/currency';

export default function PackageDetail() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [pkg, setPkg] = useState<any>(null);
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
      <div className="min-h-screen pt-20 flex justify-center bg-offwhite">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      </div>
    );
  }

  if (error || !pkg) {
    return (
      <div className="min-h-screen py-20 bg-offwhite text-center">
        <Container>
          <h2 className="text-3xl font-bold mb-4">Package not found</h2>
          <p className="text-slate-600 mb-8">The package you're looking for doesn't exist or is currently unavailable.</p>
          <Button to="/packages">View all packages</Button>
        </Container>
      </div>
    );
  }

  return (
    <div className="bg-offwhite pb-20">
      <Helmet>
        <title>{`${pkg.title} | Serendib Days`}</title>
        <meta name="description" content={pkg.short_description} />
        <script type="application/ld+json">
          {`
            {
              "@context": "https://schema.org",
              "@type": "TouristTrip",
              "name": "${pkg.title}",
              "description": "${pkg.short_description}",
              "touristType": [
                ${pkg.interests.map((i: string) => `"${i}"`).join(', ')}
              ],
              "provider": {
                "@type": "Organization",
                "name": "Serendib Days"
              }
            }
          `}
        </script>
      </Helmet>

      <div className="relative h-[50vh] min-h-[400px]">
        <img 
          src={pkg.cover_image} 
          alt={pkg.title} 
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-slate-900/80 to-transparent"></div>
        <Container className="absolute bottom-0 left-0 right-0 p-8 text-white z-10">
          <Link to="/packages" className="inline-flex items-center gap-2 text-white/80 hover:text-white mb-4 text-sm font-medium">
            <ArrowLeft className="h-4 w-4" /> Back to Packages
          </Link>
          <h1 className="font-serif text-4xl md:text-5xl font-bold mb-4">{pkg.title}</h1>
          <div className="flex flex-wrap gap-6 text-sm font-medium">
            <div className="flex items-center gap-2">
              <Clock className="h-5 w-5 text-accent" />
              <span>{pkg.duration_days} {pkg.duration_days === 1 ? 'Day' : 'Days'}</span>
            </div>
            <div className="flex items-center gap-2">
              <MapPin className="h-5 w-5 text-accent" />
              <span>{pkg.route}</span>
            </div>
            <div className="flex items-center gap-2">
              <Calendar className="h-5 w-5 text-accent" />
              <span>Best time: {pkg.best_time}</span>
            </div>
          </div>
        </Container>
      </div>

      <Container className="mt-12">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
          <div className="lg:col-span-2 space-y-12">
            <section className="bg-white p-8 rounded-xl shadow-sm border border-slate-100">
              <h2 className="font-serif text-2xl font-bold text-slate-800 mb-4">Overview</h2>
              <p className="text-slate-600 leading-relaxed whitespace-pre-line">{pkg.description}</p>
            </section>

            {pkg.itinerary_days && pkg.itinerary_days.length > 0 && (
              <section className="bg-white p-8 rounded-xl shadow-sm border border-slate-100">
                <h2 className="font-serif text-2xl font-bold text-slate-800 mb-6">Itinerary</h2>
                <div className="space-y-8">
                  {pkg.itinerary_days.map((day: any) => (
                    <div key={day.id} className="relative pl-8 border-l-2 border-primary-100 last:border-transparent">
                      <div className="absolute -left-[9px] top-0 h-4 w-4 rounded-full bg-primary border-4 border-white shadow-sm"></div>
                      <div className="mb-1 text-sm font-bold text-primary uppercase tracking-wide">
                        Day {day.day_number}: {day.overnight_location !== 'Not applicable' && day.overnight_location !== 'Not applicable (Day Tour)' ? `Stay in ${day.overnight_location}` : 'Day Tour'}
                      </div>
                      <h3 className="font-serif text-xl font-bold text-slate-800 mb-2">{day.title}</h3>
                      <p className="text-slate-600">{day.description}</p>
                    </div>
                  ))}
                </div>
              </section>
            )}

            <section className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-white p-8 rounded-xl shadow-sm border border-slate-100">
                <h3 className="font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <Check className="h-5 w-5 text-green-500" /> What's Included
                </h3>
                <ul className="space-y-3">
                  {pkg.inclusions && pkg.inclusions.length > 0 ? (
                    pkg.inclusions.map((item: string, i: number) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-slate-600">
                        <span className="text-green-500 mt-1">•</span> {item}
                      </li>
                    ))
                  ) : (
                    <li className="text-sm text-slate-600">Transport, accommodation, and local taxes. (Specific details on request)</li>
                  )}
                </ul>
              </div>
              <div className="bg-white p-8 rounded-xl shadow-sm border border-slate-100">
                <h3 className="font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <X className="h-5 w-5 text-red-500" /> Not Included
                </h3>
                <ul className="space-y-3">
                  {pkg.exclusions && pkg.exclusions.length > 0 ? (
                    pkg.exclusions.map((item: string, i: number) => (
                      <li key={i} className="flex items-start gap-2 text-sm text-slate-600">
                        <span className="text-red-500 mt-1">•</span> {item}
                      </li>
                    ))
                  ) : (
                    <li className="text-sm text-slate-600">International flights, visas, and personal expenses.</li>
                  )}
                </ul>
              </div>
            </section>

            {pkg.notes && (
              <section className="bg-primary-50 p-6 rounded-xl border border-primary-100 text-sm text-primary-900 flex gap-4">
                <Info className="h-6 w-6 shrink-0 text-primary" />
                <div>
                  <h4 className="font-bold mb-1 text-primary">Important Note</h4>
                  <p>{pkg.notes}</p>
                </div>
              </section>
            )}
          </div>

          <div className="lg:col-span-1">
            <div className="sticky top-24 space-y-6">
              
              <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                <div className="bg-primary p-6 text-white text-center">
                  <h3 className="font-serif text-2xl font-bold">Pricing Options</h3>
                  <p className="text-primary-100 text-sm mt-1">Per person sharing a double room</p>
                </div>
                
                <div className="p-2">
                  {pkg.package_tiers && pkg.package_tiers.map((tier: any) => (
                    <div key={tier.id} className="p-4 border-b last:border-b-0 border-slate-100">
                      <div className="flex justify-between items-center mb-2">
                        <h4 className="font-bold text-slate-800 capitalize">{tier.tier}</h4>
                        <span className="font-bold text-lg text-primary">{formatCurrency(tier.price_usd)}</span>
                      </div>
                      <div className="space-y-2 text-sm text-slate-600 mt-3">
                        <p><strong className="text-slate-700">Stay:</strong> {tier.stay_details}</p>
                        <p><strong className="text-slate-700">Transport:</strong> {tier.transport_details}</p>
                        {tier.extras && tier.extras !== 'None' && <p><strong className="text-slate-700">Extras:</strong> {tier.extras}</p>}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-100 text-center">
                <h3 className="font-bold text-slate-800 mb-2">Ready to book this trip?</h3>
                <p className="text-sm text-slate-600 mb-6">
                  Send us an enquiry. We will get back to you within 24 hours with a personalized quote.
                </p>
                <Button 
                  onClick={() => navigate(`/contact?package=${pkg.id}`)}
                  className="w-full"
                >
                  Enquire About This Package
                </Button>
              </div>

            </div>
          </div>

        </div>
      </Container>
    </div>
  );
}
