export default function SetupScreen() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-950 p-4">
            <div className="max-w-xl w-full bg-gray-900 rounded-2xl shadow-2xl p-8 border border-gray-800">
                <h2 className="text-3xl font-black text-center text-red-500 mb-4 tracking-tight">
                    ⚠️ Setup Required
                </h2>
                <p className="text-gray-400 mb-8 text-center text-lg">
                    Supabase configuration is missing or invalid.
                </p>
                <div className="bg-yellow-500/10 border border-yellow-500/20 p-4 rounded-xl text-sm text-yellow-200">
                    Add <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">VITE_SUPABASE_URL</code> and <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">VITE_SUPABASE_KEY</code> to the project root <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">.env</code> file, then restart the development server.
                </div>
            </div>
        </div>
    );
}
