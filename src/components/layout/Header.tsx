import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Menu, X, Compass } from 'lucide-react';
import { Button } from '../ui/Button';
import { Container } from '../ui/Container';

export const Header = () => {
  const [isOpen, setIsOpen] = useState(false);

  const navLinks = [
    { name: 'Home', path: '/' },
    { name: 'Packages', path: '/packages' },
    { name: 'About', path: '/about' },
    { name: 'FAQ', path: '/faq' },
  ];

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/80 backdrop-blur-md">
      <Container>
        <div className="flex h-20 items-center justify-between">
          <Link to="/" className="flex items-center gap-2">
            <Compass className="h-8 w-8 text-primary" />
            <span className="font-serif text-2xl font-bold text-primary">Serendib Days</span>
          </Link>

          <nav className="hidden md:flex items-center gap-8">
            {navLinks.map((link) => (
              <Link key={link.path} to={link.path} className="text-sm font-medium text-slate-600 hover:text-primary transition-colors">
                {link.name}
              </Link>
            ))}
            <Button to="/contact" variant="primary">Enquire Now</Button>
          </nav>

          <button className="md:hidden p-2 text-slate-600" onClick={() => setIsOpen(!isOpen)} aria-label="Toggle menu">
            {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>
        </div>
      </Container>

      {isOpen && (
        <div className="md:hidden border-t bg-white">
          <div className="space-y-1 px-4 pb-4 pt-2">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className="block rounded-md px-3 py-2 text-base font-medium text-slate-700 hover:bg-slate-50 hover:text-primary"
                onClick={() => setIsOpen(false)}
              >
                {link.name}
              </Link>
            ))}
            <div className="mt-4 px-3">
              <Button to="/contact" className="w-full" onClick={() => setIsOpen(false)}>Enquire Now</Button>
            </div>
          </div>
        </div>
      )}
    </header>
  );
};
