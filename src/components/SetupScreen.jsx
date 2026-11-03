export default function SetupScreen() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-950 p-4">
            <div className="max-w-xl w-full bg-gray-900 rounded-2xl shadow-2xl p-8 border border-gray-800">
                <h2 className="text-3xl font-black text-center text-red-500 mb-4 tracking-tight">
                    ⚠️ Setup Required
                </h2>
                <p className="text-gray-400 mb-8 text-center text-lg">
                    Supabase configuration is missing or invalid. The app cannot connect until both public project settings are configured.
                </p>
                <div className="bg-yellow-500/10 border border-yellow-500/20 p-4 rounded-xl text-sm text-yellow-200">
                    <p className="mb-3">
                        For GitHub Pages, add <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">VITE_SUPABASE_URL</code> and <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">VITE_SUPABASE_KEY</code> under your repository's <strong>Settings → Secrets and variables → Actions</strong>, then rerun the deployment workflow.
                    </p>
                    <p>
                        For local development, set these values in the project root <code className="bg-black/30 px-1 py-0.5 rounded font-mono text-yellow-100">.env.local</code> file and restart the development server. Use only a Supabase publishable or anon key; never put a secret or service-role key in the frontend.
                    </p>
                </div>
            </div>
        </div>
    );
}
