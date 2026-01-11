'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import AdminLayout from '@/components/AdminLayout';

interface Admin {
    id: string;
    email: string;
    gemini_api_key?: string;
    created_at: string;
}

export default function ProfilePage() {
    const [currentAdmin, setCurrentAdmin] = useState<{ email: string; id: string } | null>(null);
    const [admins, setAdmins] = useState<Admin[]>([]);
    const [loading, setLoading] = useState(true);
    const [showAddAdmin, setShowAddAdmin] = useState(false);
    const [apiKey, setApiKey] = useState('');
    const [savingApiKey, setSavingApiKey] = useState(false);

    const [newEmail, setNewEmail] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [newApiKey, setNewApiKey] = useState('');
    const [addLoading, setAddLoading] = useState(false);

    useEffect(() => {
        fetchCurrentAdmin();
        fetchAdmins();
    }, []);

    const fetchCurrentAdmin = async () => {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            setCurrentAdmin({ email: user.email || '', id: user.id });
            // Fetch API key
            const { data } = await supabase.from('admin_users').select('gemini_api_key').eq('id', user.id).single();
            if (data?.gemini_api_key) setApiKey(data.gemini_api_key);
        }
    };

    const fetchAdmins = async () => {
        setLoading(true);
        const { data } = await supabase.from('admin_users').select('*').order('created_at', { ascending: false });
        if (data) setAdmins(data);
        setLoading(false);
    };

    const handleSaveApiKey = async () => {
        if (!currentAdmin) return;
        setSavingApiKey(true);
        const { error } = await supabase.from('admin_users').update({ gemini_api_key: apiKey }).eq('id', currentAdmin.id);
        if (error) alert('Error: ' + error.message);
        else alert('✅ API Key saved successfully!');
        setSavingApiKey(false);
    };

    const handleAddAdmin = async (e: React.FormEvent) => {
        e.preventDefault();
        setAddLoading(true);

        try {
            const { data, error } = await supabase.auth.signUp({
                email: newEmail,
                password: newPassword,
            });

            if (error) {
                alert('Error: ' + error.message);
            } else if (data.user) {
                await supabase.from('admin_users').insert([{
                    id: data.user.id,
                    email: newEmail,
                    gemini_api_key: newApiKey || null,
                }]);
                alert('✅ New admin added successfully!');
                setNewEmail(''); setNewPassword(''); setNewApiKey('');
                setShowAddAdmin(false);
                fetchAdmins();
            }
        } catch (err) {
            alert('Error: ' + (err as Error).message);
        }

        setAddLoading(false);
    };

    const handleDeleteAdmin = async (id: string, email: string) => {
        if (id === currentAdmin?.id) {
            alert('Cannot delete yourself!');
            return;
        }
        if (confirm(`Delete admin ${email}?`)) {
            await supabase.from('admin_users').delete().eq('id', id);
            fetchAdmins();
        }
    };

    return (
        <AdminLayout title="👤 Admin Profile" subtitle="Manage your account, API keys, and admin users">
            {/* Current Admin Card */}
            <div style={{ background: 'linear-gradient(135deg, #6366f1, #a855f7)', borderRadius: 24, padding: 32, color: 'white', marginBottom: 24 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
                    <div style={{ width: 80, height: 80, borderRadius: 20, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 36 }}>
                        👤
                    </div>
                    <div>
                        <p style={{ margin: 0, fontSize: 12, opacity: 0.8, fontWeight: 500 }}>LOGGED IN AS</p>
                        <h2 style={{ margin: '4px 0 0 0', fontSize: 24, fontWeight: 700 }}>{currentAdmin?.email || 'Loading...'}</h2>
                        <p style={{ margin: '8px 0 0 0', fontSize: 14, opacity: 0.9 }}>🔐 Admin Account</p>
                    </div>
                </div>
            </div>

            {/* API Key Management */}
            <div style={{ background: 'white', borderRadius: 20, padding: 24, marginBottom: 24, boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
                    <div style={{ width: 48, height: 48, borderRadius: 14, background: 'linear-gradient(135deg, #fef3c7, #fde68a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24 }}>
                        🔑
                    </div>
                    <div>
                        <h3 style={{ margin: 0, fontSize: 18, fontWeight: 700, color: '#1e293b' }}>Gemini API Key</h3>
                        <p style={{ margin: 0, fontSize: 12, color: '#64748b' }}>Used for AI health tips generation</p>
                    </div>
                </div>

                <div style={{ display: 'flex', gap: 12 }}>
                    <input
                        type="password"
                        value={apiKey}
                        onChange={(e) => setApiKey(e.target.value)}
                        placeholder="Enter your Gemini API key..."
                        style={{ flex: 1, padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 14, fontFamily: 'monospace', outline: 'none' }}
                    />
                    <button onClick={handleSaveApiKey} disabled={savingApiKey}
                        style={{ padding: '14px 24px', background: 'linear-gradient(135deg, #10b981, #059669)', color: 'white', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', opacity: savingApiKey ? 0.6 : 1 }}>
                        {savingApiKey ? '⏳' : '💾'} Save
                    </button>
                </div>

                <p style={{ margin: '12px 0 0 0', fontSize: 12, color: '#94a3b8' }}>
                    💡 Get your API key from: <a href="https://makersuite.google.com/app/apikey" target="_blank" style={{ color: '#6366f1' }}>Google AI Studio</a>
                </p>
            </div>

            {/* Add Admin Button */}
            <button onClick={() => setShowAddAdmin(true)}
                style={{ marginBottom: 24, padding: '14px 28px', background: 'linear-gradient(135deg, #10b981, #059669)', color: 'white', fontWeight: 600, borderRadius: 14, border: 'none', cursor: 'pointer', fontSize: 15, display: 'flex', alignItems: 'center', gap: 8 }}>
                ➕ Add New Admin
            </button>

            {/* Add Admin Modal */}
            {showAddAdmin && (
                <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: 16, backdropFilter: 'blur(4px)' }} onClick={() => setShowAddAdmin(false)}>
                    <div style={{ background: 'white', borderRadius: 24, width: '100%', maxWidth: 440, boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)' }} onClick={e => e.stopPropagation()}>
                        <div style={{ padding: 24, borderBottom: '1px solid #f1f5f9' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                                <div style={{ width: 48, height: 48, borderRadius: 14, background: 'linear-gradient(135deg, #10b981, #059669)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                    <span style={{ fontSize: 24 }}>👤</span>
                                </div>
                                <div>
                                    <h2 style={{ margin: 0, fontSize: 22, fontWeight: 700, color: '#1e293b' }}>Add New Admin</h2>
                                    <p style={{ margin: 0, fontSize: 13, color: '#64748b' }}>Create a new admin account</p>
                                </div>
                            </div>
                        </div>

                        <form onSubmit={handleAddAdmin} style={{ padding: 24 }}>
                            <div style={{ marginBottom: 16 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>📧 Email</label>
                                <input type="email" value={newEmail} onChange={(e) => setNewEmail(e.target.value)} placeholder="admin@example.com"
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }} required />
                            </div>
                            <div style={{ marginBottom: 16 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>🔐 Password</label>
                                <input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} placeholder="Min 6 characters"
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }} required minLength={6} />
                            </div>
                            <div style={{ marginBottom: 24 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>🔑 Gemini API Key (Optional)</label>
                                <input type="password" value={newApiKey} onChange={(e) => setNewApiKey(e.target.value)} placeholder="API key for this admin"
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }} />
                            </div>

                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                                <button type="button" onClick={() => setShowAddAdmin(false)}
                                    style={{ padding: '14px', background: '#f1f5f9', color: '#475569', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15 }}>
                                    Cancel
                                </button>
                                <button type="submit" disabled={addLoading}
                                    style={{ padding: '14px', background: 'linear-gradient(135deg, #10b981, #059669)', color: 'white', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15, opacity: addLoading ? 0.6 : 1 }}>
                                    {addLoading ? '⏳ Creating...' : '✅ Create Admin'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Admin Users List */}
            <div style={{ background: 'white', borderRadius: 20, padding: 24, boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}>
                <h3 style={{ margin: '0 0 20px 0', fontSize: 18, fontWeight: 700, color: '#1e293b' }}>🛡️ Admin Users</h3>

                {loading ? (
                    <div style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
                        <div style={{ width: 40, height: 40, border: '4px solid #e0e7ff', borderTopColor: '#6366f1', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                    </div>
                ) : (
                    <div style={{ display: 'grid', gap: 12 }}>
                        {admins.map((admin) => (
                            <div key={admin.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: 16, background: '#f8fafc', borderRadius: 14, flexWrap: 'wrap', gap: 12 }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                                    <div style={{ width: 44, height: 44, borderRadius: 12, background: 'linear-gradient(135deg, #6366f1, #a855f7)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontWeight: 700 }}>
                                        {admin.email[0].toUpperCase()}
                                    </div>
                                    <div>
                                        <p style={{ margin: 0, fontSize: 15, fontWeight: 600, color: '#1e293b' }}>{admin.email}</p>
                                        <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
                                            <span style={{ fontSize: 11, color: '#64748b' }}>📅 {new Date(admin.created_at).toLocaleDateString()}</span>
                                            {admin.gemini_api_key && <span style={{ fontSize: 11, padding: '2px 8px', background: '#dcfce7', color: '#16a34a', borderRadius: 6, fontWeight: 600 }}>🔑 API Key Set</span>}
                                            {admin.id === currentAdmin?.id && <span style={{ fontSize: 11, padding: '2px 8px', background: '#dbeafe', color: '#1d4ed8', borderRadius: 6, fontWeight: 600 }}>YOU</span>}
                                        </div>
                                    </div>
                                </div>
                                {admin.id !== currentAdmin?.id && (
                                    <button onClick={() => handleDeleteAdmin(admin.id, admin.email)}
                                        style={{ background: '#fee2e2', color: '#dc2626', border: 'none', padding: '8px 14px', borderRadius: 10, cursor: 'pointer', fontSize: 13, fontWeight: 600 }}>
                                        🗑️ Remove
                                    </button>
                                )}
                            </div>
                        ))}
                        {admins.length === 0 && (
                            <p style={{ textAlign: 'center', padding: 32, color: '#64748b' }}>No admins found</p>
                        )}
                    </div>
                )}
            </div>

            <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </AdminLayout>
    );
}
