'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';

export default function CreateAdminPage() {
    const router = useRouter();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [fullName, setFullName] = useState('');
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');
    const [error, setError] = useState('');

    const handleCreateAdmin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        setMessage('');

        try {
            // Step 1: Create user in Supabase Auth
            const { data: authData, error: authError } = await supabase.auth.signUp({
                email,
                password,
                options: {
                    data: {
                        full_name: fullName,
                    }
                }
            });

            if (authError) {
                setError(authError.message);
                setLoading(false);
                return;
            }

            if (authData.user) {
                // Step 2: Add to admin_users table
                const { error: adminError } = await supabase
                    .from('admin_users')
                    .insert([{
                        user_id: authData.user.id,
                        email: email,
                        full_name: fullName,
                        role: 'super_admin',
                        is_active: true
                    }]);

                if (adminError) {
                    // If admin insert fails, try updating existing
                    console.log('Admin insert error:', adminError);
                    setMessage('Account created! Check your email for verification, then login.');
                } else {
                    setMessage('🎉 Admin account created successfully! Check email for verification.');
                }
            }
        } catch (err) {
            console.error(err);
            setError('Something went wrong');
        }

        setLoading(false);
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500">
            <div className="bg-white p-8 rounded-3xl shadow-2xl w-full max-w-md">
                <div className="text-center mb-8">
                    <div className="w-20 h-20 bg-gradient-to-r from-indigo-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-4 rotate-3">
                        <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <h1 className="text-2xl font-bold text-gray-800">Create Admin Account</h1>
                    <p className="text-gray-500 mt-2">First time setup for TrueScan Admin</p>
                </div>

                {error && (
                    <div className="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-xl text-sm">
                        ❌ {error}
                    </div>
                )}

                {message && (
                    <div className="mb-4 p-4 bg-green-50 border border-green-200 text-green-700 rounded-xl text-sm">
                        ✅ {message}
                        <button
                            onClick={() => router.push('/')}
                            className="mt-3 w-full py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                        >
                            Go to Login →
                        </button>
                    </div>
                )}

                {!message && (
                    <form onSubmit={handleCreateAdmin} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                            <input
                                type="text"
                                value={fullName}
                                onChange={(e) => setFullName(e.target.value)}
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-gray-900"
                                placeholder="Your Name"
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-gray-900"
                                placeholder="admin@example.com"
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-gray-900"
                                placeholder="••••••••"
                                minLength={6}
                                required
                            />
                            <p className="text-xs text-gray-500 mt-1">Minimum 6 characters</p>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full py-3 bg-gradient-to-r from-indigo-500 to-purple-600 text-white font-semibold rounded-xl hover:from-indigo-600 hover:to-purple-700 transition-all disabled:opacity-50"
                        >
                            {loading ? (
                                <span className="flex items-center justify-center gap-2">
                                    <svg className="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
                                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                    </svg>
                                    Creating...
                                </span>
                            ) : (
                                '🚀 Create Admin Account'
                            )}
                        </button>
                    </form>
                )}

                <div className="mt-6 text-center">
                    <button
                        onClick={() => router.push('/')}
                        className="text-purple-600 hover:text-purple-700 text-sm"
                    >
                        ← Back to Login
                    </button>
                </div>

                <div className="mt-6 p-4 bg-amber-50 border border-amber-200 rounded-xl text-amber-800 text-xs">
                    ⚠️ <strong>Note:</strong> This page is for first-time admin setup only. After creating your admin account, this page should be removed for security.
                </div>
            </div>
        </div>
    );
}
