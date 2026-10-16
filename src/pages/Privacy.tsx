import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Container } from '../components/ui/Container';

export default function Privacy() {
  return (
    <div className="py-20 bg-white min-h-screen">
      <Helmet>
        <title>Privacy Policy | Serendib Days</title>
        <meta name="robots" content="noindex" />
      </Helmet>
      <Container className="max-w-3xl">
        <h1 className="font-serif text-4xl font-bold text-slate-800 mb-8">Privacy Policy</h1>
        <div className="prose prose-slate">
          <p className="text-slate-500 mb-8 italic">[This is placeholder text. Please update with a legally binding privacy policy before launch.]</p>
          <p>We respect your privacy. Any information you provide through our contact forms is used solely to respond to your enquiry and plan your travel arrangements.</p>
          <p>We do not sell, rent, or share your personal information with third parties for marketing purposes.</p>
          <h2>Data Collection</h2>
          <p>When you submit an enquiry, we collect your name, email, phone number, and travel preferences to provide you with an accurate quote and itinerary.</p>
        </div>
      </Container>
    </div>
  );
}
