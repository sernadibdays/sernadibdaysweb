import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, MapPin, ArrowRight } from 'lucide-react';
import { formatCurrency } from '../../utils/currency';

interface PackageCardProps {
  pkg: any;
}

export const PackageCard: React.FC<PackageCardProps> = ({ pkg }) => {
  const startingPrice = pkg.package_tiers?.length > 0 
    ? Math.min(...pkg.package_tiers.map((t: any) => t.price_usd)) 
    : 0;

  const routeOrigin = (pkg.route.includes('→') 
    ? pkg.route.split('→')[0] 
    : pkg.route.split('-')[0]
  ).trim();

  return (
    <Link 
      to={`/packages/${pkg.slug}`} 
      className="group flex flex-col overflow-hidden rounded-2xl bg-white shadow-sm border border-slate-200 transition-all duration-300 hover:shadow-xl hover:-translate-y-1"
    >
      <div className="relative aspect-[16/11] overflow-hidden bg-slate-100">
        <img 
          src={pkg.cover_image} 
          alt={pkg.title} 
          className="h-full w-full object-cover transition-transform duration-700 ease-out group-hover:scale-105"
          onError={(e) => {
            (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=800&q=80';
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-slate-900/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
        
        <div className="absolute top-4 left-4 flex gap-2">
          <div className="rounded-full bg-slate-900/80 backdrop-blur-md px-3 py-1 text-xs font-bold text-white shadow-sm">
            {pkg.duration_days} {pkg.duration_days === 1 ? 'Day' : 'Days'}
          </div>
          {pkg.is_featured && (
            <div className="rounded-full bg-accent px-3 py-1 text-xs font-bold text-white shadow-sm">
              Featured
            </div>
          )}
        </div>

        {pkg.interests && pkg.interests.length > 0 && (
          <div className="absolute bottom-3 left-4 flex flex-wrap gap-1.5 opacity-90">
            {pkg.interests.slice(0, 2).map((interest: string) => (
              <span key={interest} className="text-[10px] uppercase font-semibold px-2 py-0.5 rounded bg-white/90 text-slate-800 backdrop-blur-sm">
                {interest}
              </span>
            ))}
          </div>
        )}
      </div>

      <div className="flex flex-1 flex-col p-6">
        <h3 className="font-serif text-xl font-bold text-slate-900 mb-2 leading-snug group-hover:text-primary transition-colors">
          {pkg.title}
        </h3>
        
        <p className="text-sm text-slate-600 mb-5 line-clamp-2 leading-relaxed">
          {pkg.short_description}
        </p>
        
        <div className="mt-auto space-y-4">
          <div className="flex items-center gap-4 text-xs font-medium text-slate-500">
            <div className="flex items-center gap-1.5 shrink-0">
              <Clock className="h-4 w-4 text-primary" />
              <span>{pkg.duration_days} {pkg.duration_days === 1 ? 'Day Trip' : 'Days Tour'}</span>
            </div>
            <div className="flex items-center gap-1.5 truncate">
              <MapPin className="h-4 w-4 text-primary shrink-0" />
              <span className="truncate">{routeOrigin} & beyond</span>
            </div>
          </div>
          
          <div className="border-t border-slate-100 pt-3 flex items-center justify-between">
            <div className="flex flex-col">
              <span className="text-[10px] text-slate-400 uppercase tracking-wider font-bold">Starting from</span>
              <span className="font-bold text-xl text-primary">{formatCurrency(startingPrice)}</span>
            </div>
            <span className="text-xs font-bold text-primary group-hover:translate-x-1 transition-transform flex items-center gap-1">
              <span>View details</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </span>
          </div>
        </div>
      </div>
    </Link>
  );
};
