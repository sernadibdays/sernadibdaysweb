import React, { useEffect, useState, useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { Filter, X, Search, ArrowUpDown, Compass } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { PackageCard } from '../components/packages/PackageCard';
import { getPackages } from '../services/packagesService';
import type { Package } from '../types/database';

const DURATIONS = [
  { id: 'all', label: 'All Durations' },
  { id: '1', label: '1 Day' },
  { id: '2', label: '2 Days' },
  { id: '3', label: '3 Days' },
  { id: '4', label: '4 Days' },
  { id: '5-7', label: '5–7 Days' },
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
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'recommended' | 'price-asc' | 'price-desc' | 'duration-asc' | 'duration-desc'>('recommended');

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
    const result = packages.filter(pkg => {
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
        matchInterest = pkg.interests?.includes(interestFilter) ?? false;
      }

      let matchSearch = true;
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        matchSearch = pkg.title.toLowerCase().includes(q) ||
                      pkg.route.toLowerCase().includes(q) ||
                      pkg.short_description.toLowerCase().includes(q);
      }

      return matchDuration && matchInterest && matchSearch;
    });

    // Sorting
    return result.sort((a, b) => {
      const minA = a.package_tiers?.length ? Math.min(...a.package_tiers.map(t => t.price_usd)) : 0;
      const minB = b.package_tiers?.length ? Math.min(...b.package_tiers.map(t => t.price_usd)) : 0;

      if (sortBy === 'price-asc') return minA - minB;
      if (sortBy === 'price-desc') return minB - minA;
      if (sortBy === 'duration-asc') return a.duration_days - b.duration_days;
      if (sortBy === 'duration-desc') return b.duration_days - a.duration_days;
      // Default: recommended sort_order with featured first
      if (a.is_featured && !b.is_featured) return -1;
      if (!a.is_featured && b.is_featured) return 1;
      return a.sort_order - b.sort_order;
    });
  }, [packages, durationFilter, interestFilter, searchQuery, sortBy]);

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
    setSearchQuery('');
    setSortBy('recommended');
    setSearchParams({});
  };

  const activeFiltersCount = (durationFilter !== 'all' ? 1 : 0) + (interestFilter !== 'all' ? 1 : 0) + (searchQuery.trim() ? 1 : 0);

  return (
    <div className="py-16 bg-slate-50 min-h-screen">
      <Helmet>
        <title>All Tour Packages | Serendib Days</title>
        <meta name="description" content="Explore all 25 flexible Sri Lanka tour packages. From single-day excursions to comprehensive 14-day island loops." />
      </Helmet>

      <Container>
        <div className="mb-12 text-center max-w-3xl mx-auto">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-bold uppercase tracking-wider mb-4">
            <Compass className="w-4 h-4" />
            <span>25 Handcrafted Itineraries</span>
          </div>
          <h1 className="font-serif text-4xl md:text-5xl font-bold text-slate-900 mb-4 tracking-tight">Craft Your Journey</h1>
          <p className="text-lg text-slate-600 leading-relaxed">
            Discover the perfect route for your holiday duration and travel style. Every package is fully customizable to your pace and preferences.
          </p>
        </div>

        {/* Refined Search & Filter Card */}
        <div className="bg-white p-6 md:p-8 rounded-3xl shadow-sm border border-slate-200 mb-12 space-y-6">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 border-b border-slate-100 pb-5">
            <div className="relative w-full sm:max-w-md">
              <Search className="w-5 h-5 absolute left-3.5 top-3 text-slate-400" />
              <input 
                type="text"
                placeholder="Search by destination (e.g. Sigiriya, Galle, Ella)..."
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
                className="w-full pl-11 pr-4 py-2.5 rounded-2xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent text-sm"
              />
              {searchQuery && (
                <button onClick={() => setSearchQuery('')} className="absolute right-3 top-3 text-slate-400 hover:text-slate-600">
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>

            <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
              <div className="flex items-center gap-2 text-xs font-semibold text-slate-500">
                <ArrowUpDown className="w-4 h-4 text-slate-400" />
                <span>Sort by:</span>
                <select 
                  value={sortBy}
                  onChange={e => setSortBy(e.target.value as any)}
                  className="px-3 py-1.5 rounded-xl border border-slate-200 bg-slate-50 text-slate-800 text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="recommended">Featured / Recommended</option>
                  <option value="price-asc">Price: Low to High</option>
                  <option value="price-desc">Price: High to Low</option>
                  <option value="duration-asc">Duration: Shortest First</option>
                  <option value="duration-desc">Duration: Longest First</option>
                </select>
              </div>

              {activeFiltersCount > 0 && (
                <button 
                  onClick={clearFilters}
                  className="text-xs flex items-center gap-1 text-slate-500 hover:text-red-500 transition-colors font-medium px-2 py-1 rounded-lg hover:bg-slate-100"
                >
                  <X className="h-3.5 w-3.5" />
                  <span>Clear filters</span>
                </button>
              )}
            </div>
          </div>
          
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Durations Filter */}
            <div>
              <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2.5">Filter by Duration</h3>
              <div className="flex flex-wrap gap-2">
                {DURATIONS.map(duration => (
                  <button
                    key={duration.id}
                    onClick={() => handleDurationChange(duration.id)}
                    className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all duration-200 ${
                      durationFilter === duration.id
                        ? 'bg-primary text-white shadow-md shadow-primary/20 scale-105'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200 hover:text-slate-900'
                    }`}
                  >
                    {duration.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Interests Filter */}
            <div>
              <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2.5">Filter by Interest</h3>
              <div className="flex flex-wrap gap-2">
                {INTERESTS.map(interest => (
                  <button
                    key={interest.id}
                    onClick={() => handleInterestChange(interest.id)}
                    className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all duration-200 ${
                      interestFilter === interest.id
                        ? 'bg-primary text-white shadow-md shadow-primary/20 scale-105'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200 hover:text-slate-900'
                    }`}
                  >
                    {interest.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Results Count Banner */}
        <div className="mb-6 flex justify-between items-center text-sm text-slate-500">
          <div>
            Showing <strong className="text-slate-900">{filteredPackages.length}</strong> {filteredPackages.length === 1 ? 'package' : 'packages'}
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
          <div className="bg-white rounded-3xl border border-slate-200 p-16 text-center shadow-sm">
            <div className="bg-slate-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Filter className="h-8 w-8 text-slate-400" />
            </div>
            <h3 className="text-2xl font-bold text-slate-800 mb-2">No itineraries matching criteria</h3>
            <p className="text-slate-500 mb-8 max-w-md mx-auto text-sm">
              We couldn't find an itinerary matching this exact combination, but we can easily craft a customized tour for your dates and interests.
            </p>
            <button 
              onClick={clearFilters}
              className="bg-primary hover:bg-primary/90 text-white font-semibold px-6 py-3 rounded-full transition-colors text-sm shadow-md"
            >
              Reset Filters & Show All
            </button>
          </div>
        )}
      </Container>
    </div>
  );
}
