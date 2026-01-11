'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState, useEffect } from 'react';

interface AdminLayoutProps {
    children: React.ReactNode;
    title: string;
    subtitle?: string;
}

export default function AdminLayout({ children, title, subtitle }: AdminLayoutProps) {
    const pathname = usePathname();
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
    }, []);

    const navItems = [
        { href: '/', label: 'Dashboard', icon: '🏠', desc: 'Overview' },
        { href: '/users', label: 'Users', icon: '👥', desc: 'Manage' },
        { href: '/tips', label: 'Health Tips', icon: '💡', desc: 'AI Tips' },
        { href: '/ads', label: 'Ads', icon: '📢', desc: 'Manage' },
        { href: '/notifications', label: 'Notifications', icon: '🔔', desc: 'Send' },
        { href: '/profile', label: 'Admin Profile', icon: '👤', desc: 'API Keys' },
    ];

    if (!mounted) return null;

    return (
        <div style={{ minHeight: '100vh', background: 'linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%)' }}>
            {/* Mobile Header */}
            <div style={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                height: 56,
                background: '#1e293b',
                zIndex: 100,
                padding: '0 16px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between'
            }} className="lg:hidden">
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                    <span style={{ fontSize: 24 }}>🛡️</span>
                    <span style={{ color: 'white', fontWeight: 'bold' }}>TrueScan</span>
                </div>
                <button onClick={() => setSidebarOpen(!sidebarOpen)} style={{ color: 'white', padding: 8, background: 'none', border: 'none', cursor: 'pointer', fontSize: 20 }}>
                    {sidebarOpen ? '✕' : '☰'}
                </button>
            </div>

            {/* Sidebar Overlay */}
            {sidebarOpen && (
                <div onClick={() => setSidebarOpen(false)} className="lg:hidden"
                    style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 110 }} />
            )}

            {/* Sidebar */}
            <aside style={{
                position: 'fixed',
                top: 0,
                left: 0,
                height: '100vh',
                width: 220,
                background: 'linear-gradient(180deg, #1e293b 0%, #0f172a 100%)',
                padding: 16,
                zIndex: 120,
                transform: sidebarOpen ? 'translateX(0)' : 'translateX(-100%)',
                transition: 'transform 0.3s ease',
                overflowY: 'auto'
            }} className="lg:!transform-none">
                {/* Logo */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 24, padding: 8 }}>
                    <div style={{
                        width: 40, height: 40, borderRadius: 12,
                        background: 'linear-gradient(135deg, #6366f1, #a855f7)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center'
                    }}>
                        <span style={{ fontSize: 20 }}>🛡️</span>
                    </div>
                    <div>
                        <h1 style={{ color: 'white', fontWeight: 'bold', fontSize: 16, margin: 0 }}>TrueScan</h1>
                        <p style={{ color: '#94a3b8', fontSize: 10, margin: 0 }}>Admin Panel</p>
                    </div>
                </div>

                {/* Navigation */}
                <nav style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                    {navItems.map((item) => (
                        <Link key={item.href} href={item.href} onClick={() => setSidebarOpen(false)}
                            style={{
                                display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', borderRadius: 12,
                                textDecoration: 'none',
                                background: pathname === item.href ? 'linear-gradient(135deg, #6366f1, #a855f7)' : 'transparent'
                            }}>
                            <span style={{ fontSize: 18 }}>{item.icon}</span>
                            <div>
                                <p style={{ color: 'white', margin: 0, fontSize: 13, fontWeight: 500 }}>{item.label}</p>
                                <p style={{ color: '#94a3b8', margin: 0, fontSize: 10 }}>{item.desc}</p>
                            </div>
                        </Link>
                    ))}
                </nav>

                {/* Sign Out */}
                <div style={{ position: 'absolute', bottom: 16, left: 16, right: 16 }}>
                    <button
                        onClick={async () => {
                            const { supabase } = await import('@/lib/supabase');
                            await supabase.auth.signOut();
                            window.location.href = '/';
                        }}
                        style={{
                            width: '100%', padding: '10px', borderRadius: 10,
                            background: 'rgba(239,68,68,0.1)', color: '#f87171',
                            border: '1px solid rgba(239,68,68,0.2)',
                            cursor: 'pointer', fontSize: 13
                        }}>
                        🚪 Sign Out
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <main style={{ marginLeft: 0, paddingTop: 56, minHeight: '100vh' }} className="lg:!ml-[220px] lg:!pt-0">
                <div style={{ padding: 20, maxWidth: 1200 }}>
                    {/* Page Header */}
                    <div style={{ marginBottom: 24 }}>
                        <h1 style={{ fontSize: 28, fontWeight: 'bold', color: '#1e293b', margin: 0 }}>{title}</h1>
                        {subtitle && <p style={{ color: '#64748b', fontSize: 14, margin: '4px 0 0 0' }}>{subtitle}</p>}
                    </div>

                    {children}
                </div>
            </main>
        </div>
    );
}
