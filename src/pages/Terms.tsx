import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Container } from '../components/ui/Container';

export default function Terms() {
  return (
    <div className="py-20 bg-white min-h-screen">
      <Helmet>
        <title>Terms & Conditions | Serendib Days</title>
        <meta name="robots" content="noindex" />
      </Helmet>
      <Container className="max-w-3xl">
        <h1 className="font-serif text-4xl font-bold text-slate-800 mb-8">Terms & Conditions</h1>
        <div className="prose prose-slate">
          <p className="text-slate-500 mb-8 italic">[This is placeholder text. Please update with legally binding terms before launch.]</p>
          <p>By booking a tour with Serendib Days, you agree to the following terms and conditions.</p>
          <h2>Booking and Payments</h2>
          <p>A deposit is required to confirm your booking. The remaining balance must be paid before or upon arrival in Sri Lanka.</p>
          <h2>Cancellations</h2>
          <p>Cancellations made 30 days prior to arrival are eligible for a partial refund. Cancellations made within 14 days of arrival are non-refundable.</p>
        </div>
      </Container>
    </div>
  );
}
