# Serendib Days Website

A simple, professional, launch-ready tourism website for "Serendib Days", a Sri Lankan tour company.

## Tech Stack
- React 18 + Vite + TypeScript
- React Router v6
- Tailwind CSS
- Supabase (PostgreSQL)
- TanStack Query
- React Hook Form + Zod

## Local Setup Instructions

1. **Install Dependencies**
   Run `npm install` to install all required packages.

2. **Environment Variables**
   Create a `.env` file in the root directory and add your Supabase credentials:
   ```
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   VITE_WHATSAPP_NUMBER=your_whatsapp_number
   ```

3. **Database Setup**
   Go to your Supabase project dashboard, open the SQL Editor, and paste the contents of `supabase/setup.sql`. Run the script to create all necessary tables, Row Level Security (RLS) policies, and seed data.

4. **Start the Development Server**
   Run `npm run dev` to start the app locally.
