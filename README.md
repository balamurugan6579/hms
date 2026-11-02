# Clinic Management System

## Setup
1. Copy `.env.example` to `.env.local` and set `VITE_SUPABASE_URL` and `VITE_SUPABASE_KEY` from your Supabase project settings.
   - Use the Project URL (for example, `https://your-project-ref.supabase.co`) and a publishable key. Never put a Secret or Service Role key in the frontend.
   - `.env` and `.env.local` are ignored by Git; do not commit credentials.
2. Run `npm install`.
3. Run `npm run dev` to start the application.

## Supabase database setup
1. In the new project's Supabase Dashboard, open **SQL Editor** and run [`database/migrations/20261102100000_hms_initial.sql`](./database/migrations/20261102100000_hms_initial.sql) once. It creates the HMS tables, indexes, role-based RLS policies, and private storage buckets without dropping existing data or inserting demo records.
2. Create the first user in **Authentication → Users**. Use the bootstrap SQL comments at the end of the migration to promote that user to administrator.
3. Configure GitHub Actions repository secrets `VITE_SUPABASE_URL` and `VITE_SUPABASE_KEY` before deploying through GitHub Pages.

The old Supabase project's patient records, accounts, and files cannot be recovered or migrated without access to that project. Existing user passwords are not portable; users must be created again in the new project's Auth service.

The face-recognition Python scanner currently calls the Data API with the publishable key. The migration deliberately restricts attendance writes to authenticated users, so the scanner needs a trusted server-side/Edge Function integration before it can write attendance. Do not make attendance anonymously writable or put a secret/service-role key in the browser.

## Features
- **Admin**: Manage Staff, Patients, Inventory, Reports.
- **Doctor**: View appointments, Add Diagnosis, Prescribe Meds (Real-time stock deduction).
- **Staff**: Register Patients, Book Appointments, Update Stock.
- **Patient**: View status, Prescriptions.

## Supabase Tables Required
Ensure your Supabase project has the following tables:
- `profiles` (id, name, email, role)
- `doctors` (id, name, specialization, availability)
- `patients` (id, name, age, gender, phone, medical_history)
- `appointments` (id, patient_id, doctor_id, appointment_date, status)
- `medicines` (id, medicine_name, stock_quantity, expiry_date, price)
- `medicine_usage` (id, patient_id, medicine_id, quantity_used, date)

## Tech Stack
- Frontend: React + Vite + Tailwind CSS
- Backend: Supabase (Auth + Database + Realtime)
