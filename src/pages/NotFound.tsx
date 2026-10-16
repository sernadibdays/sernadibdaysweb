import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { Compass } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="py-32 bg-offwhite min-h-[70vh] flex items-center">
      <Helmet>
        <title>404 - Page Not Found | Serendib Days</title>
        <meta name="robots" content="noindex" />
      </Helmet>
      <Container className="text-center">
        <Compass className="h-20 w-20 text-slate-300 mx-auto mb-6" />
        <h1 className="font-serif text-5xl font-bold text-slate-800 mb-4">Lost your way?</h1>
        <p className="text-lg text-slate-600 mb-8">
          The page you are looking for doesn't exist or has been moved.
        </p>
        <Button to="/">Return Home</Button>
      </Container>
    </div>
  );
}
