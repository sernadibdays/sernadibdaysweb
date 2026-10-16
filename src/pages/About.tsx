import React from 'react';
import { Helmet } from 'react-helmet-async';
import { Container } from '../components/ui/Container';
import { Compass, Users, Leaf, ShieldCheck } from 'lucide-react';

export default function About() {
  return (
    <div className="py-20 bg-offwhite min-h-screen">
      <Helmet>
        <title>About Us | Serendib Days</title>
        <meta name="description" content="Learn about Serendib Days, a passionate team of local Sri Lankan guides dedicated to authentic travel." />
      </Helmet>
      
      <Container>
        <div className="max-w-3xl mx-auto text-center mb-16">
          <h1 className="font-serif text-4xl md:text-5xl font-bold text-slate-800 mb-6">Our Story</h1>
          <p className="text-lg text-slate-600 leading-relaxed">
            Born from a deep love for our island home, Serendib Days was created to offer a better way to experience Sri Lanka. 
            We are not a faceless global agency; we are locals who know the hidden trails, the best time to see elephants, and 
            where to find the most authentic rice and curry.
          </p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center mb-20">
          <img 
            src="https://images.unsplash.com/photo-1579730591523-28957cdbd045?auto=format&fit=crop&w=800&q=80" 
            alt="Sri Lanka tea pluckers" 
            className="rounded-xl shadow-lg w-full h-[400px] object-cover"
          />
          <div>
            <h2 className="font-serif text-3xl font-bold text-slate-800 mb-4">Authentic. Local. Personal.</h2>
            <p className="text-slate-600 mb-4">
              Our mission is to share the true spirit of Sri Lanka. "Serendib" is an ancient name for Sri Lanka, from which the word "serendipity" (a happy or unexpected discovery) was derived. That's exactly what we want your journey to be.
            </p>
            <p className="text-slate-600">
              We employ local drivers and guides, partner with eco-friendly hotels, and promote responsible tourism to ensure the beauty of our country is preserved for generations to come.
            </p>
          </div>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-8">
          <div className="bg-white p-8 rounded-xl text-center shadow-sm border border-slate-100">
            <Users className="h-10 w-10 text-primary mx-auto mb-4" />
            <h3 className="font-bold text-slate-800 mb-2">Local Experts</h3>
            <p className="text-sm text-slate-600">Our guides live and breathe Sri Lanka. They are your friends on the ground.</p>
          </div>
          <div className="bg-white p-8 rounded-xl text-center shadow-sm border border-slate-100">
            <ShieldCheck className="h-10 w-10 text-primary mx-auto mb-4" />
            <h3 className="font-bold text-slate-800 mb-2">Trust & Safety</h3>
            <p className="text-sm text-slate-600">Fully registered and certified by the Sri Lanka Tourism Development Authority.</p>
          </div>
          <div className="bg-white p-8 rounded-xl text-center shadow-sm border border-slate-100">
            <Leaf className="h-10 w-10 text-primary mx-auto mb-4" />
            <h3 className="font-bold text-slate-800 mb-2">Responsible Travel</h3>
            <p className="text-sm text-slate-600">We support local communities and promote eco-friendly practices.</p>
          </div>
        </div>
      </Container>
    </div>
  );
}
