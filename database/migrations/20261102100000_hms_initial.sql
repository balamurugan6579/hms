-- HMS initial schema for a new Supabase project.
-- Safe to re-run: creates missing objects and does not drop application data.

CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    name text,
    full_name text,
    email text,
    phone text,
    role text NOT NULL DEFAULT 'patient'
        CHECK (role IN ('admin', 'doctor', 'receptionist', 'patient', 'worker', 'staff')),
    specialization text,
    avatar_url text,
    address text,
    per_day_salary numeric(12, 2) NOT NULL DEFAULT 0,
    salary numeric(12, 2) NOT NULL DEFAULT 0,
    payment_status text NOT NULL DEFAULT 'unpaid',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.admins (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    email text,
    phone text,
    address text,
    permissions jsonb NOT NULL DEFAULT '{"all": true}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.doctors (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
    profile_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    name text,
    full_name text,
    email text,
    phone text,
    address text,
    specialization text,
    qualification text,
    experience_years integer,
    consultation_fee numeric(12, 2),
    availability text,
    available_days text[],
    available_from time,
    available_to time,
    is_active boolean NOT NULL DEFAULT true,
    per_day_salary numeric(12, 2) NOT NULL DEFAULT 0,
    salary numeric(12, 2) NOT NULL DEFAULT 0,
    payment_status text NOT NULL DEFAULT 'unpaid',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.patients (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
    name text,
    full_name text,
    email text,
    phone text,
    date_of_birth date,
    age integer,
    gender text,
    blood_group text,
    address text,
    emergency_contact text,
    medical_history text,
    allergies text,
    patient_type text NOT NULL DEFAULT 'permanent',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.staff (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    email text,
    role text NOT NULL DEFAULT 'Receptionist',
    phone text,
    address text,
    place text,
    shift text,
    salary numeric(12, 2) NOT NULL DEFAULT 0,
    per_day_salary numeric(12, 2) NOT NULL DEFAULT 0,
    payment_status text NOT NULL DEFAULT 'unpaid',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.workers (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    role text NOT NULL,
    status text NOT NULL DEFAULT 'active',
    email text,
    phone text,
    address text,
    join_date date NOT NULL DEFAULT CURRENT_DATE,
    face_descriptor jsonb,
    salary numeric(12, 2) NOT NULL DEFAULT 0,
    per_day_salary numeric(12, 2) NOT NULL DEFAULT 0,
    payment_status text NOT NULL DEFAULT 'unpaid',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.appointments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id uuid NOT NULL REFERENCES public.doctors(id) ON DELETE RESTRICT,
    appointment_date date NOT NULL DEFAULT CURRENT_DATE,
    appointment_time time NOT NULL DEFAULT LOCALTIME,
    status text NOT NULL DEFAULT 'scheduled'
        CHECK (status IN ('scheduled', 'pending', 'confirmed', 'completed', 'cancelled', 'no-show')),
    reason text,
    notes text,
    created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.medical_records (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE SET NULL,
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    diagnosis text,
    prescription text,
    treatment text,
    vital_signs jsonb,
    lab_results jsonb,
    follow_up_date date,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.medicines (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_name text NOT NULL,
    medicine_type text,
    stock_quantity integer NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    manufacture_date date,
    stock_coming_date date,
    expiry_date date,
    price numeric(12, 2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.prescriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE SET NULL,
    patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.prescription_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id uuid NOT NULL REFERENCES public.prescriptions(id) ON DELETE CASCADE,
    medicine_id uuid REFERENCES public.medicines(id) ON DELETE SET NULL,
    quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
    instructions text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.medicine_usage (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid REFERENCES public.patients(id) ON DELETE SET NULL,
    medicine_id uuid REFERENCES public.medicines(id) ON DELETE SET NULL,
    quantity_used integer NOT NULL DEFAULT 1 CHECK (quantity_used > 0),
    date timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.attendance (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
    check_in timestamptz,
    check_out timestamptz,
    in_time timestamptz,
    out_time timestamptz,
    status text,
    date date NOT NULL DEFAULT CURRENT_DATE,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT attendance_check_out_after_check_in
        CHECK (check_out IS NULL OR check_in IS NULL OR check_out >= check_in)
);

CREATE TABLE IF NOT EXISTS public.bills (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid REFERENCES public.patients(id) ON DELETE SET NULL,
    total_amount numeric(12, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    status text NOT NULL DEFAULT 'pending',
    items jsonb NOT NULL DEFAULT '[]'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bill_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_id uuid NOT NULL REFERENCES public.bills(id) ON DELETE CASCADE,
    item_name text,
    quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price numeric(12, 2) NOT NULL DEFAULT 0 CHECK (unit_price >= 0),
    subtotal numeric(12, 2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.hospital_settings (
    id bigint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    hospital_name text,
    address text,
    contact_number text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_doctors_user_id ON public.doctors(user_id);
CREATE INDEX IF NOT EXISTS idx_patients_user_id ON public.patients(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_patient_date ON public.appointments(patient_id, appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_date ON public.appointments(doctor_id, appointment_date);
CREATE INDEX IF NOT EXISTS idx_medical_records_patient ON public.medical_records(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_created ON public.prescriptions(patient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_prescription_items_prescription ON public.prescription_items(prescription_id);
CREATE INDEX IF NOT EXISTS idx_medicine_usage_patient ON public.medicine_usage(patient_id);
CREATE INDEX IF NOT EXISTS idx_attendance_user_date ON public.attendance(user_id, date);
CREATE INDEX IF NOT EXISTS idx_bills_patient_created ON public.bills(patient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_bill_items_bill ON public.bill_items(bill_id);

CREATE OR REPLACE FUNCTION public.hms_has_role(requested_roles text[])
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles AS p
        WHERE p.id = (SELECT auth.uid())
          AND p.role = ANY (requested_roles)
    );
$$;

CREATE OR REPLACE FUNCTION public.hms_can_access_patient(patient_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT
        public.hms_has_role(ARRAY['admin']::text[])
        OR EXISTS (
            SELECT 1
            FROM public.patients AS p
            WHERE p.id = patient_id
              AND (p.user_id = (SELECT auth.uid()) OR p.id = (SELECT auth.uid()))
        )
        OR (
            public.hms_has_role(ARRAY['doctor']::text[])
            AND EXISTS (
                SELECT 1
                FROM public.appointments AS a
                JOIN public.doctors AS d ON d.id = a.doctor_id
                WHERE a.patient_id = $1
                  AND d.user_id = (SELECT auth.uid())
            )
        );
$$;

CREATE OR REPLACE FUNCTION public.hms_can_access_patient_folder(patient_folder text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.patients AS p
        WHERE p.id::text = patient_folder
          AND public.hms_can_access_patient(p.id)
    );
$$;

CREATE OR REPLACE FUNCTION public.hms_can_access_prescription(prescription_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.prescriptions AS rx
        LEFT JOIN public.doctors AS d ON d.id = rx.doctor_id
        WHERE rx.id = prescription_id
          AND (
              public.hms_can_access_patient(rx.patient_id)
              OR d.user_id = (SELECT auth.uid())
          )
    );
$$;

CREATE OR REPLACE VIEW public.patient_directory
WITH (security_barrier = true)
AS
SELECT p.id, p.user_id, p.name, p.full_name, p.email, p.phone
FROM public.patients AS p
WHERE public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
   OR public.hms_can_access_patient(p.id);

REVOKE ALL ON FUNCTION public.hms_has_role(text[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.hms_can_access_patient(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.hms_can_access_patient_folder(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.hms_can_access_prescription(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.hms_has_role(text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.hms_can_access_patient(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.hms_can_access_patient_folder(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.hms_can_access_prescription(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.hms_sync_profile_ids()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.name IS DISTINCT FROM OLD.name THEN
            NEW.full_name := NEW.name;
        ELSIF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
            NEW.name := NEW.full_name;
        END IF;
    END IF;
    IF NEW.id IS NULL THEN
        NEW.id := NEW.user_id;
    END IF;
    IF NEW.user_id IS NULL THEN
        NEW.user_id := NEW.id;
    END IF;
    IF NEW.name IS NULL THEN
        NEW.name := NEW.full_name;
    END IF;
    IF NEW.full_name IS NULL THEN
        NEW.full_name := NEW.name;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS hms_sync_profile_ids ON public.profiles;
CREATE TRIGGER hms_sync_profile_ids
BEFORE INSERT OR UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.hms_sync_profile_ids();

CREATE OR REPLACE FUNCTION public.hms_sync_display_names()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.name IS DISTINCT FROM OLD.name THEN
            NEW.full_name := NEW.name;
        ELSIF NEW.full_name IS DISTINCT FROM OLD.full_name THEN
            NEW.name := NEW.full_name;
        END IF;
    END IF;
    IF NEW.name IS NULL THEN
        NEW.name := NEW.full_name;
    END IF;
    IF NEW.full_name IS NULL THEN
        NEW.full_name := NEW.name;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS hms_sync_doctor_names ON public.doctors;
CREATE TRIGGER hms_sync_doctor_names
BEFORE INSERT OR UPDATE ON public.doctors
FOR EACH ROW EXECUTE FUNCTION public.hms_sync_display_names();

DROP TRIGGER IF EXISTS hms_sync_patient_names ON public.patients;
CREATE TRIGGER hms_sync_patient_names
BEFORE INSERT OR UPDATE ON public.patients
FOR EACH ROW EXECUTE FUNCTION public.hms_sync_display_names();

CREATE OR REPLACE FUNCTION public.hms_handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    display_name text;
BEGIN
    display_name := COALESCE(
        NEW.raw_user_meta_data ->> 'displayName',
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'name',
        split_part(COALESCE(NEW.email, ''), '@', 1)
    );

    INSERT INTO public.profiles (id, user_id, name, full_name, email, role)
    VALUES (NEW.id, NEW.id, display_name, display_name, NEW.email, 'patient')
    ON CONFLICT (id) DO UPDATE
        SET email = EXCLUDED.email,
            updated_at = now();

    IF COALESCE(NEW.raw_user_meta_data ->> 'role', 'patient') = 'patient' THEN
        INSERT INTO public.patients (
            id, user_id, name, full_name, email, phone, address, gender,
            date_of_birth, blood_group, medical_history, allergies, emergency_contact
        )
        VALUES (
            NEW.id,
            NEW.id,
            display_name,
            display_name,
            NEW.email,
            NEW.raw_user_meta_data ->> 'phone',
            NEW.raw_user_meta_data ->> 'address',
            NEW.raw_user_meta_data ->> 'gender',
            CASE
                WHEN NEW.raw_user_meta_data ->> 'date_of_birth' ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                THEN (NEW.raw_user_meta_data ->> 'date_of_birth')::date
                ELSE NULL
            END,
            NEW.raw_user_meta_data ->> 'blood_group',
            NEW.raw_user_meta_data ->> 'medical_history',
            NEW.raw_user_meta_data ->> 'allergies',
            NEW.raw_user_meta_data ->> 'emergency_contact'
        )
        ON CONFLICT (user_id) DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.hms_handle_new_auth_user() FROM PUBLIC;
DROP TRIGGER IF EXISTS hms_on_auth_user_created ON auth.users;
CREATE TRIGGER hms_on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.hms_handle_new_auth_user();

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescription_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicine_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bill_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hospital_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS hms_profiles_select ON public.profiles;
CREATE POLICY hms_profiles_select ON public.profiles FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin']::text[]));
DROP POLICY IF EXISTS hms_profiles_insert ON public.profiles;
CREATE POLICY hms_profiles_insert ON public.profiles FOR INSERT TO authenticated
WITH CHECK (
    (id = (SELECT auth.uid()) AND role = 'patient')
    OR public.hms_has_role(ARRAY['admin']::text[])
);
DROP POLICY IF EXISTS hms_profiles_update ON public.profiles;
CREATE POLICY hms_profiles_update ON public.profiles FOR UPDATE TO authenticated
USING (id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (
    (id = (SELECT auth.uid()) AND role = 'patient')
    OR public.hms_has_role(ARRAY['admin']::text[])
);

DROP POLICY IF EXISTS hms_admins_select ON public.admins;
CREATE POLICY hms_admins_select ON public.admins FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin']::text[]));
DROP POLICY IF EXISTS hms_admins_manage ON public.admins;
CREATE POLICY hms_admins_manage ON public.admins FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin']::text[]));

DROP POLICY IF EXISTS hms_doctors_select ON public.doctors;
CREATE POLICY hms_doctors_select ON public.doctors FOR SELECT TO authenticated
USING (is_active OR user_id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin']::text[]));
DROP POLICY IF EXISTS hms_doctors_manage ON public.doctors;
CREATE POLICY hms_doctors_manage ON public.doctors FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin']::text[]));

DROP POLICY IF EXISTS hms_patients_select ON public.patients;
CREATE POLICY hms_patients_select ON public.patients FOR SELECT TO authenticated
USING (public.hms_can_access_patient(id));
DROP POLICY IF EXISTS hms_patients_insert ON public.patients;
CREATE POLICY hms_patients_insert ON public.patients FOR INSERT TO authenticated
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR user_id = (SELECT auth.uid())
    OR id = (SELECT auth.uid())
);
DROP POLICY IF EXISTS hms_patients_update ON public.patients;
CREATE POLICY hms_patients_update ON public.patients FOR UPDATE TO authenticated
USING (
    public.hms_has_role(ARRAY['admin']::text[])
    OR public.hms_can_access_patient(id)
)
WITH CHECK (
    public.hms_has_role(ARRAY['admin']::text[])
    OR public.hms_can_access_patient(id)
);
DROP POLICY IF EXISTS hms_patients_delete ON public.patients;
CREATE POLICY hms_patients_delete ON public.patients FOR DELETE TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]));

DROP POLICY IF EXISTS hms_staff_select ON public.staff;
CREATE POLICY hms_staff_select ON public.staff FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin']::text[]));
DROP POLICY IF EXISTS hms_staff_manage ON public.staff;
CREATE POLICY hms_staff_manage ON public.staff FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin']::text[]));

DROP POLICY IF EXISTS hms_workers_select ON public.workers;
CREATE POLICY hms_workers_select ON public.workers FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));
DROP POLICY IF EXISTS hms_workers_manage ON public.workers;
CREATE POLICY hms_workers_manage ON public.workers FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin']::text[]));

DROP POLICY IF EXISTS hms_appointments_select ON public.appointments;
CREATE POLICY hms_appointments_select ON public.appointments FOR SELECT TO authenticated
USING (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR public.hms_can_access_patient(patient_id)
    OR EXISTS (
        SELECT 1 FROM public.doctors AS d
        WHERE d.id = doctor_id AND d.user_id = (SELECT auth.uid())
    )
);
DROP POLICY IF EXISTS hms_appointments_insert ON public.appointments;
CREATE POLICY hms_appointments_insert ON public.appointments FOR INSERT TO authenticated
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR public.hms_can_access_patient(patient_id)
    OR EXISTS (
        SELECT 1 FROM public.doctors AS d
        WHERE d.id = doctor_id AND d.user_id = (SELECT auth.uid())
    )
);
DROP POLICY IF EXISTS hms_appointments_update ON public.appointments;
CREATE POLICY hms_appointments_update ON public.appointments FOR UPDATE TO authenticated
USING (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR EXISTS (
        SELECT 1 FROM public.doctors AS d
        WHERE d.id = doctor_id AND d.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR EXISTS (
        SELECT 1 FROM public.doctors AS d
        WHERE d.id = doctor_id AND d.user_id = (SELECT auth.uid())
    )
);
DROP POLICY IF EXISTS hms_appointments_delete ON public.appointments;
CREATE POLICY hms_appointments_delete ON public.appointments FOR DELETE TO authenticated
USING (public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));

DROP POLICY IF EXISTS hms_medical_records_select ON public.medical_records;
CREATE POLICY hms_medical_records_select ON public.medical_records FOR SELECT TO authenticated
USING (public.hms_can_access_patient(patient_id));
DROP POLICY IF EXISTS hms_medical_records_insert ON public.medical_records;
CREATE POLICY hms_medical_records_insert ON public.medical_records FOR INSERT TO authenticated
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND public.hms_can_access_patient(patient_id)
);
DROP POLICY IF EXISTS hms_medical_records_update ON public.medical_records;
CREATE POLICY hms_medical_records_update ON public.medical_records FOR UPDATE TO authenticated
USING (public.hms_has_role(ARRAY['admin', 'doctor']::text[]) AND public.hms_can_access_patient(patient_id))
WITH CHECK (public.hms_has_role(ARRAY['admin', 'doctor']::text[]) AND public.hms_can_access_patient(patient_id));

DROP POLICY IF EXISTS hms_medicines_select ON public.medicines;
CREATE POLICY hms_medicines_select ON public.medicines FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS hms_medicines_manage ON public.medicines;
CREATE POLICY hms_medicines_manage ON public.medicines FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin', 'doctor', 'receptionist']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin', 'doctor', 'receptionist']::text[]));

DROP POLICY IF EXISTS hms_prescriptions_select ON public.prescriptions;
CREATE POLICY hms_prescriptions_select ON public.prescriptions FOR SELECT TO authenticated
USING (public.hms_can_access_patient(patient_id));
DROP POLICY IF EXISTS hms_prescriptions_manage ON public.prescriptions;
CREATE POLICY hms_prescriptions_manage ON public.prescriptions FOR ALL TO authenticated
USING (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND (public.hms_has_role(ARRAY['admin']::text[]) OR public.hms_can_access_patient(patient_id))
)
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND (public.hms_has_role(ARRAY['admin']::text[]) OR public.hms_can_access_patient(patient_id))
);

DROP POLICY IF EXISTS hms_prescription_items_select ON public.prescription_items;
CREATE POLICY hms_prescription_items_select ON public.prescription_items FOR SELECT TO authenticated
USING (public.hms_can_access_prescription(prescription_id));
DROP POLICY IF EXISTS hms_prescription_items_manage ON public.prescription_items;
CREATE POLICY hms_prescription_items_manage ON public.prescription_items FOR ALL TO authenticated
USING (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND public.hms_can_access_prescription(prescription_id)
)
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND public.hms_can_access_prescription(prescription_id)
);

DROP POLICY IF EXISTS hms_medicine_usage_select ON public.medicine_usage;
CREATE POLICY hms_medicine_usage_select ON public.medicine_usage FOR SELECT TO authenticated
USING (patient_id IS NOT NULL AND public.hms_can_access_patient(patient_id));
DROP POLICY IF EXISTS hms_medicine_usage_insert ON public.medicine_usage;
CREATE POLICY hms_medicine_usage_insert ON public.medicine_usage FOR INSERT TO authenticated
WITH CHECK (
    public.hms_has_role(ARRAY['admin', 'doctor']::text[])
    AND (patient_id IS NULL OR public.hms_can_access_patient(patient_id))
);

DROP POLICY IF EXISTS hms_attendance_select ON public.attendance;
CREATE POLICY hms_attendance_select ON public.attendance FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));
DROP POLICY IF EXISTS hms_attendance_insert ON public.attendance;
CREATE POLICY hms_attendance_insert ON public.attendance FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));
DROP POLICY IF EXISTS hms_attendance_update ON public.attendance;
CREATE POLICY hms_attendance_update ON public.attendance FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin', 'receptionist']::text[]))
WITH CHECK (user_id = (SELECT auth.uid()) OR public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));

DROP POLICY IF EXISTS hms_bills_select ON public.bills;
CREATE POLICY hms_bills_select ON public.bills FOR SELECT TO authenticated
USING (
    public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
    OR EXISTS (
        SELECT 1 FROM public.patients AS p
        WHERE p.id = patient_id
          AND (p.user_id = (SELECT auth.uid()) OR p.id = (SELECT auth.uid()))
    )
);
DROP POLICY IF EXISTS hms_bills_manage ON public.bills;
CREATE POLICY hms_bills_manage ON public.bills FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin', 'receptionist']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));

DROP POLICY IF EXISTS hms_bill_items_select ON public.bill_items;
CREATE POLICY hms_bill_items_select ON public.bill_items FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.bills AS b
        WHERE b.id = bill_id
          AND (
              public.hms_has_role(ARRAY['admin', 'receptionist']::text[])
              OR (b.patient_id IS NOT NULL AND public.hms_can_access_patient(b.patient_id))
          )
    )
);
DROP POLICY IF EXISTS hms_bill_items_manage ON public.bill_items;
CREATE POLICY hms_bill_items_manage ON public.bill_items FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin', 'receptionist']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin', 'receptionist']::text[]));

DROP POLICY IF EXISTS hms_hospital_settings_select ON public.hospital_settings;
CREATE POLICY hms_hospital_settings_select ON public.hospital_settings FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS hms_hospital_settings_manage ON public.hospital_settings;
CREATE POLICY hms_hospital_settings_manage ON public.hospital_settings FOR ALL TO authenticated
USING (public.hms_has_role(ARRAY['admin']::text[]))
WITH CHECK (public.hms_has_role(ARRAY['admin']::text[]));

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON
    public.profiles, public.admins, public.doctors, public.patients,
    public.staff, public.workers, public.appointments, public.medical_records,
    public.medicines, public.prescriptions, public.prescription_items,
    public.medicine_usage, public.attendance, public.bills, public.bill_items,
    public.hospital_settings
TO authenticated;
GRANT SELECT ON public.patient_directory TO authenticated;

INSERT INTO storage.buckets (id, name, public)
VALUES
    ('patient-documents', 'patient-documents', false),
    ('profile-images', 'profile-images', false),
    ('medical-records', 'medical-records', false),
    ('prescription-files', 'prescription-files', false)
ON CONFLICT (id) DO UPDATE SET public = false;

DROP POLICY IF EXISTS hms_storage_select ON storage.objects;
CREATE POLICY hms_storage_select ON storage.objects FOR SELECT TO authenticated
USING (
    (bucket_id = 'profile-images' AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.hms_has_role(ARRAY['admin']::text[])
    ))
    OR (
        bucket_id IN ('patient-documents', 'medical-records', 'prescription-files')
        AND (
            public.hms_has_role(ARRAY['admin']::text[])
            OR public.hms_can_access_patient_folder((storage.foldername(name))[1])
        )
    )
);
DROP POLICY IF EXISTS hms_storage_insert ON storage.objects;
CREATE POLICY hms_storage_insert ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    (bucket_id = 'profile-images' AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.hms_has_role(ARRAY['admin']::text[])
    ))
    OR (
        bucket_id IN ('patient-documents', 'medical-records', 'prescription-files')
        AND (
            public.hms_has_role(ARRAY['admin']::text[])
            OR public.hms_can_access_patient_folder((storage.foldername(name))[1])
        )
    )
);
DROP POLICY IF EXISTS hms_storage_update ON storage.objects;
CREATE POLICY hms_storage_update ON storage.objects FOR UPDATE TO authenticated
USING (
    (bucket_id = 'profile-images' AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.hms_has_role(ARRAY['admin']::text[])
    ))
    OR (
        bucket_id IN ('patient-documents', 'medical-records', 'prescription-files')
        AND (
            public.hms_has_role(ARRAY['admin']::text[])
            OR public.hms_can_access_patient_folder((storage.foldername(name))[1])
        )
    )
)
WITH CHECK (
    (bucket_id = 'profile-images' AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.hms_has_role(ARRAY['admin']::text[])
    ))
    OR (
        bucket_id IN ('patient-documents', 'medical-records', 'prescription-files')
        AND (
            public.hms_has_role(ARRAY['admin']::text[])
            OR public.hms_can_access_patient_folder((storage.foldername(name))[1])
        )
    )
);
DROP POLICY IF EXISTS hms_storage_delete ON storage.objects;
CREATE POLICY hms_storage_delete ON storage.objects FOR DELETE TO authenticated
USING (
    (bucket_id = 'profile-images' AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.hms_has_role(ARRAY['admin']::text[])
    ))
    OR (
        bucket_id IN ('patient-documents', 'medical-records', 'prescription-files')
        AND (
            public.hms_has_role(ARRAY['admin']::text[])
            OR public.hms_can_access_patient_folder((storage.foldername(name))[1])
        )
    )
);

-- No demo users, patients, appointments, or medical data are inserted.
-- Bootstrap an administrator only after creating that user in Supabase Auth:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'your-admin-email@example.com';
-- INSERT INTO public.admins (id, name, email)
-- SELECT id, COALESCE(name, full_name, email), email
-- FROM public.profiles WHERE email = 'your-admin-email@example.com'
-- ON CONFLICT (id) DO NOTHING;
