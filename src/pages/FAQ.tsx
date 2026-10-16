import React, { useEffect, useState } from 'react';
import { Helmet } from 'react-helmet-async';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { getFaqs } from '../services/faqsService';

export default function FAQ() {
  const [faqs, setFaqs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  useEffect(() => {
    const fetchFaqs = async () => {
      try {
        const data = await getFaqs();
        setFaqs(data || []);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchFaqs();
  }, []);

  return (
    <div className="py-20 bg-offwhite min-h-screen">
      <Helmet>
        <title>FAQ | Serendib Days</title>
        <meta name="description" content="Frequently asked questions about traveling to Sri Lanka and booking with Serendib Days." />
      </Helmet>

      <Container>
        <div className="max-w-3xl mx-auto text-center mb-16">
          <h1 className="font-serif text-4xl md:text-5xl font-bold text-slate-800 mb-6">Frequently Asked Questions</h1>
          <p className="text-lg text-slate-600">Everything you need to know before you go.</p>
        </div>

        <div className="max-w-3xl mx-auto">
          {loading ? (
            <div className="space-y-4">
              {[1,2,3,4,5].map(i => <div key={i} className="h-16 bg-slate-200 animate-pulse rounded-lg"></div>)}
            </div>
          ) : (
            <div className="space-y-4">
              {faqs.map((faq, index) => (
                <div key={faq.id} className="bg-white border border-slate-200 rounded-lg overflow-hidden">
                  <button 
                    className="w-full flex items-center justify-between p-5 text-left font-bold text-slate-800 hover:bg-slate-50 transition-colors"
                    onClick={() => setOpenIndex(openIndex === index ? null : index)}
                  >
                    <span>{faq.question}</span>
                    {openIndex === index ? (
                      <ChevronUp className="h-5 w-5 text-primary shrink-0" />
                    ) : (
                      <ChevronDown className="h-5 w-5 text-slate-400 shrink-0" />
                    )}
                  </button>
                  {openIndex === index && (
                    <div className="p-5 pt-0 text-slate-600 border-t border-slate-100 mt-1">
                      {faq.answer}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
          
          <div className="mt-12 text-center bg-primary-50 p-8 rounded-xl border border-primary-100">
            <h3 className="font-bold text-slate-800 mb-2">Still have questions?</h3>
            <p className="text-slate-600 mb-4">We are here to help you plan the perfect trip.</p>
            <a href="/contact" className="text-primary font-bold hover:underline">Contact Us</a>
          </div>
        </div>
      </Container>
    </div>
  );
}
