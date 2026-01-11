'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';
import AdminLayout from '@/components/AdminLayout';

interface Stats {
  totalUsers: number;
  totalTips: number;
  totalAds: number;
  totalSteps: number;
  totalNotifications: number;
}

interface RecentUser {
  id: string;
  name: string;
  email: string;
  created_at: string;
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<Stats>({ totalUsers: 0, totalTips: 0, totalAds: 0, totalSteps: 0, totalNotifications: 0 });
  const [recentUsers, setRecentUsers] = useState<RecentUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session) { setIsLoggedIn(true); fetchStats(); }
    else { setLoading(false); }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) setError(error.message);
    else { setIsLoggedIn(true); fetchStats(); }
  };

  const fetchStats = async () => {
    setLoading(true);
    try {
      const { count: tipsCount } = await supabase.from('health_tips').select('*', { count: 'exact', head: true });
      const { count: adsCount } = await supabase.from('ads').select('*', { count: 'exact', head: true });
      const { count: usersCount } = await supabase.from('users').select('*', { count: 'exact', head: true });
      const { count: notifsCount } = await supabase.from('notifications').select('*', { count: 'exact', head: true });
      const { data: stepsData } = await supabase.from('step_count').select('steps');
      const { data: recent } = await supabase.from('users').select('id, name, email, created_at').order('created_at', { ascending: false }).limit(5);

      const totalSteps = stepsData?.reduce((acc, s) => acc + (s.steps || 0), 0) || 0;
      setStats({ totalUsers: usersCount || 0, totalTips: tipsCount || 0, totalAds: adsCount || 0, totalSteps, totalNotifications: notifsCount || 0 });
      setRecentUsers(recent || []);
    } catch (err) { console.error(err); }
    setLoading(false);
  };

  // Login Screen
  if (!isLoggedIn) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 16, background: 'linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%)' }}>
        <div style={{ position: 'absolute', inset: 0, overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: 40, left: 40, width: 300, height: 300, background: 'rgba(139,92,246,0.3)', borderRadius: '50%', filter: 'blur(100px)' }}></div>
          <div style={{ position: 'absolute', bottom: 40, right: 40, width: 400, height: 400, background: 'rgba(59,130,246,0.2)', borderRadius: '50%', filter: 'blur(120px)' }}></div>
        </div>

        <div style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: 400 }}>
          <div style={{ textAlign: 'center', marginBottom: 32 }}>
            <div style={{ display: 'inline-flex', width: 72, height: 72, borderRadius: 20, background: 'linear-gradient(135deg, #6366f1, #a855f7, #ec4899)', alignItems: 'center', justifyContent: 'center', marginBottom: 16, boxShadow: '0 20px 40px rgba(139,92,246,0.4)' }}>
              <span style={{ fontSize: 36 }}>🛡️</span>
            </div>
            <h1 style={{ fontSize: 36, fontWeight: 'bold', color: 'white', margin: '0 0 8px 0' }}>TrueScan</h1>
            <p style={{ color: '#94a3b8', fontSize: 16 }}>Admin Control Center</p>
          </div>

          <div style={{ background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(20px)', borderRadius: 24, padding: 32, border: '1px solid rgba(255,255,255,0.2)' }}>
            {error && <div style={{ marginBottom: 16, padding: 12, background: 'rgba(239,68,68,0.2)', border: '1px solid rgba(239,68,68,0.4)', borderRadius: 12, color: '#fca5a5', fontSize: 14 }}>{error}</div>}

            <form onSubmit={handleLogin}>
              <div style={{ marginBottom: 20 }}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: '#cbd5e1', marginBottom: 8 }}>Email</label>
                <input type="email" value={email} onChange={(e) => setEmail(e.target.value)}
                  style={{ width: '100%', padding: '14px 16px', background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.2)', borderRadius: 12, color: 'white', fontSize: 15, outline: 'none', boxSizing: 'border-box' }}
                  placeholder="your@email.com" required />
              </div>
              <div style={{ marginBottom: 24 }}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: '#cbd5e1', marginBottom: 8 }}>Password</label>
                <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
                  style={{ width: '100%', padding: '14px 16px', background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.2)', borderRadius: 12, color: 'white', fontSize: 15, outline: 'none', boxSizing: 'border-box' }}
                  placeholder="••••••••" required />
              </div>
              <button type="submit" style={{ width: '100%', padding: '14px', background: 'linear-gradient(135deg, #6366f1, #a855f7, #ec4899)', color: 'white', fontWeight: 600, fontSize: 16, borderRadius: 12, border: 'none', cursor: 'pointer' }}>
                Sign In →
              </button>
            </form>
          </div>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#f1f5f9' }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ width: 56, height: 56, border: '4px solid #e0e7ff', borderTopColor: '#6366f1', borderRadius: '50%', animation: 'spin 1s linear infinite', margin: '0 auto 16px' }}></div>
          <p style={{ color: '#64748b', fontWeight: 500 }}>Loading...</p>
        </div>
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    );
  }

  const statCards = [
    { label: 'Users', value: stats.totalUsers, icon: '👥', color: '#6366f1', href: '/users' },
    { label: 'Health Tips', value: stats.totalTips, icon: '💡', color: '#f59e0b', href: '/tips' },
    { label: 'Active Ads', value: stats.totalAds, icon: '📢', color: '#ec4899', href: '/ads' },
    { label: 'Notifications', value: stats.totalNotifications, icon: '🔔', color: '#10b981', href: '/notifications' },
  ];

  return (
    <AdminLayout title="🏠 Dashboard" subtitle="Welcome back! Here's your overview.">
      {/* Stats Grid - Clickable */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 16, marginBottom: 24 }}>
        {statCards.map((stat) => (
          <Link key={stat.label} href={stat.href} style={{ textDecoration: 'none' }}>
            <div style={{
              background: 'white',
              borderRadius: 20,
              padding: 20,
              boxShadow: '0 4px 15px rgba(0,0,0,0.05)',
              cursor: 'pointer',
              transition: 'transform 0.2s, box-shadow 0.2s',
              border: '2px solid transparent'
            }}
              onMouseEnter={(e) => { e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = `0 8px 25px ${stat.color}30`; e.currentTarget.style.borderColor = stat.color; }}
              onMouseLeave={(e) => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 4px 15px rgba(0,0,0,0.05)'; e.currentTarget.style.borderColor = 'transparent'; }}>
              <div style={{ width: 48, height: 48, borderRadius: 14, background: `${stat.color}20`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, marginBottom: 12 }}>
                {stat.icon}
              </div>
              <p style={{ margin: 0, fontSize: 32, fontWeight: 700, color: '#1e293b' }}>{stat.value}</p>
              <p style={{ margin: '4px 0 0 0', fontSize: 14, color: '#64748b' }}>{stat.label}</p>
            </div>
          </Link>
        ))}
      </div>

      {/* Quick Actions */}
      <div style={{ background: 'white', borderRadius: 20, padding: 24, marginBottom: 24, boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}>
        <h2 style={{ margin: '0 0 16px 0', fontSize: 18, fontWeight: 700, color: '#1e293b' }}>⚡ Quick Actions</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: 12 }}>
          <Link href="/tips" style={{ padding: '14px', background: 'linear-gradient(135deg, #6366f1, #a855f7)', color: 'white', fontWeight: 600, borderRadius: 14, textAlign: 'center', textDecoration: 'none', fontSize: 14 }}>
            ✨ Add Tip
          </Link>
          <Link href="/ads" style={{ padding: '14px', background: 'linear-gradient(135deg, #ec4899, #f97316)', color: 'white', fontWeight: 600, borderRadius: 14, textAlign: 'center', textDecoration: 'none', fontSize: 14 }}>
            📢 Create Ad
          </Link>
          <Link href="/notifications" style={{ padding: '14px', background: 'linear-gradient(135deg, #10b981, #059669)', color: 'white', fontWeight: 600, borderRadius: 14, textAlign: 'center', textDecoration: 'none', fontSize: 14 }}>
            🔔 Send Notification
          </Link>
          <Link href="/profile" style={{ padding: '14px', background: '#1e293b', color: 'white', fontWeight: 600, borderRadius: 14, textAlign: 'center', textDecoration: 'none', fontSize: 14 }}>
            👤 Admin Profile
          </Link>
        </div>
      </div>

      {/* Recent Users */}
      <div style={{ background: 'white', borderRadius: 20, padding: 24, boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <h2 style={{ margin: 0, fontSize: 18, fontWeight: 700, color: '#1e293b' }}>👥 Recent Users</h2>
          <Link href="/users" style={{ fontSize: 14, color: '#6366f1', fontWeight: 600, textDecoration: 'none' }}>View All →</Link>
        </div>

        <div style={{ display: 'grid', gap: 12 }}>
          {recentUsers.map((user) => (
            <Link key={user.id} href="/users" style={{ textDecoration: 'none' }}>
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: 14,
                background: '#f8fafc',
                borderRadius: 14,
                cursor: 'pointer',
                transition: 'background 0.2s'
              }}
                onMouseEnter={(e) => e.currentTarget.style.background = '#f1f5f9'}
                onMouseLeave={(e) => e.currentTarget.style.background = '#f8fafc'}>
                <div style={{ width: 44, height: 44, borderRadius: 12, background: 'linear-gradient(135deg, #6366f1, #a855f7)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontWeight: 700 }}>
                  {(user.name || user.email)?.[0]?.toUpperCase() || 'U'}
                </div>
                <div style={{ flex: 1 }}>
                  <p style={{ margin: 0, fontSize: 14, fontWeight: 600, color: '#1e293b' }}>{user.name || 'User'}</p>
                  <p style={{ margin: '2px 0 0 0', fontSize: 12, color: '#64748b' }}>{user.email}</p>
                </div>
                <p style={{ fontSize: 11, color: '#94a3b8' }}>{new Date(user.created_at).toLocaleDateString()}</p>
              </div>
            </Link>
          ))}
          {recentUsers.length === 0 && (
            <p style={{ textAlign: 'center', padding: 32, color: '#64748b' }}>No users yet</p>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
