import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, MapPin } from 'lucide-react';
import { formatCurrency } from '../../utils/currency';

interface PackageCardProps {
  pkg: any;
}

export const PackageCard: React.FC<PackageCardProps> = ({ pkg }) => {
  const startingPrice = pkg.package_tiers?.length > 0 
    ? Math.min(...pkg.package_tiers.map((t: any) => t.price_usd)) 
    : 0;

  return (
    <Link to={`/packages/${pkg.slug}`} className="group flex flex-col overflow-hidden rounded-xl bg-white shadow-md transition-all hover:shadow-xl hover:-translate-y-1">
      <div className="relative aspect-[4/3] overflow-hidden">
        <img 
          src={pkg.cover_image} 
          alt={pkg.title} 
          className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        {pkg.is_featured && (
          <div className="absolute top-4 left-4 rounded-full bg-accent px-3 py-1 text-xs font-bold text-white shadow-sm">
            Featured
          </div>
        )}
      </div>
      <div className="flex flex-1 flex-col p-6">
        <h3 className="font-serif text-xl font-bold text-slate-800 mb-2">{pkg.title}</h3>
        <p className="text-sm text-slate-600 mb-4 line-clamp-2">{pkg.short_description}</p>
        
        <div className="mt-auto space-y-3">
          <div className="flex items-center gap-4 text-sm text-slate-500">
            <div className="flex items-center gap-1">
              <Clock className="h-4 w-4" />
              <span>{pkg.duration_days} {pkg.duration_days === 1 ? 'Day' : 'Days'}</span>
            </div>
            <div className="flex items-center gap-1 truncate">
              <MapPin className="h-4 w-4" />
              <span className="truncate">{pkg.route.split('-')[0].trim()}...</span>
            </div>
          </div>
          
          <div className="border-t pt-3 flex items-center justify-between">
            <div className="flex flex-col">
              <span className="text-xs text-slate-500 uppercase tracking-wider font-semibold">From</span>
              <span className="font-bold text-lg text-primary">{formatCurrency(startingPrice)}</span>
            </div>
            <span className="text-sm font-medium text-primary group-hover:underline">View details</span>
          </div>
        </div>
      </div>
    </Link>
  );
};
