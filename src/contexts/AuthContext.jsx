import { createContext, useContext, useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

const AuthContext = createContext({});

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [role, setRole] = useState(null);
    const [userName, setUserName] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Check active session
        supabase.auth.getSession().then(({ data: { session } }) => {
            setUser(session?.user ?? null);
            if (session?.user) {
                fetchUserProfile(session.user.id);
            } else {
                setLoading(false);
            }
        });

        // Listen for auth changes
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setUser(session?.user ?? null);
            if (session?.user) {
                fetchUserProfile(session.user.id);
            } else {
                setRole(null);
                setUserName(null);
                setLoading(false);
            }
        });

        return () => subscription.unsubscribe();
    }, []);

    const fetchUserProfile = async (userId) => {
        try {
            // Check ADMINS table
            let { data: admin } = await supabase.from('admins').select('id, name').eq('id', userId).maybeSingle();
            if (admin) {
                setRole('admin');
                setUserName(admin.name);
                return;
            }

            // Check DOCTORS table
            let { data: doctor } = await supabase.from('doctors').select('id, name, full_name').eq('user_id', userId).maybeSingle();
            if (doctor) {
                setRole('doctor');
                setUserName(doctor.name || doctor.full_name);
                return;
            }

            // Check STAFF table (Receptionists)
            let { data: staff } = await supabase.from('staff').select('id, name, role').eq('id', userId).maybeSingle();
            if (staff && staff.role?.toLowerCase() === 'receptionist') {
                setRole('receptionist');
                setUserName(staff.name);
                return;
            }

            // Check PATIENTS table
            let { data: patient } = await supabase.from('patients').select('id, name, full_name').eq('user_id', userId).maybeSingle();
            if (patient) {
                setRole('patient');
                setUserName(patient.name || patient.full_name);
                return;
            }

            // Check WORKERS table
            let { data: worker } = await supabase.from('workers').select('id, name').eq('id', userId).maybeSingle();
            if (worker) {
                setRole('worker');
                setUserName(worker.name);
                return;
            }

            // Roles come from the database, never from user-editable auth metadata.
            const { data: profile, error: profileError } = await supabase
                .from('profiles')
                .select('role, name, full_name')
                .eq('id', userId)
                .maybeSingle();

            if (profileError) throw profileError;

            const allowedRoles = ['admin', 'doctor', 'receptionist', 'patient', 'worker', 'staff'];
            if (profile && allowedRoles.includes(profile.role)) {
                setRole(profile.role === 'staff' ? 'receptionist' : profile.role);
                setUserName(profile.name || profile.full_name);
            } else {
                console.error("Role not found in an authorized account record");
                setRole(null);
            }

        } catch (error) {
            console.error("Critical Profile Fetch Error:", error);
            setRole(null);
        } finally {
            setLoading(false);
        }
    };

    const login = async (email, password) => {
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        if (data.user) {
            setUser(data.user);
            await fetchUserProfile(data.user.id);
        }
    };

    const signUp = async (email, password, name, role, specialization = null, phone = null, address = null) => {
        if (role !== 'patient') {
            throw new Error('Only patient self-registration is available. Staff accounts must be provisioned by an administrator.');
        }

        const { error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    displayName: name,
                    role: 'patient',
                    specialization,
                    phone,
                    address
                }
            }
        });
        if (error) throw error;
    };

    const logout = async () => {
        await supabase.auth.signOut();
        setRole(null);
        setUserName(null);
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, role, userName, loading, login, signUp, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
