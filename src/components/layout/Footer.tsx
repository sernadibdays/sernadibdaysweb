import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Compass, Mail, MapPin, Phone, Lock, Heart } from 'lucide-react';
import { Container } from '../ui/Container';
import { getSiteContent } from '../../services/siteContentService';

export const Footer = () => {
  const [content, setContent] = useState<Record<string, string>>({});

  useEffect(() => {
    getSiteContent().then(setContent).catch(console.error);
  }, []);

  const phone = content['contact_phone'] || '+94 77 123 4567';
  const email = content['contact_email'] || 'hello@serendibdays.com';
  const address = content['contact_address'] || 'Colombo, Sri Lanka';

  return (
    <footer className="bg-slate-900 text-slate-300 py-16 mt-auto border-t border-slate-800">
      <Container>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10">
          <div className="space-y-4">
            <Link to="/" className="flex items-center gap-2 text-white">
              <Compass className="h-8 w-8 text-accent" />
              <span className="font-serif text-2xl font-bold tracking-tight">Serendib Days</span>
            </Link>
            <p className="text-sm text-slate-400 leading-relaxed">
              Your days in Sri Lanka, planned by locals. Authentic, flexible, and unforgettable travel experiences tailored to your dreams.
            </p>
            <div className="pt-2 text-xs text-slate-500 flex items-center gap-1.5">
              <span>Crafted with</span>
              <Heart className="w-3.5 h-3.5 text-accent fill-accent" />
              <span>in Sri Lanka</span>
            </div>
          </div>
          
          <div>
            <h3 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Explore</h3>
            <ul className="space-y-2.5 text-sm">
              <li><Link to="/packages" className="text-slate-400 hover:text-white transition-colors">All Tour Packages</Link></li>
              <li><Link to="/packages?duration=1" className="text-slate-400 hover:text-white transition-colors">Day Tours & Excursions</Link></li>
              <li><Link to="/packages?duration=5-7" className="text-slate-400 hover:text-white transition-colors">Week-long Highlights</Link></li>
              <li><Link to="/about" className="text-slate-400 hover:text-white transition-colors">About Our Story</Link></li>
              <li><Link to="/faq" className="text-slate-400 hover:text-white transition-colors">Frequently Asked Questions</Link></li>
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Assistance & Legal</h3>
            <ul className="space-y-2.5 text-sm">
              <li><Link to="/contact" className="text-slate-400 hover:text-white transition-colors">Plan Your Custom Trip</Link></li>
              <li><Link to="/terms" className="text-slate-400 hover:text-white transition-colors">Terms & Conditions</Link></li>
              <li><Link to="/privacy" className="text-slate-400 hover:text-white transition-colors">Privacy Policy</Link></li>
              <li>
                <Link to="/admin" className="text-slate-500 hover:text-slate-300 transition-colors flex items-center gap-1.5 text-xs pt-2">
                  <Lock className="w-3 h-3 text-slate-500" />
                  <span>Admin Portal</span>
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Contact Us</h3>
            <ul className="space-y-3 text-sm">
              <li className="flex items-start gap-3 text-slate-400">
                <MapPin className="h-5 w-5 shrink-0 text-accent" />
                <span>{address}</span>
              </li>
              <li className="flex items-center gap-3 text-slate-400">
                <Phone className="h-5 w-5 shrink-0 text-accent" />
                <span>{phone}</span>
              </li>
              <li className="flex items-center gap-3 text-slate-400">
                <Mail className="h-5 w-5 shrink-0 text-accent" />
                <span>{email}</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-14 pt-8 border-t border-slate-800 flex flex-col sm:flex-row items-center justify-between text-xs text-slate-500 gap-4">
          <p>&copy; {new Date().getFullYear()} Serendib Days. All rights reserved.</p>
          <p>Authentic bespoke travel across Sri Lanka.</p>
        </div>
      </Container>
    </footer>
  );
};
