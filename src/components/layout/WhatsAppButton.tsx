import React from 'react';
import { MessageCircle } from 'lucide-react';

export const WhatsAppButton = () => {
  const whatsappNumber = import.meta.env.VITE_WHATSAPP_NUMBER || '+94771234567';
  
  return (
    <a
      href={`https://wa.me/${whatsappNumber.replace(/[^0-9]/g, '')}`}
      target="_blank"
      rel="noopener noreferrer"
      className="fixed bottom-6 right-6 z-50 flex h-14 w-14 items-center justify-center rounded-full bg-[#25D366] text-white shadow-lg transition-transform hover:scale-110 focus:outline-none focus:ring-4 focus:ring-[#25D366]/50"
      aria-label="Chat on WhatsApp"
    >
      <MessageCircle className="h-7 w-7" />
    </a>
  );
};
