import React, { useEffect, useState, useMemo } from 'react';
import { Helmet } from 'react-helmet-async';
import { useSearchParams } from 'react-router-dom';
import { Filter, X } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { PackageCard } from '../components/packages/PackageCard';
import { getPackages } from '../services/packagesService';
import type { Package } from '../types/database';

const DURATIONS = [
  { id: 'all', label: 'Any Duration' },
  { id: '1', label: '1 Day' },
  { id: '2', label: '2 Days' },
  { id: '3', label: '3 Days' },
  { id: '4', label: '4 Days' },
  { id: '5-7', label: '5 to 7 Days' },
  { id: '8+', label: '8+ Days' }
];

const INTERESTS = [
  { id: 'all', label: 'All Interests' },
  { id: 'Culture & Heritage', label: 'Culture & Heritage' },
  { id: 'Wildlife', label: 'Wildlife' },
  { id: 'Beaches', label: 'Beaches' },
  { id: 'Hill Country', label: 'Hill Country' },
  { id: 'Adventure', label: 'Adventure' }
];

export default function Packages() {
  const [searchParams, setSearchParams] = useSearchParams();
  const initialDuration = searchParams.get('duration') || 'all';
  const initialInterest = searchParams.get('interest') || 'all';

  const [packages, setPackages] = useState<Package[]>([]);
  const [loading, setLoading] = useState(true);
  const [durationFilter, setDurationFilter] = useState(initialDuration);
  const [interestFilter, setInterestFilter] = useState(initialInterest);

  useEffect(() => {
    const fetchPkgs = async () => {
      try {
        setLoading(true);
        const data = await getPackages();
        setPackages(data || []);
      } catch (error) {
        console.error('Error fetching packages', error);
      } finally {
        setLoading(false);
      }
    };
    fetchPkgs();
  }, []);

  const filteredPackages = useMemo(() => {
    return packages.filter(pkg => {
      let matchDuration = true;
      if (durationFilter !== 'all') {
        if (durationFilter === '1') matchDuration = pkg.duration_days === 1;
        else if (durationFilter === '2') matchDuration = pkg.duration_days === 2;
        else if (durationFilter === '3') matchDuration = pkg.duration_days === 3;
        else if (durationFilter === '4') matchDuration = pkg.duration_days === 4;
        else if (durationFilter === '5-7') matchDuration = pkg.duration_days >= 5 && pkg.duration_days <= 7;
        else if (durationFilter === '8+') matchDuration = pkg.duration_days >= 8;
      }

      let matchInterest = true;
      if (interestFilter !== 'all') {
        // The DB interests are exactly 'Culture & Heritage', 'Wildlife', etc.
        matchInterest = pkg.interests?.includes(interestFilter) ?? false;
      }

      return matchDuration && matchInterest;
    });
  }, [packages, durationFilter, interestFilter]);

  const handleDurationChange = (value: string) => {
    setDurationFilter(value);
    setSearchParams(prev => {
      if (value === 'all') prev.delete('duration');
      else prev.set('duration', value);
      return prev;
    });
  };

  const handleInterestChange = (value: string) => {
    setInterestFilter(value);
    setSearchParams(prev => {
      if (value === 'all') prev.delete('interest');
      else prev.set('interest', value);
      return prev;
    });
  };

  const clearFilters = () => {
    setDurationFilter('all');
    setInterestFilter('all');
    setSearchParams({});
  };

  const activeFiltersCount = (durationFilter !== 'all' ? 1 : 0) + (interestFilter !== 'all' ? 1 : 0);

  return (
    <div className="py-12 bg-slate-50 min-h-screen">
      <Helmet>
        <title>Tour Packages | Serendib Days</title>
        <meta name="description" content="Explore our flexible Sri Lanka tour packages. From single day trips to week-long adventures." />
      </Helmet>

      <Container>
        <div className="mb-12 text-center">
          <h1 className="font-serif text-4xl md:text-5xl font-bold text-slate-800 mb-4">Craft Your Journey</h1>
          <p className="text-lg text-slate-600 max-w-2xl mx-auto">
            Discover the perfect journey for your time and interests. Every package can be customized to your exact requirements.
          </p>
        </div>

        {/* Premium Filtering Section */}
        <div className="bg-white p-6 md:p-8 rounded-2xl shadow-sm border border-slate-200 mb-10">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-2 text-slate-800 font-bold text-lg">
              <Filter className="h-5 w-5 text-primary" />
              <span>Filter Packages</span>
              {activeFiltersCount > 0 && (
                <span className="bg-primary text-white text-xs font-bold px-2 py-0.5 rounded-full ml-2">
                  {activeFiltersCount}
                </span>
              )}
            </div>
            {activeFiltersCount > 0 && (
              <button 
                onClick={clearFilters}
                className="text-sm flex items-center gap-1 text-slate-500 hover:text-red-500 transition-colors font-medium"
              >
                <X className="h-4 w-4" />
                Clear all
              </button>
            )}
          </div>
          
          <div className="flex flex-col xl:flex-row gap-8 xl:gap-12">
            {/* Interests Filter */}
            <div className="flex-1">
              <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-3">Interests</h3>
              <div className="flex flex-wrap gap-2">
                {INTERESTS.map(interest => (
                  <button
                    key={interest.id}
                    onClick={() => handleInterestChange(interest.id)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                      interestFilter === interest.id
                        ? 'bg-primary text-white shadow-md shadow-primary/20 scale-105'
                        : 'bg-slate-100 text-slate-700 hover:bg-slate-200 hover:text-slate-900'
                    }`}
                  >
                    {interest.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Durations Filter */}
            <div className="flex-1">
              <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-3">Duration</h3>
              <div className="flex flex-wrap gap-2">
                {DURATIONS.map(duration => (
                  <button
                    key={duration.id}
                    onClick={() => handleDurationChange(duration.id)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                      durationFilter === duration.id
                        ? 'bg-primary text-white shadow-md shadow-primary/20 scale-105'
                        : 'bg-slate-100 text-slate-700 hover:bg-slate-200 hover:text-slate-900'
                    }`}
                  >
                    {duration.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Results Section */}
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1,2,3,4,5,6].map(i => <div key={i} className="animate-pulse bg-slate-200 rounded-2xl aspect-[3/4]"></div>)}
          </div>
        ) : filteredPackages.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredPackages.map(pkg => (
              <PackageCard key={pkg.id} pkg={pkg} />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-2xl border border-slate-200 p-16 text-center shadow-sm">
            <div className="bg-slate-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Filter className="h-8 w-8 text-slate-400" />
            </div>
            <h3 className="text-2xl font-bold text-slate-800 mb-2">No packages found</h3>
            <p className="text-slate-500 mb-8 max-w-md mx-auto">
              We couldn't find any itineraries matching exactly these requirements, but we can custom-build one for you.
            </p>
            <button 
              onClick={clearFilters}
              className="bg-primary hover:bg-primary/90 text-white font-medium px-6 py-3 rounded-full transition-colors"
            >
              Show all packages
            </button>
          </div>
        )}
      </Container>
    </div>
  );
}
