import React from 'react';
import { Link } from 'react-router-dom';
import { Compass, Mail, MapPin, Phone } from 'lucide-react';
import { Container } from '../ui/Container';

export const Footer = () => {
  return (
    <footer className="bg-slate-900 text-slate-300 py-12 mt-auto">
      <Container>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="space-y-4">
            <Link to="/" className="flex items-center gap-2 text-white">
              <Compass className="h-8 w-8" />
              <span className="font-serif text-2xl font-bold">Serendib Days</span>
            </Link>
            <p className="text-sm">Your days in Sri Lanka, planned by locals. Authentic, flexible, and unforgettable travel experiences.</p>
          </div>
          
          <div>
            <h3 className="text-white font-semibold mb-4">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li><Link to="/packages" className="hover:text-white transition-colors">Tour Packages</Link></li>
              <li><Link to="/about" className="hover:text-white transition-colors">About Us</Link></li>
              <li><Link to="/faq" className="hover:text-white transition-colors">FAQs</Link></li>
              <li><Link to="/contact" className="hover:text-white transition-colors">Contact</Link></li>
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold mb-4">Legal</h3>
            <ul className="space-y-2 text-sm">
              <li><Link to="/terms" className="hover:text-white transition-colors">Terms & Conditions</Link></li>
              <li><Link to="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link></li>
            </ul>
          </div>

          <div>
            <h3 className="text-white font-semibold mb-4">Contact</h3>
            <ul className="space-y-3 text-sm">
              <li className="flex items-start gap-3">
                <MapPin className="h-5 w-5 shrink-0" />
                <span>Colombo, Sri Lanka</span>
              </li>
              <li className="flex items-center gap-3">
                <Phone className="h-5 w-5 shrink-0" />
                <span>+94 77 123 4567</span>
              </li>
              <li className="flex items-center gap-3">
                <Mail className="h-5 w-5 shrink-0" />
                <span>hello@serendibdays.com</span>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-12 pt-8 border-t border-slate-800 text-center text-sm">
          <p>&copy; {new Date().getFullYear()} Serendib Days. All rights reserved.</p>
        </div>
      </Container>
    </footer>
  );
};
