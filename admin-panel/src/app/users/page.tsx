'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import AdminLayout from '@/components/AdminLayout';

interface User {
    id: string;
    email: string;
    name: string;
    full_name?: string;
    avatar_url?: string;
    profile_image?: string;
    created_at: string;
}

interface StepCount {
    user_id: string;
    steps: number;
    distance_meters: number;
    calories_burned: number;
}

export default function UsersPage() {
    const [users, setUsers] = useState<(User & { total_steps: number; total_calories: number; total_distance: number })[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');

    useEffect(() => { fetchUsers(); }, []);

    const fetchUsers = async () => {
        setLoading(true);
        const { data: usersData } = await supabase.from('users').select('*').order('created_at', { ascending: false });
        const { data: stepsData } = await supabase.from('step_count').select('*');

        const usersWithSteps = (usersData || []).map((user: User) => {
            const userSteps = (stepsData || []).filter((s: StepCount) => s.user_id === user.id);
            return {
                ...user,
                total_steps: userSteps.reduce((a, s) => a + (s.steps || 0), 0),
                total_calories: userSteps.reduce((a, s) => a + (s.calories_burned || 0), 0),
                total_distance: userSteps.reduce((a, s) => a + (s.distance_meters || 0), 0),
            };
        });
        setUsers(usersWithSteps);
        setLoading(false);
    };

    const filtered = users.filter(u =>
        u.name?.toLowerCase().includes(search.toLowerCase()) ||
        u.email?.toLowerCase().includes(search.toLowerCase())
    );

    const getInitials = (name: string, email: string) => {
        if (name) return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
        return email?.[0]?.toUpperCase() || 'U';
    };

    const getGradient = (id: string) => {
        const gradients = [
            'linear-gradient(135deg, #667eea, #764ba2)',
            'linear-gradient(135deg, #f093fb, #f5576c)',
            'linear-gradient(135deg, #4facfe, #00f2fe)',
            'linear-gradient(135deg, #43e97b, #38f9d7)',
            'linear-gradient(135deg, #fa709a, #fee140)',
            'linear-gradient(135deg, #a8edea, #fed6e3)',
        ];
        const index = id.charCodeAt(0) % gradients.length;
        return gradients[index];
    };

    return (
        <AdminLayout title="👥 Users" subtitle={`${users.length} registered users`}>
            {/* Search Bar */}
            <div style={{ marginBottom: 24 }}>
                <div style={{ position: 'relative' }}>
                    <span style={{ position: 'absolute', left: 16, top: '50%', transform: 'translateY(-50%)', fontSize: 20 }}>🔍</span>
                    <input
                        type="text"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        placeholder="Search by name or email..."
                        style={{
                            width: '100%',
                            padding: '16px 16px 16px 48px',
                            background: 'white',
                            border: '2px solid #e2e8f0',
                            borderRadius: 16,
                            fontSize: 15,
                            color: '#1e293b',
                            boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)',
                            outline: 'none',
                            boxSizing: 'border-box'
                        }}
                    />
                </div>
            </div>

            {/* Stats Summary */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 24 }}>
                <div style={{ background: 'linear-gradient(135deg, #667eea, #764ba2)', borderRadius: 16, padding: 20, color: 'white' }}>
                    <p style={{ margin: 0, fontSize: 32, fontWeight: 700 }}>{users.length}</p>
                    <p style={{ margin: 0, fontSize: 14, opacity: 0.9 }}>👥 Total Users</p>
                </div>
                <div style={{ background: 'linear-gradient(135deg, #f093fb, #f5576c)', borderRadius: 16, padding: 20, color: 'white' }}>
                    <p style={{ margin: 0, fontSize: 32, fontWeight: 700 }}>{users.reduce((a, u) => a + u.total_steps, 0).toLocaleString()}</p>
                    <p style={{ margin: 0, fontSize: 14, opacity: 0.9 }}>🚶 Total Steps</p>
                </div>
                <div style={{ background: 'linear-gradient(135deg, #fa709a, #fee140)', borderRadius: 16, padding: 20, color: 'white' }}>
                    <p style={{ margin: 0, fontSize: 32, fontWeight: 700 }}>{users.reduce((a, u) => a + u.total_calories, 0).toFixed(0)}</p>
                    <p style={{ margin: 0, fontSize: 14, opacity: 0.9 }}>🔥 Calories Burned</p>
                </div>
            </div>

            {loading ? (
                <div style={{ display: 'flex', justifyContent: 'center', padding: 48 }}>
                    <div style={{ width: 48, height: 48, border: '4px solid #e0e7ff', borderTopColor: '#6366f1', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                </div>
            ) : (
                <div style={{ display: 'grid', gap: 16 }}>
                    {filtered.map((user) => (
                        <div key={user.id} style={{
                            background: 'white',
                            borderRadius: 20,
                            padding: 24,
                            boxShadow: '0 4px 15px rgba(0,0,0,0.05)',
                            transition: 'transform 0.2s, box-shadow 0.2s',
                            cursor: 'default'
                        }}>
                            {/* User Header */}
                            <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20 }}>
                                {/* Avatar */}
                                {user.avatar_url || user.profile_image ? (
                                    <img
                                        src={user.avatar_url || user.profile_image}
                                        alt={user.name}
                                        style={{ width: 64, height: 64, borderRadius: 16, objectFit: 'cover', border: '3px solid #e2e8f0' }}
                                        onError={(e) => {
                                            (e.target as HTMLImageElement).style.display = 'none';
                                            (e.target as HTMLImageElement).nextElementSibling?.classList.remove('hidden');
                                        }}
                                    />
                                ) : null}
                                <div style={{
                                    width: 64,
                                    height: 64,
                                    borderRadius: 16,
                                    background: getGradient(user.id),
                                    display: (user.avatar_url || user.profile_image) ? 'none' : 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    color: 'white',
                                    fontWeight: 700,
                                    fontSize: 22,
                                    boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
                                }}>
                                    {getInitials(user.name, user.email)}
                                </div>

                                <div style={{ flex: 1 }}>
                                    <h3 style={{ margin: 0, fontSize: 18, fontWeight: 700, color: '#1e293b' }}>
                                        {user.name || user.full_name || 'User'}
                                    </h3>
                                    <p style={{ margin: '4px 0 0 0', fontSize: 14, color: '#64748b' }}>📧 {user.email}</p>
                                    <p style={{ margin: '4px 0 0 0', fontSize: 12, color: '#94a3b8' }}>
                                        📅 Joined {new Date(user.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                                    </p>
                                </div>
                            </div>

                            {/* Stats Grid */}
                            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12 }}>
                                <div style={{ background: 'linear-gradient(135deg, #ede9fe, #ddd6fe)', borderRadius: 14, padding: 16, textAlign: 'center' }}>
                                    <p style={{ margin: 0, fontSize: 28, fontWeight: 700, color: '#7c3aed' }}>{user.total_steps.toLocaleString()}</p>
                                    <p style={{ margin: '4px 0 0 0', fontSize: 12, color: '#8b5cf6', fontWeight: 600 }}>🚶 Steps</p>
                                </div>
                                <div style={{ background: 'linear-gradient(135deg, #fee2e2, #fecaca)', borderRadius: 14, padding: 16, textAlign: 'center' }}>
                                    <p style={{ margin: 0, fontSize: 28, fontWeight: 700, color: '#dc2626' }}>{user.total_calories.toFixed(0)}</p>
                                    <p style={{ margin: '4px 0 0 0', fontSize: 12, color: '#ef4444', fontWeight: 600 }}>🔥 Calories</p>
                                </div>
                                <div style={{ background: 'linear-gradient(135deg, #d1fae5, #a7f3d0)', borderRadius: 14, padding: 16, textAlign: 'center' }}>
                                    <p style={{ margin: 0, fontSize: 28, fontWeight: 700, color: '#059669' }}>{(user.total_distance / 1000).toFixed(1)}km</p>
                                    <p style={{ margin: '4px 0 0 0', fontSize: 12, color: '#10b981', fontWeight: 600 }}>📍 Distance</p>
                                </div>
                            </div>
                        </div>
                    ))}

                    {filtered.length === 0 && (
                        <div style={{ textAlign: 'center', padding: 64, background: 'white', borderRadius: 20 }}>
                            <p style={{ fontSize: 48, margin: 0 }}>👤</p>
                            <p style={{ fontSize: 18, color: '#64748b', margin: '16px 0 0 0' }}>No users found</p>
                        </div>
                    )}
                </div>
            )}

            <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </AdminLayout>
    );
}
