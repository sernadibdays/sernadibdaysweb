import React, { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { MapPin, Phone, Mail, Clock, CheckCircle2 } from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { getPackages } from '../services/packagesService';
import { submitEnquiry } from '../services/enquiriesService';

const contactSchema = z.object({
  name: z.string().min(2, 'Name is required'),
  email: z.string().email('Valid email is required'),
  phone: z.string().min(5, 'Phone number is required'),
  package_id: z.string().optional(),
  travel_dates: z.string().min(2, 'Approximate dates are required'),
  adults: z.number().min(1, 'At least 1 adult'),
  children: z.number().min(0),
  budget_tier: z.enum(['essential', 'comfort', 'signature', 'undecided']),
  message: z.string().optional(),
  honeypot: z.string().max(0, 'Spam detected').optional(),
});

type ContactFormValues = z.infer<typeof contactSchema>;

export default function Contact() {
  const [searchParams] = useSearchParams();
  const preselectedPackage = searchParams.get('package');
  
  const [packages, setPackages] = useState<any[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const { register, handleSubmit, formState: { errors } } = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      package_id: preselectedPackage || '',
      adults: 2,
      children: 0,
      budget_tier: 'undecided',
    }
  });

  useEffect(() => {
    const fetchPkgs = async () => {
      try {
        const pkgs = await getPackages();
        setPackages(pkgs || []);
      } catch (err) {
        console.error(err);
      }
    };
    fetchPkgs();
  }, []);

  const onSubmit = async (data: ContactFormValues) => {
    if (data.honeypot) return;
    
    try {
      setIsSubmitting(true);
      setErrorMsg('');
      await submitEnquiry(data);
      setIsSuccess(true);
    } catch (err) {
      console.error(err);
      setErrorMsg('Something went wrong. Please try again or contact us directly.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const whatsappNumber = import.meta.env.VITE_WHATSAPP_NUMBER || '+94771234567';

  return (
    <div className="py-20 bg-offwhite min-h-screen">
      <Helmet>
        <title>Contact Us | Serendib Days</title>
        <meta name="description" content="Get in touch with local Sri Lankan travel experts. Plan your perfect holiday today." />
      </Helmet>

      <Container>
        <div className="mb-16 text-center">
          <h1 className="font-serif text-4xl md:text-5xl font-bold text-slate-800 mb-4">Plan Your Journey</h1>
          <p className="text-lg text-slate-600 max-w-2xl mx-auto">
            Ready to explore Sri Lanka? Send us your details, and our local experts will craft the perfect itinerary for you within 24 hours.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 max-w-6xl mx-auto">
          <div className="lg:col-span-1 space-y-8">
            <div className="bg-primary text-white p-8 rounded-xl shadow-sm">
              <h3 className="font-serif text-2xl font-bold mb-6">Get in Touch</h3>
              
              <ul className="space-y-6">
                <li className="flex gap-4">
                  <Phone className="h-6 w-6 text-primary-200 shrink-0" />
                  <div>
                    <p className="font-semibold mb-1">WhatsApp / Phone</p>
                    <a href={`https://wa.me/${whatsappNumber.replace(/[^0-9]/g, '')}`} className="hover:text-primary-200 transition-colors">
                      {whatsappNumber}
                    </a>
                  </div>
                </li>
                <li className="flex gap-4">
                  <Mail className="h-6 w-6 text-primary-200 shrink-0" />
                  <div>
                    <p className="font-semibold mb-1">Email</p>
                    <a href="mailto:hello@serendibdays.com" className="hover:text-primary-200 transition-colors">
                      hello@serendibdays.com
                    </a>
                  </div>
                </li>
                <li className="flex gap-4">
                  <Clock className="h-6 w-6 text-primary-200 shrink-0" />
                  <div>
                    <p className="font-semibold mb-1">Business Hours</p>
                    <p className="text-primary-100">Monday - Saturday<br/>9:00 AM - 6:00 PM (LKT)</p>
                  </div>
                </li>
                <li className="flex gap-4">
                  <MapPin className="h-6 w-6 text-primary-200 shrink-0" />
                  <div>
                    <p className="font-semibold mb-1">Location</p>
                    <p className="text-primary-100">Colombo, Sri Lanka</p>
                  </div>
                </li>
              </ul>
            </div>
          </div>

          <div className="lg:col-span-2">
            <div className="bg-white p-8 md:p-10 rounded-xl shadow-sm border border-slate-100">
              {isSuccess ? (
                <div className="text-center py-16">
                  <div className="mx-auto w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mb-6">
                    <CheckCircle2 className="w-10 h-10" />
                  </div>
                  <h3 className="font-serif text-3xl font-bold text-slate-800 mb-4">Enquiry Sent Successfully!</h3>
                  <p className="text-lg text-slate-600 mb-8">
                    Thank you for reaching out. One of our local experts will review your request and get back to you within 24 hours.
                  </p>
                  <Button onClick={() => setIsSuccess(false)} variant="outline">Send Another Enquiry</Button>
                </div>
              ) : (
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                  
                  <div className="hidden">
                    <input type="text" {...register('honeypot')} tabIndex={-1} autoComplete="off" />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Full Name *</label>
                      <input 
                        type="text" 
                        {...register('name')}
                        className={`w-full bg-slate-50 border ${errors.name ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                      {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name.message}</p>}
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Email Address *</label>
                      <input 
                        type="email" 
                        {...register('email')}
                        className={`w-full bg-slate-50 border ${errors.email ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                      {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email.message}</p>}
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">WhatsApp / Phone *</label>
                      <input 
                        type="text" 
                        {...register('phone')}
                        className={`w-full bg-slate-50 border ${errors.phone ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                      {errors.phone && <p className="text-red-500 text-xs mt-1">{errors.phone.message}</p>}
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Approximate Travel Dates *</label>
                      <input 
                        type="text" 
                        placeholder="e.g. December 2024 or 12-20 Dec"
                        {...register('travel_dates')}
                        className={`w-full bg-slate-50 border ${errors.travel_dates ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                      {errors.travel_dates && <p className="text-red-500 text-xs mt-1">{errors.travel_dates.message}</p>}
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">Interested Package (Optional)</label>
                    <select 
                      {...register('package_id')}
                      className="w-full bg-slate-50 border border-slate-200 rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    >
                      <option value="">I'm not sure yet / Custom itinerary</option>
                      {packages.map(pkg => (
                        <option key={pkg.id} value={pkg.id}>{pkg.title} ({pkg.duration_days} Days)</option>
                      ))}
                    </select>
                  </div>

                  <div className="grid grid-cols-3 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Adults</label>
                      <input 
                        type="number" 
                        min="1"
                        {...register('adults', { valueAsNumber: true })}
                        className={`w-full bg-slate-50 border ${errors.adults ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                      {errors.adults && <p className="text-red-500 text-xs mt-1">{errors.adults.message}</p>}
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Children</label>
                      <input 
                        type="number" 
                        min="0"
                        {...register('children', { valueAsNumber: true })}
                        className={`w-full bg-slate-50 border ${errors.children ? 'border-red-500' : 'border-slate-200'} rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent`}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1">Budget Tier</label>
                      <select 
                        {...register('budget_tier')}
                        className="w-full bg-slate-50 border border-slate-200 rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                      >
                        <option value="undecided">Not sure yet</option>
                        <option value="essential">Essential (3-star)</option>
                        <option value="comfort">Comfort (4-star)</option>
                        <option value="signature">Signature (5-star)</option>
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1">Message / Special Requirements</label>
                    <textarea 
                      rows={4}
                      placeholder="Tell us more about your ideal trip..."
                      {...register('message')}
                      className="w-full bg-slate-50 border border-slate-200 rounded-md py-2.5 px-4 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    ></textarea>
                  </div>

                  {errorMsg && (
                    <div className="p-4 bg-red-50 text-red-700 rounded-md text-sm">
                      {errorMsg}
                    </div>
                  )}

                  <Button 
                    type="submit" 
                    size="lg" 
                    className="w-full"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? 'Sending Enquiry...' : 'Send Enquiry'}
                  </Button>
                  <p className="text-center text-xs text-slate-500 mt-4">
                    Your information is secure. We will only use it to respond to your request.
                  </p>
                </form>
              )}
            </div>
          </div>
        </div>
      </Container>
    </div>
  );
}
