import { Link } from "react-router-dom";
import { Shield } from "lucide-react";

export default function AdminSignup() {
    return (
        <main className="min-h-screen flex items-center justify-center bg-gray-50 p-6 dark:bg-slate-900">
            <section className="max-w-xl rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-xl dark:border-white/10 dark:bg-slate-800">
                <Shield className="mx-auto mb-4 text-blue-600" size={40} />
                <h1 className="mb-3 text-2xl font-bold text-gray-900 dark:text-white">
                    Administrator setup
                </h1>
                <p className="mb-6 text-gray-600 dark:text-gray-300">
                    Public administrator registration is disabled. Create the first administrator in Supabase Authentication, then follow the bootstrap instructions at the end of the HMS database migration.
                </p>
                <Link
                    to="/login"
                    className="inline-flex rounded-lg bg-blue-600 px-6 py-3 font-bold text-white hover:bg-blue-700"
                >
                    Return to login
                </Link>
            </section>
        </main>
    );
}
