import React, { useState, useEffect } from 'react';
import { Helmet } from 'react-helmet-async';
import { 
  Package as PackageIcon, 
  MessageSquare, 
  HelpCircle, 
  Inbox, 
  Settings, 
  ExternalLink, 
  Plus, 
  Search, 
  Edit3, 
  Trash2, 
  Check, 
  X, 
  Eye, 
  EyeOff, 
  Star, 
  RefreshCw, 
  Database, 
  LogOut, 
  Lock, 
  MapPin, 
  Clock, 
  DollarSign, 
  Calendar,
  AlertCircle,
  Copy,
  ChevronRight,
  Sparkles
} from 'lucide-react';
import { Container } from '../components/ui/Container';
import { Button } from '../components/ui/Button';
import { 
  getAllPackagesAdmin, 
  savePackageFull, 
  deletePackage, 
  togglePublishPackage, 
  toggleFeaturedPackage 
} from '../services/packagesService';
import { 
  getAllTestimonialsAdmin, 
  saveTestimonial, 
  deleteTestimonial 
} from '../services/testimonialsService';
import { 
  getAllFaqsAdmin, 
  saveFaq, 
  deleteFaq 
} from '../services/faqsService';
import { 
  getEnquiries, 
  updateEnquiryStatus, 
  EnquiryItem 
} from '../services/enquiriesService';
import { 
  getSiteContent, 
  updateSiteContent 
} from '../services/siteContentService';
import { formatCurrency } from '../utils/currency';
import type { Package, PackageTier, ItineraryDay, Testimonial, FAQ } from '../types/database';

export default function Admin() {
  // Auth state
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(() => {
    return localStorage.getItem('serendib_admin_session') === 'true';
  });
  const [passcode, setPasscode] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loginError, setLoginError] = useState('');

  // Password Change state
  const [currentPassInput, setCurrentPassInput] = useState('');
  const [newPassInput, setNewPassInput] = useState('');
  const [confirmPassInput, setConfirmPassInput] = useState('');
  const [passChangeError, setPassChangeError] = useState('');
  const [passChangeSuccess, setPassChangeSuccess] = useState('');
  const [showNewPass, setShowNewPass] = useState(false);

  // Active Tab
  const [activeTab, setActiveTab] = useState<'overview' | 'packages' | 'enquiries' | 'testimonials' | 'faqs' | 'content' | 'database'>('overview');

  // Data states
  const [packages, setPackages] = useState<Package[]>([]);
  const [testimonials, setTestimonials] = useState<Testimonial[]>([]);
  const [faqs, setFaqs] = useState<FAQ[]>([]);
  const [enquiries, setEnquiries] = useState<EnquiryItem[]>([]);
  const [siteContent, setSiteContent] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Package Editor Modal State
  const [isEditingPackage, setIsEditingPackage] = useState(false);
  const [editingPkg, setEditingPkg] = useState<Partial<Package>>({});
  const [pkgTiers, setPkgTiers] = useState<Partial<PackageTier>[]>([]);
  const [pkgDays, setPkgDays] = useState<Partial<ItineraryDay>[]>([]);
  const [searchQuery, setSearchQuery] = useState('');

  // Testimonial / FAQ Modal States
  const [isEditingTestimonial, setIsEditingTestimonial] = useState(false);
  const [editingTestimonial, setEditingTestimonial] = useState<Partial<Testimonial>>({});
  const [isEditingFaq, setIsEditingFaq] = useState(false);
  const [editingFaq, setEditingFaq] = useState<Partial<FAQ>>({});

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const loadAllData = async () => {
    setLoading(true);
    try {
      const [pkgs, tests, fqs, enqs, content] = await Promise.all([
        getAllPackagesAdmin(),
        getAllTestimonialsAdmin(),
        getAllFaqsAdmin(),
        getEnquiries(),
        getSiteContent()
      ]);
      setPackages(pkgs);
      setTestimonials(tests);
      setFaqs(fqs as FAQ[]);
      setEnquiries(enqs);
      setSiteContent(content);
    } catch (err) {
      console.error('Error loading admin data', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isAuthenticated) {
      loadAllData();
    }
  }, [isAuthenticated]);

  const getAdminPassword = () => {
    return localStorage.getItem('serendib_admin_custom_password') || 
           (import.meta.env.VITE_ADMIN_PASSWORD as string | undefined) || 
           'serendib2025';
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    const validPassword = getAdminPassword();
    if (passcode === validPassword) {
      localStorage.setItem('serendib_admin_session', 'true');
      setIsAuthenticated(true);
      setLoginError('');
      showToast('Welcome to Serendib Days Admin CMS');
    } else {
      setLoginError('Incorrect administrator password. Please try again.');
    }
  };

  const handleChangePassword = (e: React.FormEvent) => {
    e.preventDefault();
    setPassChangeError('');
    setPassChangeSuccess('');
    const validPassword = getAdminPassword();

    if (currentPassInput !== validPassword) {
      setPassChangeError('Current password is incorrect.');
      return;
    }
    if (!newPassInput || newPassInput.length < 4) {
      setPassChangeError('New password must be at least 4 characters long.');
      return;
    }
    if (newPassInput !== confirmPassInput) {
      setPassChangeError('New passwords do not match.');
      return;
    }

    localStorage.setItem('serendib_admin_custom_password', newPassInput);
    setCurrentPassInput('');
    setNewPassInput('');
    setConfirmPassInput('');
    setPassChangeSuccess('Admin password updated successfully!');
    showToast('Admin password updated successfully!');
  };

  const handleLogout = () => {
    localStorage.removeItem('serendib_admin_session');
    setIsAuthenticated(false);
  };

  // Open Package Editor
  const openPackageEditor = (pkg?: Package) => {
    if (pkg) {
      setEditingPkg({ ...pkg });
      setPkgTiers(pkg.package_tiers ? [...pkg.package_tiers] : [
        { tier: 'essential', price_usd: 100, stay_details: 'Comfortable guesthouses & 3★ hotels', transport_details: 'Private AC car with chauffeur-guide' },
        { tier: 'comfort', price_usd: 250, stay_details: 'Handpicked 4★ boutique hotels with pools', transport_details: 'Comfortable SUV with chauffeur-guide' },
        { tier: 'signature', price_usd: 550, stay_details: '5★ luxury heritage resorts & villas', transport_details: 'Luxury vehicle with senior naturalist-guide' }
      ]);
      setPkgDays(pkg.itinerary_days ? [...pkg.itinerary_days] : []);
    } else {
      setEditingPkg({
        id: crypto.randomUUID(),
        title: '',
        slug: '',
        duration_days: 1,
        route: 'Colombo → Destination → Return',
        best_time: 'Year-round',
        short_description: '',
        description: '',
        interests: ['Culture & Heritage'],
        cover_image: 'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=1200&q=80',
        gallery: [],
        inclusions: [
          'Private air-conditioned vehicle with fuel and driver-guide',
          'Hotel accommodations with breakfast',
          'All taxes and expressway toll charges'
        ],
        exclusions: [
          'International flights and tourist visa',
          'Entrance fees unless specified',
          'Personal expenses and tips'
        ],
        notes: null,
        is_featured: false,
        is_published: true,
        sort_order: packages.length + 1
      });
      setPkgTiers([
        { tier: 'essential', price_usd: 100, stay_details: 'Comfortable 3★ hotels', transport_details: 'Private AC Car' },
        { tier: 'comfort', price_usd: 250, stay_details: '4★ boutique hotels with pool', transport_details: 'Comfortable SUV' },
        { tier: 'signature', price_usd: 550, stay_details: '5★ luxury heritage properties', transport_details: 'Luxury vehicle' }
      ]);
      setPkgDays([
        { day_number: 1, title: 'Arrival & Scenic Exploration', description: 'Meet your guide and explore the vibrant sights.', overnight_location: 'Check route' }
      ]);
    }
    setIsEditingPackage(true);
  };

  const handleSavePackage = async () => {
    if (!editingPkg.title) {
      alert('Package title is required.');
      return;
    }
    setLoading(true);
    try {
      const saved = await savePackageFull(editingPkg, pkgTiers, pkgDays);
      await loadAllData();
      setIsEditingPackage(false);
      showToast(`Package "${saved.title}" saved successfully!`);
    } catch (e) {
      console.error(e);
      alert('Error saving package.');
    } finally {
      setLoading(false);
    }
  };

  const handleDeletePackage = async (id: string, title: string) => {
    if (confirm(`Are you sure you want to delete "${title}"?`)) {
      setLoading(true);
      await deletePackage(id);
      await loadAllData();
      setLoading(false);
      showToast(`Package "${title}" deleted.`);
    }
  };

  const handleTogglePublish = async (pkg: Package) => {
    const nextState = !pkg.is_published;
    await togglePublishPackage(pkg.id, nextState);
    setPackages(prev => prev.map(p => p.id === pkg.id ? { ...p, is_published: nextState } : p));
    showToast(`Package ${nextState ? 'published to live website' : 'hidden as draft'}.`);
  };

  const handleToggleFeatured = async (pkg: Package) => {
    const nextState = !pkg.is_featured;
    await toggleFeaturedPackage(pkg.id, nextState);
    setPackages(prev => prev.map(p => p.id === pkg.id ? { ...p, is_featured: nextState } : p));
    showToast(`Package ${nextState ? 'featured on homepage' : 'removed from featured'}.`);
  };

  // Testimonial Save
  const handleSaveTestimonial = async () => {
    if (!editingTestimonial.name || !editingTestimonial.text) {
      alert('Please provide name and review text.');
      return;
    }
    await saveTestimonial(editingTestimonial);
    await loadAllData();
    setIsEditingTestimonial(false);
    showToast('Testimonial saved successfully!');
  };

  // FAQ Save
  const handleSaveFaq = async () => {
    if (!editingFaq.question || !editingFaq.answer) {
      alert('Please provide question and answer.');
      return;
    }
    await saveFaq(editingFaq);
    await loadAllData();
    setIsEditingFaq(false);
    showToast('FAQ saved successfully!');
  };

  // Site Content Save
  const handleSaveContent = async (key: string, value: string) => {
    await updateSiteContent(key, value);
    setSiteContent(prev => ({ ...prev, [key]: value }));
    showToast(`Content for "${key}" updated.`);
  };

  // Filtered packages
  const filteredPackages = packages.filter(p => {
    const q = searchQuery.toLowerCase();
    return p.title.toLowerCase().includes(q) || 
           p.route.toLowerCase().includes(q) || 
           p.slug.toLowerCase().includes(q);
  });

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center p-4">
        <Helmet>
          <title>Admin Login | Serendib Days CMS</title>
        </Helmet>
        <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full border border-slate-200">
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mx-auto mb-4 text-primary">
              <Lock className="w-8 h-8" />
            </div>
            <h1 className="font-serif text-3xl font-bold text-slate-900">Serendib Days CMS</h1>
            <p className="text-slate-500 text-sm mt-1">Administrator Content & Tour Management</p>
          </div>

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1">Administrator Password</label>
              <div className="relative">
                <input 
                  type={showPassword ? 'text' : 'password'} 
                  placeholder="Enter administrator password"
                  value={passcode}
                  onChange={e => setPasscode(e.target.value)}
                  className="w-full pl-4 pr-11 py-3 rounded-xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent text-slate-900"
                  autoFocus
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-3.5 text-slate-400 hover:text-slate-600 focus:outline-none"
                  title={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            {loginError && (
              <div className="p-3 bg-red-50 text-red-600 rounded-lg text-sm flex items-center gap-2">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{loginError}</span>
              </div>
            )}

            <Button type="submit" size="lg" className="w-full">
              Enter Admin Dashboard
            </Button>

            <p className="text-center text-xs text-slate-400 mt-4">
              Protected interface for managing Serendib Days tours, pricing, testimonials, and site content.
            </p>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      <Helmet>
        <title>Administration CMS | Serendib Days</title>
      </Helmet>

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-slate-900 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 border border-slate-700 animate-bounce">
          <Check className="w-5 h-5 text-emerald-400" />
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Admin Top Header */}
      <header className="bg-slate-900 text-white border-b border-slate-800 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-primary flex items-center justify-center font-bold text-white shadow-md">
              SD
            </div>
            <div>
              <span className="font-serif font-bold text-lg text-white">Serendib Days</span>
              <span className="text-xs px-2 py-0.5 ml-2 rounded bg-primary/20 text-primary-300 font-medium">CMS Studio</span>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <a 
              href="/" 
              target="_blank" 
              rel="noreferrer"
              className="text-xs flex items-center gap-1.5 text-slate-300 hover:text-white bg-slate-800 px-3 py-1.5 rounded-lg transition-colors border border-slate-700"
            >
              <span>View Live Website</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>

            <button 
              onClick={handleLogout}
              className="text-xs flex items-center gap-1.5 text-red-400 hover:text-red-300 bg-red-950/40 hover:bg-red-950/60 px-3 py-1.5 rounded-lg transition-colors border border-red-900/50"
            >
              <LogOut className="w-3.5 h-3.5" />
              <span>Log Out</span>
            </button>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex overflow-x-auto border-t border-slate-800">
          {[
            { id: 'overview', label: 'Dashboard Overview', icon: Sparkles },
            { id: 'packages', label: `Packages (${packages.length})`, icon: PackageIcon },
            { id: 'enquiries', label: `Enquiries (${enquiries.length})`, icon: Inbox },
            { id: 'testimonials', label: `Testimonials (${testimonials.length})`, icon: MessageSquare },
            { id: 'faqs', label: `FAQs (${faqs.length})`, icon: HelpCircle },
            { id: 'content', label: 'Site Content', icon: Settings },
            { id: 'database', label: 'Supabase Sync', icon: Database },
          ].map(tab => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-2 px-5 py-3 text-sm font-medium border-b-2 whitespace-nowrap transition-colors ${
                  isActive 
                    ? 'border-primary text-white bg-slate-800/60' 
                    : 'border-transparent text-slate-400 hover:text-slate-200 hover:bg-slate-800/30'
                }`}
              >
                <Icon className={`w-4 h-4 ${isActive ? 'text-primary' : 'text-slate-400'}`} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>
      </header>

      {/* Main Admin Area */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        {/* OVERVIEW TAB */}
        {activeTab === 'overview' && (
          <div className="space-y-8">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
              <div>
                <h2 className="font-serif text-2xl font-bold text-slate-900">Welcome to Serendib Days Management</h2>
                <p className="text-slate-500 text-sm mt-1">
                  All 25 curated travel packages, itineraries, testimonials, and bookings are accessible and editable below.
                </p>
              </div>
              <div className="flex items-center gap-3">
                <Button onClick={() => openPackageEditor()} className="flex items-center gap-2">
                  <Plus className="w-4 h-4" />
                  <span>Create New Package</span>
                </Button>
                <Button variant="outline" onClick={loadAllData} className="flex items-center gap-2">
                  <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                  <span>Refresh Data</span>
                </Button>
              </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-slate-500">Total Packages</span>
                  <div className="w-10 h-10 rounded-xl bg-teal-50 text-teal-600 flex items-center justify-center">
                    <PackageIcon className="w-5 h-5" />
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-900">{packages.length}</div>
                <div className="text-xs text-slate-500 mt-2 flex items-center gap-2">
                  <span className="text-emerald-600 font-semibold">{packages.filter(p => p.is_published).length} Published</span>
                  <span>•</span>
                  <span>{packages.filter(p => p.is_featured).length} Featured</span>
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-slate-500">Customer Enquiries</span>
                  <div className="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                    <Inbox className="w-5 h-5" />
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-900">{enquiries.length}</div>
                <div className="text-xs text-slate-500 mt-2">
                  <span className="text-amber-600 font-semibold">{enquiries.filter(e => e.status === 'new').length} New Pending</span>
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-slate-500">Guest Testimonials</span>
                  <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                    <MessageSquare className="w-5 h-5" />
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-900">{testimonials.length}</div>
                <div className="text-xs text-slate-500 mt-2">
                  <span>5-Star verified traveler reviews</span>
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-slate-500">Frequently Asked</span>
                  <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
                    <HelpCircle className="w-5 h-5" />
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-900">{faqs.length}</div>
                <div className="text-xs text-slate-500 mt-2">
                  <span>Live FAQs with rich answers</span>
                </div>
              </div>
            </div>

            {/* Recent Enquiries & Featured Packages */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Recent Enquiries */}
              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                  <h3 className="font-serif text-lg font-bold text-slate-900">Latest Enquiries</h3>
                  <button 
                    onClick={() => setActiveTab('enquiries')}
                    className="text-xs font-semibold text-primary hover:underline flex items-center gap-1"
                  >
                    View all <ChevronRight className="w-3.5 h-3.5" />
                  </button>
                </div>

                {enquiries.length === 0 ? (
                  <p className="text-slate-400 text-sm text-center py-8">No customer enquiries received yet.</p>
                ) : (
                  <div className="space-y-4">
                    {enquiries.slice(0, 4).map(e => (
                      <div key={e.id} className="p-4 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-slate-800 text-sm">{e.name}</span>
                            <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                              e.status === 'new' ? 'bg-amber-100 text-amber-800' :
                              e.status === 'contacted' ? 'bg-blue-100 text-blue-800' :
                              e.status === 'booked' ? 'bg-emerald-100 text-emerald-800' :
                              'bg-slate-200 text-slate-700'
                            }`}>
                              {e.status}
                            </span>
                          </div>
                          <div className="text-xs text-slate-500 mt-1">
                            {e.email} • {e.adults} Adults • {e.travel_dates}
                          </div>
                        </div>
                        <button 
                          onClick={() => setActiveTab('enquiries')}
                          className="text-xs text-primary font-medium hover:underline"
                        >
                          Details
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Quick Actions & Brand Values */}
              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-between">
                <div>
                  <h3 className="font-serif text-lg font-bold text-slate-900 mb-2">Serendib Days Brand Values</h3>
                  <p className="text-sm text-slate-500 mb-6">
                    Our established visual identity and content voice are preserved throughout:
                  </p>
                  
                  <div className="space-y-3">
                    <div className="flex items-center gap-3 p-3 rounded-xl bg-teal-50 border border-teal-100 text-sm text-teal-900">
                      <div className="w-4 h-4 rounded-full bg-[#0F766E] shrink-0"></div>
                      <div>
                        <strong>Deep Teal (#0F766E)</strong> — Main brand accent for trust, serenity, and Sri Lankan seas.
                      </div>
                    </div>
                    <div className="flex items-center gap-3 p-3 rounded-xl bg-amber-50 border border-amber-100 text-sm text-amber-900">
                      <div className="w-4 h-4 rounded-full bg-[#F59E0B] shrink-0"></div>
                      <div>
                        <strong>Warm Amber (#F59E0B)</strong> — Highlights, badges, and sunshine warmth.
                      </div>
                    </div>
                    <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm text-slate-800">
                      <div className="w-4 h-4 rounded-full bg-slate-800 shrink-0"></div>
                      <div>
                        <strong>Playfair Display & Inter</strong> — Classic editorial elegance paired with crisp modern readability.
                      </div>
                    </div>
                  </div>
                </div>

                <div className="mt-8 pt-6 border-t border-slate-100 flex gap-3">
                  <Button onClick={() => setActiveTab('packages')} className="flex-1">
                    Manage Tour Packages
                  </Button>
                  <Button variant="outline" onClick={() => setActiveTab('content')} className="flex-1">
                    Edit Website Content
                  </Button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* PACKAGES TAB */}
        {activeTab === 'packages' && (
          <div className="space-y-6">
            {/* Header Toolbar */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
              <div className="flex-1 max-w-md relative">
                <Search className="w-5 h-5 absolute left-3 top-3 text-slate-400" />
                <input 
                  type="text"
                  placeholder="Search packages by title, route, slug..."
                  value={searchQuery}
                  onChange={e => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent text-sm"
                />
              </div>

              <div className="flex items-center gap-3 w-full sm:w-auto">
                <Button onClick={() => openPackageEditor()} className="flex items-center gap-2">
                  <Plus className="w-4 h-4" />
                  <span>Add New Package</span>
                </Button>
              </div>
            </div>

            {/* Packages Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredPackages.map(pkg => {
                const minPrice = pkg.package_tiers && pkg.package_tiers.length > 0 
                  ? Math.min(...pkg.package_tiers.map(t => t.price_usd)) 
                  : 0;

                return (
                  <div key={pkg.id} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden flex flex-col hover:shadow-md transition-shadow">
                    <div className="relative aspect-[16/10] overflow-hidden bg-slate-100">
                      <img 
                        src={pkg.cover_image} 
                        alt={pkg.title} 
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1586227740560-8cf2732c1531?auto=format&fit=crop&w=800&q=80';
                        }}
                      />
                      <div className="absolute top-3 left-3 flex gap-2">
                        <span className="bg-slate-900/80 backdrop-blur-md text-white text-xs font-semibold px-2.5 py-1 rounded-full">
                          {pkg.duration_days} {pkg.duration_days === 1 ? 'Day' : 'Days'}
                        </span>
                        {pkg.is_featured && (
                          <span className="bg-accent text-white text-xs font-bold px-2.5 py-1 rounded-full shadow-sm">
                            Featured
                          </span>
                        )}
                      </div>

                      <div className="absolute top-3 right-3 flex gap-1.5">
                        <button
                          onClick={() => handleTogglePublish(pkg)}
                          title={pkg.is_published ? "Published (click to hide)" : "Draft (click to publish)"}
                          className={`p-2 rounded-full backdrop-blur-md shadow-sm transition-colors ${
                            pkg.is_published ? 'bg-emerald-500 text-white' : 'bg-slate-800/80 text-slate-300'
                          }`}
                        >
                          {pkg.is_published ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                        </button>
                        <button
                          onClick={() => handleToggleFeatured(pkg)}
                          title={pkg.is_featured ? "Featured on Home" : "Make Featured"}
                          className={`p-2 rounded-full backdrop-blur-md shadow-sm transition-colors ${
                            pkg.is_featured ? 'bg-amber-400 text-slate-900' : 'bg-slate-800/80 text-slate-300'
                          }`}
                        >
                          <Star className="w-4 h-4" fill={pkg.is_featured ? "currentColor" : "none"} />
                        </button>
                      </div>
                    </div>

                    <div className="p-5 flex-1 flex flex-col">
                      <div className="flex items-center gap-1.5 text-xs text-primary font-semibold uppercase tracking-wider mb-1">
                        <MapPin className="w-3.5 h-3.5 shrink-0" />
                        <span className="truncate">{pkg.route.split('→')[0].trim()}...</span>
                      </div>

                      <h3 className="font-serif font-bold text-lg text-slate-900 mb-2 leading-snug line-clamp-1">
                        {pkg.title}
                      </h3>

                      <p className="text-slate-600 text-xs line-clamp-2 mb-4 leading-relaxed">
                        {pkg.short_description}
                      </p>

                      <div className="mt-auto pt-4 border-t border-slate-100 flex items-center justify-between">
                        <div>
                          <span className="text-[10px] uppercase font-bold text-slate-400">From</span>
                          <div className="font-bold text-primary text-base">
                            {formatCurrency(minPrice)}
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <a 
                            href={`/packages/${pkg.slug}`} 
                            target="_blank" 
                            rel="noreferrer"
                            title="Preview on Public Website"
                            className="p-2 rounded-lg text-slate-500 hover:text-primary hover:bg-slate-100 transition-colors"
                          >
                            <ExternalLink className="w-4 h-4" />
                          </a>
                          <button
                            onClick={() => openPackageEditor(pkg)}
                            title="Edit Package Details"
                            className="p-2 rounded-lg text-slate-500 hover:text-primary hover:bg-slate-100 transition-colors"
                          >
                            <Edit3 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDeletePackage(pkg.id, pkg.title)}
                            title="Delete Package"
                            className="p-2 rounded-lg text-slate-400 hover:text-red-500 hover:bg-red-50 transition-colors"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ENQUIRIES TAB */}
        {activeTab === 'enquiries' && (
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex justify-between items-center">
              <div>
                <h2 className="font-serif text-2xl font-bold text-slate-900">Guest Tour Enquiries</h2>
                <p className="text-slate-500 text-sm mt-1">
                  Manage incoming trip requests, send personalized quotes, and update booking status.
                </p>
              </div>
              <Button variant="outline" onClick={loadAllData} className="flex items-center gap-2">
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                <span>Refresh</span>
              </Button>
            </div>

            {enquiries.length === 0 ? (
              <div className="bg-white p-12 text-center rounded-2xl border border-slate-200">
                <Inbox className="w-12 h-12 text-slate-300 mx-auto mb-3" />
                <h3 className="text-lg font-bold text-slate-800">No enquiries received yet</h3>
                <p className="text-slate-500 text-sm mt-1">When visitors submit the Contact form, their details appear here immediately.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {enquiries.map(enq => (
                  <div key={enq.id} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                    <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-100 pb-4 mb-4">
                      <div>
                        <div className="flex items-center gap-3">
                          <h3 className="font-bold text-lg text-slate-900">{enq.name}</h3>
                          <span className={`text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full ${
                            enq.status === 'new' ? 'bg-amber-100 text-amber-800' :
                            enq.status === 'contacted' ? 'bg-blue-100 text-blue-800' :
                            enq.status === 'quoted' ? 'bg-purple-100 text-purple-800' :
                            enq.status === 'booked' ? 'bg-emerald-100 text-emerald-800' :
                            'bg-slate-200 text-slate-700'
                          }`}>
                            Status: {enq.status}
                          </span>
                        </div>
                        <div className="text-sm text-slate-500 mt-1 flex flex-wrap gap-4">
                          <span>Email: <strong>{enq.email}</strong></span>
                          <span>Phone: <strong>{enq.phone}</strong></span>
                          <span>Dates: <strong>{enq.travel_dates}</strong></span>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <select 
                          value={enq.status}
                          onChange={async (e) => {
                            const newStatus = e.target.value as any;
                            await updateEnquiryStatus(enq.id, newStatus);
                            setEnquiries(prev => prev.map(item => item.id === enq.id ? { ...item, status: newStatus } : item));
                            showToast(`Status updated to ${newStatus}`);
                          }}
                          className="px-3 py-1.5 rounded-xl border border-slate-300 text-sm font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-primary"
                        >
                          <option value="new">Mark as New</option>
                          <option value="contacted">Mark as Contacted</option>
                          <option value="quoted">Mark as Quoted</option>
                          <option value="booked">Mark as Booked</option>
                          <option value="archived">Archive</option>
                        </select>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm bg-slate-50 p-4 rounded-xl">
                      <div>
                        <span className="text-slate-400 text-xs block">Party Size</span>
                        <strong className="text-slate-700">{enq.adults} Adults, {enq.children || 0} Children</strong>
                      </div>
                      <div>
                        <span className="text-slate-400 text-xs block">Budget Tier</span>
                        <strong className="text-slate-700 capitalize">{enq.budget_tier || 'Undecided'}</strong>
                      </div>
                      <div>
                        <span className="text-slate-400 text-xs block">Interested Package</span>
                        <strong className="text-slate-700">{enq.package_title || 'Custom Itinerary'}</strong>
                      </div>
                    </div>

                    {enq.message && (
                      <div className="mt-4 text-sm text-slate-600 bg-amber-50/50 p-4 rounded-xl border border-amber-100">
                        <span className="text-xs font-bold text-amber-900 block mb-1">Customer Special Requests:</span>
                        <p className="whitespace-pre-line">{enq.message}</p>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* TESTIMONIALS TAB */}
        {activeTab === 'testimonials' && (
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex justify-between items-center">
              <div>
                <h2 className="font-serif text-2xl font-bold text-slate-900">Guest Testimonials</h2>
                <p className="text-slate-500 text-sm mt-1">
                  Manage traveler reviews and feedback displayed on the homepage.
                </p>
              </div>
              <Button 
                onClick={() => {
                  setEditingTestimonial({
                    id: crypto.randomUUID(),
                    name: '',
                    country: '',
                    text: '',
                    rating: 5,
                    is_published: true
                  });
                  setIsEditingTestimonial(true);
                }}
                className="flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                <span>Add Testimonial</span>
              </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {testimonials.map(t => (
                <div key={t.id} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-between">
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex text-amber-400">
                        {[...Array(t.rating || 5)].map((_, i) => (
                          <Star key={i} className="w-4 h-4 fill-current" />
                        ))}
                      </div>
                      <span className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-full ${
                        t.is_published !== false ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-200 text-slate-600'
                      }`}>
                        {t.is_published !== false ? 'Live on Site' : 'Hidden'}
                      </span>
                    </div>

                    <p className="text-slate-700 italic text-sm mb-4 leading-relaxed">
                      "{t.text}"
                    </p>
                  </div>

                  <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-slate-900 text-sm">{t.name}</div>
                      <div className="text-xs text-slate-500">{t.country}</div>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => {
                          setEditingTestimonial(t);
                          setIsEditingTestimonial(true);
                        }}
                        className="p-1.5 rounded-lg text-slate-500 hover:text-primary hover:bg-slate-100"
                      >
                        <Edit3 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={async () => {
                          if (confirm(`Delete review from ${t.name}?`)) {
                            await deleteTestimonial(t.id);
                            await loadAllData();
                            showToast('Review deleted.');
                          }
                        }}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-red-500 hover:bg-red-50"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* FAQS TAB */}
        {activeTab === 'faqs' && (
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex justify-between items-center">
              <div>
                <h2 className="font-serif text-2xl font-bold text-slate-900">Frequently Asked Questions</h2>
                <p className="text-slate-500 text-sm mt-1">
                  Manage traveler questions displayed on the FAQ page and assistance modules.
                </p>
              </div>
              <Button 
                onClick={() => {
                  setEditingFaq({
                    id: crypto.randomUUID(),
                    question: '',
                    answer: '',
                    sort_order: faqs.length + 1,
                    is_published: true
                  });
                  setIsEditingFaq(true);
                }}
                className="flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                <span>Add FAQ</span>
              </Button>
            </div>

            <div className="space-y-4">
              {faqs.map(faq => (
                <div key={faq.id} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <span className="w-6 h-6 rounded-full bg-primary/10 text-primary font-bold text-xs flex items-center justify-center">
                        {faq.sort_order}
                      </span>
                      <h4 className="font-bold text-slate-900 text-base">{faq.question}</h4>
                    </div>
                    <p className="text-slate-600 text-sm leading-relaxed pl-9">
                      {faq.answer}
                    </p>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      onClick={() => {
                        setEditingFaq(faq);
                        setIsEditingFaq(true);
                      }}
                      className="p-2 rounded-lg text-slate-500 hover:text-primary hover:bg-slate-100"
                    >
                      <Edit3 className="w-4 h-4" />
                    </button>
                    <button
                      onClick={async () => {
                        if (confirm(`Delete FAQ: "${faq.question}"?`)) {
                          await deleteFaq(faq.id);
                          await loadAllData();
                          showToast('FAQ deleted.');
                        }
                      }}
                      className="p-2 rounded-lg text-slate-400 hover:text-red-500 hover:bg-red-50"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* SITE CONTENT & BRANDING TAB */}
        {activeTab === 'content' && (
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
              <h2 className="font-serif text-2xl font-bold text-slate-900">Website Content & Contact Information</h2>
              <p className="text-slate-500 text-sm mt-1">
                Edit core website headlines, welcome text, and contact channels without editing code.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Homepage Content */}
              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
                <h3 className="font-serif text-lg font-bold text-slate-900 border-b pb-3">Homepage Content</h3>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Hero Headline
                  </label>
                  <input 
                    type="text" 
                    value={siteContent['hero_title'] || ''}
                    onChange={e => setSiteContent({ ...siteContent, hero_title: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('hero_title', siteContent['hero_title'])}
                    >
                      Save Headline
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Hero Subtitle
                  </label>
                  <textarea 
                    rows={3}
                    value={siteContent['hero_subtitle'] || ''}
                    onChange={e => setSiteContent({ ...siteContent, hero_subtitle: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('hero_subtitle', siteContent['hero_subtitle'])}
                    >
                      Save Subtitle
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Welcome Section Message
                  </label>
                  <textarea 
                    rows={4}
                    value={siteContent['welcome_body'] || ''}
                    onChange={e => setSiteContent({ ...siteContent, welcome_body: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm leading-relaxed"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('welcome_body', siteContent['welcome_body'])}
                    >
                      Save Welcome Message
                    </Button>
                  </div>
                </div>
              </div>

              {/* Contact Channels */}
              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
                <h3 className="font-serif text-lg font-bold text-slate-900 border-b pb-3">Contact Channels</h3>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Direct Phone Number
                  </label>
                  <input 
                    type="text" 
                    value={siteContent['contact_phone'] || '+94 77 123 4567'}
                    onChange={e => setSiteContent({ ...siteContent, contact_phone: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('contact_phone', siteContent['contact_phone'])}
                    >
                      Save Phone
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    WhatsApp Number (International format with country code)
                  </label>
                  <input 
                    type="text" 
                    value={siteContent['contact_whatsapp'] || '+94771234567'}
                    onChange={e => setSiteContent({ ...siteContent, contact_whatsapp: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('contact_whatsapp', siteContent['contact_whatsapp'])}
                    >
                      Save WhatsApp
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Support Email Address
                  </label>
                  <input 
                    type="text" 
                    value={siteContent['contact_email'] || 'hello@serendibdays.com'}
                    onChange={e => setSiteContent({ ...siteContent, contact_email: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('contact_email', siteContent['contact_email'])}
                    >
                      Save Email
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                    Office Address / Location
                  </label>
                  <input 
                    type="text" 
                    value={siteContent['contact_address'] || 'Colombo, Sri Lanka'}
                    onChange={e => setSiteContent({ ...siteContent, contact_address: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                  />
                  <div className="mt-2 text-right">
                    <Button 
                      size="sm" 
                      onClick={() => handleSaveContent('contact_address', siteContent['contact_address'])}
                    >
                      Save Address
                    </Button>
                  </div>
                </div>
              </div>

              {/* Security & Password Management */}
              <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
                <div className="flex items-center gap-2 border-b pb-3">
                  <Lock className="w-5 h-5 text-primary" />
                  <h3 className="font-serif text-lg font-bold text-slate-900">Administrator Security & Password</h3>
                </div>

                <p className="text-sm text-slate-500">
                  You can change the administrator password below. The new password takes effect immediately.
                </p>

                <form onSubmit={handleChangePassword} className="max-w-xl space-y-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                      Current Password
                    </label>
                    <input 
                      type="password"
                      placeholder="Enter current password"
                      value={currentPassInput}
                      onChange={e => setCurrentPassInput(e.target.value)}
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                        New Password
                      </label>
                      <div className="relative">
                        <input 
                          type={showNewPass ? 'text' : 'password'}
                          placeholder="Enter new password"
                          value={newPassInput}
                          onChange={e => setNewPassInput(e.target.value)}
                          className="w-full pl-4 pr-10 py-2.5 rounded-xl border border-slate-300 text-sm"
                        />
                        <button
                          type="button"
                          onClick={() => setShowNewPass(!showNewPass)}
                          className="absolute right-3 top-3 text-slate-400 hover:text-slate-600"
                        >
                          {showNewPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                        </button>
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1">
                        Confirm New Password
                      </label>
                      <input 
                        type="password"
                        placeholder="Re-enter new password"
                        value={confirmPassInput}
                        onChange={e => setConfirmPassInput(e.target.value)}
                        className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                      />
                    </div>
                  </div>

                  {passChangeError && (
                    <div className="p-3 bg-red-50 text-red-600 rounded-lg text-xs flex items-center gap-2">
                      <AlertCircle className="w-4 h-4 shrink-0" />
                      <span>{passChangeError}</span>
                    </div>
                  )}

                  {passChangeSuccess && (
                    <div className="p-3 bg-emerald-50 text-emerald-700 rounded-lg text-xs flex items-center gap-2">
                      <Check className="w-4 h-4 shrink-0" />
                      <span>{passChangeSuccess}</span>
                    </div>
                  )}

                  <div className="pt-2">
                    <Button type="submit" size="sm">
                      Update Administrator Password
                    </Button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        )}

        {/* DATABASE SYNC TAB */}
        {activeTab === 'database' && (
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
              <h2 className="font-serif text-2xl font-bold text-slate-900">Supabase CMS & Migration Studio</h2>
              <p className="text-slate-500 text-sm mt-1">
                Your database migration file <code className="bg-slate-100 px-2 py-0.5 rounded text-primary font-bold">supabase/complete_seed_all.sql</code> contains all 25 packages, 75 tiers, 111 itinerary days, testimonials, and FAQs.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
                <h3 className="font-serif text-lg font-bold text-slate-900">How to Apply or Refresh Migration in Supabase:</h3>
                
                <ol className="list-decimal list-inside space-y-3 text-sm text-slate-600 leading-relaxed">
                  <li>
                    Open your Supabase Project dashboard (<a href="https://supabase.com/dashboard" target="_blank" rel="noreferrer" className="text-primary font-semibold underline">supabase.com/dashboard</a>).
                  </li>
                  <li>
                    Navigate to the <strong>SQL Editor</strong> tab on the left navigation.
                  </li>
                  <li>
                    Click <strong>+ New Query</strong>.
                  </li>
                  <li>
                    Copy the complete contents of <code className="bg-slate-100 px-1.5 py-0.5 rounded font-mono text-xs">supabase/complete_seed_all.sql</code> and paste into the editor.
                  </li>
                  <li>
                    Click <strong>Run</strong>. All tables, RLS policies, packages, and content will be synced cleanly.
                  </li>
                </ol>

                <div className="p-4 bg-teal-50 border border-teal-200 rounded-xl text-teal-900 text-xs">
                  <strong>Zero-Downtime Guarantee:</strong> The frontend is fully connected and features resilient multi-layer caching with automatic fallback. Edits saved in this CMS are instantly reflected on public pages!
                </div>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
                <h3 className="font-serif text-lg font-bold text-slate-900">Backup & Recovery</h3>
                <p className="text-sm text-slate-500">
                  You can download the full current JSON backup of all 25 packages at any time.
                </p>

                <button 
                  onClick={() => {
                    const jsonStr = JSON.stringify(packages, null, 2);
                    const dataUri = 'data:application/json;charset=utf-8,' + encodeURIComponent(jsonStr);
                    const a = document.createElement('a');
                    a.href = dataUri;
                    a.download = `serendib_days_packages_backup_${new Date().toISOString().slice(0, 10)}.json`;
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    showToast('Backup JSON downloaded');
                  }}
                  className="w-full py-3 px-4 bg-slate-900 hover:bg-slate-800 text-white font-medium rounded-xl text-sm flex items-center justify-center gap-2 transition-colors shadow-sm"
                >
                  <Database className="w-4 h-4" />
                  <span>Download Full JSON Export</span>
                </button>
              </div>
            </div>
          </div>
        )}

      </main>

      {/* PACKAGE EDITOR MODAL / DRAWER */}
      {isEditingPackage && (
        <div className="fixed inset-0 z-50 overflow-y-auto bg-slate-900/60 backdrop-blur-sm flex justify-center p-4 sm:p-6 lg:p-10">
          <div className="bg-white rounded-3xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto border border-slate-200 flex flex-col">
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b border-slate-200 p-6 flex items-center justify-between z-10">
              <div>
                <h2 className="font-serif text-2xl font-bold text-slate-900">
                  {editingPkg.id && packages.some(p => p.id === editingPkg.id) ? 'Edit Tour Package' : 'Create New Tour Package'}
                </h2>
                <p className="text-xs text-slate-500 mt-1">
                  Adjust package title, itinerary, pricing tiers, and gallery images.
                </p>
              </div>
              <button 
                onClick={() => setIsEditingPackage(false)}
                className="p-2 text-slate-400 hover:text-slate-700 rounded-full hover:bg-slate-100"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-6 sm:p-8 space-y-8 flex-1">
              
              {/* Basic Information */}
              <div className="space-y-4">
                <h3 className="font-serif text-lg font-bold text-slate-900 border-b pb-2">1. Basic Details</h3>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Package Title *</label>
                    <input 
                      type="text" 
                      value={editingPkg.title || ''}
                      onChange={e => setEditingPkg({ ...editingPkg, title: e.target.value })}
                      placeholder="e.g. 5-Day Sri Lanka Highlights Tour"
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-1">URL Slug</label>
                    <input 
                      type="text" 
                      value={editingPkg.slug || ''}
                      onChange={e => setEditingPkg({ ...editingPkg, slug: e.target.value })}
                      placeholder="e.g. 5-day-sri-lanka-highlights"
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-mono text-slate-600"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Duration (Days)</label>
                    <input 
                      type="number" 
                      min="1"
                      max="30"
                      value={editingPkg.duration_days || 1}
                      onChange={e => setEditingPkg({ ...editingPkg, duration_days: parseInt(e.target.value) || 1 })}
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Best Time to Visit</label>
                    <input 
                      type="text" 
                      value={editingPkg.best_time || 'Year-round'}
                      onChange={e => setEditingPkg({ ...editingPkg, best_time: e.target.value })}
                      placeholder="e.g. November to April"
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Display Sort Order</label>
                    <input 
                      type="number" 
                      value={editingPkg.sort_order || 1}
                      onChange={e => setEditingPkg({ ...editingPkg, sort_order: parseInt(e.target.value) || 1 })}
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-medium"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Route Summary</label>
                  <input 
                    type="text" 
                    value={editingPkg.route || ''}
                    onChange={e => setEditingPkg({ ...editingPkg, route: e.target.value })}
                    placeholder="e.g. Airport → Sigiriya → Kandy → Nuwara Eliya → Colombo"
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                  />
                </div>

                <div className="flex gap-6 pt-2">
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input 
                      type="checkbox" 
                      checked={editingPkg.is_published !== false}
                      onChange={e => setEditingPkg({ ...editingPkg, is_published: e.target.checked })}
                      className="rounded text-primary focus:ring-primary w-4 h-4"
                    />
                    <span className="text-sm font-semibold text-slate-700">Published (Visible on Live Website)</span>
                  </label>

                  <label className="flex items-center gap-2 cursor-pointer">
                    <input 
                      type="checkbox" 
                      checked={!!editingPkg.is_featured}
                      onChange={e => setEditingPkg({ ...editingPkg, is_featured: e.target.checked })}
                      className="rounded text-primary focus:ring-primary w-4 h-4"
                    />
                    <span className="text-sm font-semibold text-slate-700">Featured on Homepage</span>
                  </label>
                </div>
              </div>

              {/* Descriptions & Media */}
              <div className="space-y-4">
                <h3 className="font-serif text-lg font-bold text-slate-900 border-b pb-2">2. Descriptions & Photography</h3>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Short Description (Card excerpt)</label>
                  <textarea 
                    rows={2}
                    value={editingPkg.short_description || ''}
                    onChange={e => setEditingPkg({ ...editingPkg, short_description: e.target.value })}
                    placeholder="Brief 1-2 sentence teaser for package cards..."
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Full Overview Description</label>
                  <textarea 
                    rows={4}
                    value={editingPkg.description || ''}
                    onChange={e => setEditingPkg({ ...editingPkg, description: e.target.value })}
                    placeholder="Comprehensive overview of the journey..."
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Cover Image URL</label>
                  <input 
                    type="text" 
                    value={editingPkg.cover_image || ''}
                    onChange={e => setEditingPkg({ ...editingPkg, cover_image: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
                  />
                  {editingPkg.cover_image && (
                    <div className="mt-2 h-36 rounded-xl overflow-hidden border border-slate-200">
                      <img src={editingPkg.cover_image} alt="Preview" className="w-full h-full object-cover" />
                    </div>
                  )}
                </div>
              </div>

              {/* Pricing Tiers */}
              <div className="space-y-4">
                <h3 className="font-serif text-lg font-bold text-slate-900 border-b pb-2">3. Pricing Tiers (Per Person USD)</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {['essential', 'comfort', 'signature'].map((tierName, idx) => {
                    const currentTier = pkgTiers.find(t => t.tier === tierName) || {
                      tier: tierName as any,
                      price_usd: idx === 0 ? 100 : idx === 1 ? 250 : 550,
                      stay_details: '',
                      transport_details: '',
                      extras: null
                    };

                    return (
                      <div key={tierName} className="p-4 rounded-xl border border-slate-200 bg-slate-50 space-y-3">
                        <div className="flex justify-between items-center">
                          <span className="font-bold text-slate-800 uppercase text-xs">{tierName} Tier</span>
                          <span className="text-xs font-bold text-primary">${currentTier.price_usd}</span>
                        </div>

                        <div>
                          <label className="text-[10px] uppercase font-bold text-slate-500">Price (USD)</label>
                          <input 
                            type="number"
                            value={currentTier.price_usd}
                            onChange={e => {
                              const val = parseFloat(e.target.value) || 0;
                              setPkgTiers(prev => {
                                const copy = [...prev];
                                const tIdx = copy.findIndex(t => t.tier === tierName);
                                if (tIdx >= 0) copy[tIdx].price_usd = val;
                                else copy.push({ tier: tierName as any, price_usd: val, stay_details: '', transport_details: '' });
                                return copy;
                              });
                            }}
                            className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-sm font-bold text-primary"
                          />
                        </div>

                        <div>
                          <label className="text-[10px] uppercase font-bold text-slate-500">Accommodation</label>
                          <input 
                            type="text"
                            value={currentTier.stay_details || ''}
                            onChange={e => {
                              const val = e.target.value;
                              setPkgTiers(prev => {
                                const copy = [...prev];
                                const tIdx = copy.findIndex(t => t.tier === tierName);
                                if (tIdx >= 0) copy[tIdx].stay_details = val;
                                else copy.push({ tier: tierName as any, price_usd: 0, stay_details: val, transport_details: '' });
                                return copy;
                              });
                            }}
                            placeholder="e.g. 4★ boutique hotels"
                            className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-xs"
                          />
                        </div>

                        <div>
                          <label className="text-[10px] uppercase font-bold text-slate-500">Transport</label>
                          <input 
                            type="text"
                            value={currentTier.transport_details || ''}
                            onChange={e => {
                              const val = e.target.value;
                              setPkgTiers(prev => {
                                const copy = [...prev];
                                const tIdx = copy.findIndex(t => t.tier === tierName);
                                if (tIdx >= 0) copy[tIdx].transport_details = val;
                                else copy.push({ tier: tierName as any, price_usd: 0, stay_details: '', transport_details: val });
                                return copy;
                              });
                            }}
                            placeholder="e.g. Private SUV"
                            className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-xs"
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Itinerary Days */}
              <div className="space-y-4">
                <div className="flex justify-between items-center border-b pb-2">
                  <h3 className="font-serif text-lg font-bold text-slate-900">4. Itinerary Planner ({pkgDays.length} Days)</h3>
                  <Button 
                    size="sm"
                    variant="outline"
                    onClick={() => {
                      setPkgDays([
                        ...pkgDays,
                        {
                          day_number: pkgDays.length + 1,
                          title: `Day ${pkgDays.length + 1}`,
                          description: '',
                          overnight_location: 'Check route'
                        }
                      ]);
                    }}
                    className="flex items-center gap-1.5"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Add Day</span>
                  </Button>
                </div>

                <div className="space-y-3">
                  {pkgDays.map((day, idx) => (
                    <div key={idx} className="p-4 rounded-xl border border-slate-200 bg-white space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-primary text-sm">Day {idx + 1}</span>
                        {pkgDays.length > 1 && (
                          <button 
                            onClick={() => {
                              const copy = pkgDays.filter((_, i) => i !== idx).map((d, i) => ({ ...d, day_number: i + 1 }));
                              setPkgDays(copy);
                            }}
                            className="text-xs text-red-500 hover:underline"
                          >
                            Remove Day
                          </button>
                        )}
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div>
                          <label className="text-[10px] uppercase font-bold text-slate-500">Day Title</label>
                          <input 
                            type="text"
                            value={day.title || ''}
                            onChange={e => {
                              const val = e.target.value;
                              setPkgDays(prev => prev.map((d, i) => i === idx ? { ...d, title: val } : d));
                            }}
                            placeholder="e.g. Ancient Sigiriya Rock Fortress"
                            className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-sm"
                          />
                        </div>
                        <div>
                          <label className="text-[10px] uppercase font-bold text-slate-500">Overnight Location</label>
                          <input 
                            type="text"
                            value={day.overnight_location || ''}
                            onChange={e => {
                              const val = e.target.value;
                              setPkgDays(prev => prev.map((d, i) => i === idx ? { ...d, overnight_location: val } : d));
                            }}
                            placeholder="e.g. Sigiriya or Habarana"
                            className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-sm"
                          />
                        </div>
                      </div>

                      <div>
                        <label className="text-[10px] uppercase font-bold text-slate-500">Day Description & Activities</label>
                        <textarea 
                          rows={2}
                          value={day.description || ''}
                          onChange={e => {
                            const val = e.target.value;
                            setPkgDays(prev => prev.map((d, i) => i === idx ? { ...d, description: val } : d));
                          }}
                          className="w-full px-3 py-1.5 rounded-lg border border-slate-300 text-xs"
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

            </div>

            {/* Modal Footer */}
            <div className="sticky bottom-0 bg-white border-t border-slate-200 p-6 flex items-center justify-end gap-3 z-10">
              <Button variant="outline" onClick={() => setIsEditingPackage(false)}>
                Cancel
              </Button>
              <Button onClick={handleSavePackage} disabled={loading} className="px-8">
                {loading ? 'Saving...' : 'Save & Publish Package'}
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* TESTIMONIAL MODAL */}
      {isEditingTestimonial && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl space-y-4">
            <h3 className="font-serif text-xl font-bold text-slate-900">
              {editingTestimonial.id ? 'Edit Review' : 'Add New Review'}
            </h3>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Guest Name(s)</label>
              <input 
                type="text" 
                value={editingTestimonial.name || ''}
                onChange={e => setEditingTestimonial({ ...editingTestimonial, name: e.target.value })}
                placeholder="e.g. Sarah & Mark"
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Country</label>
              <input 
                type="text" 
                value={editingTestimonial.country || ''}
                onChange={e => setEditingTestimonial({ ...editingTestimonial, country: e.target.value })}
                placeholder="e.g. United Kingdom"
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Rating (1 to 5 Stars)</label>
              <select 
                value={editingTestimonial.rating || 5}
                onChange={e => setEditingTestimonial({ ...editingTestimonial, rating: parseInt(e.target.value) })}
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
              >
                <option value={5}>5 Stars ★★★★★</option>
                <option value={4}>4 Stars ★★★★☆</option>
                <option value={3}>3 Stars ★★★☆☆</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Testimonial Quote</label>
              <textarea 
                rows={3}
                value={editingTestimonial.text || ''}
                onChange={e => setEditingTestimonial({ ...editingTestimonial, text: e.target.value })}
                placeholder="What did they love about their trip?"
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
              />
            </div>

            <div className="flex justify-end gap-3 pt-3">
              <Button variant="outline" onClick={() => setIsEditingTestimonial(false)}>Cancel</Button>
              <Button onClick={handleSaveTestimonial}>Save Review</Button>
            </div>
          </div>
        </div>
      )}

      {/* FAQ MODAL */}
      {isEditingFaq && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 max-w-lg w-full shadow-2xl space-y-4">
            <h3 className="font-serif text-xl font-bold text-slate-900">
              {editingFaq.id ? 'Edit FAQ' : 'Add FAQ'}
            </h3>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Question</label>
              <input 
                type="text" 
                value={editingFaq.question || ''}
                onChange={e => setEditingFaq({ ...editingFaq, question: e.target.value })}
                placeholder="e.g. Do I need a visa for Sri Lanka?"
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm font-semibold"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Answer</label>
              <textarea 
                rows={4}
                value={editingFaq.answer || ''}
                onChange={e => setEditingFaq({ ...editingFaq, answer: e.target.value })}
                placeholder="Clear, helpful answer for travelers..."
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm leading-relaxed"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Sort Order</label>
              <input 
                type="number" 
                value={editingFaq.sort_order || 1}
                onChange={e => setEditingFaq({ ...editingFaq, sort_order: parseInt(e.target.value) || 1 })}
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm"
              />
            </div>

            <div className="flex justify-end gap-3 pt-3">
              <Button variant="outline" onClick={() => setIsEditingFaq(false)}>Cancel</Button>
              <Button onClick={handleSaveFaq}>Save FAQ</Button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
