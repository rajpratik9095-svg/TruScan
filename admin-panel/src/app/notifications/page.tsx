'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import AdminLayout from '@/components/AdminLayout';

interface Notification {
    id: number;
    title: string;
    message: string;
    type: string;
    user_id: string | null;
    is_read: boolean;
    created_at: string;
}

interface User {
    id: string;
    name: string;
    email: string;
}

export default function NotificationsPage() {
    const [notifications, setNotifications] = useState<Notification[]>([]);
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);

    const [title, setTitle] = useState('');
    const [message, setMessage] = useState('');
    const [type, setType] = useState('general');
    const [targetUserId, setTargetUserId] = useState('all');

    useEffect(() => {
        fetchNotifications();
        fetchUsers();
    }, []);

    const fetchNotifications = async () => {
        setLoading(true);
        const { data } = await supabase.from('notifications').select('*').order('created_at', { ascending: false });
        if (data) setNotifications(data);
        setLoading(false);
    };

    const fetchUsers = async () => {
        const { data } = await supabase.from('users').select('id, name, email');
        if (data) setUsers(data);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const notifData = {
            title,
            message,
            type,
            user_id: targetUserId === 'all' ? null : targetUserId,
        };
        await supabase.from('notifications').insert([notifData]);
        setTitle(''); setMessage(''); setType('general'); setTargetUserId('all');
        setShowForm(false);
        fetchNotifications();
        alert('✅ Notification sent successfully!');
    };

    const handleDelete = async (id: number) => {
        if (confirm('Delete this notification?')) {
            await supabase.from('notifications').delete().eq('id', id);
            fetchNotifications();
        }
    };

    const typeColors: Record<string, { bg: string; text: string }> = {
        general: { bg: '#dbeafe', text: '#1d4ed8' },
        alert: { bg: '#fee2e2', text: '#dc2626' },
        promotion: { bg: '#d1fae5', text: '#059669' },
        reminder: { bg: '#fef3c7', text: '#d97706' },
    };

    return (
        <AdminLayout title="🔔 Notifications" subtitle="Send notifications to app users">
            {/* Send Button */}
            <button onClick={() => setShowForm(true)}
                style={{ marginBottom: 24, padding: '14px 28px', background: 'linear-gradient(135deg, #6366f1, #a855f7)', color: 'white', fontWeight: 600, borderRadius: 14, border: 'none', cursor: 'pointer', fontSize: 15, display: 'flex', alignItems: 'center', gap: 8 }}>
                📤 Send New Notification
            </button>

            {/* Send Notification Modal */}
            {showForm && (
                <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: 16, backdropFilter: 'blur(4px)' }} onClick={() => setShowForm(false)}>
                    <div style={{ background: 'white', borderRadius: 24, width: '100%', maxWidth: 520, boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)' }} onClick={e => e.stopPropagation()}>
                        {/* Header */}
                        <div style={{ padding: 24, borderBottom: '1px solid #f1f5f9' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                                <div style={{ width: 48, height: 48, borderRadius: 14, background: 'linear-gradient(135deg, #6366f1, #a855f7)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                    <span style={{ fontSize: 24 }}>🔔</span>
                                </div>
                                <div>
                                    <h2 style={{ margin: 0, fontSize: 22, fontWeight: 700, color: '#1e293b' }}>Send Notification</h2>
                                    <p style={{ margin: 0, fontSize: 13, color: '#64748b' }}>Broadcast or send to specific user</p>
                                </div>
                            </div>
                        </div>

                        <form onSubmit={handleSubmit} style={{ padding: 24 }}>
                            {/* Title */}
                            <div style={{ marginBottom: 20 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>📌 Title</label>
                                <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Notification title..."
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }} required />
                            </div>

                            {/* Message */}
                            <div style={{ marginBottom: 20 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>📝 Message</label>
                                <textarea value={message} onChange={(e) => setMessage(e.target.value)} placeholder="Write your notification message..."
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', minHeight: 100, resize: 'vertical', fontFamily: 'inherit', boxSizing: 'border-box' }} required />
                            </div>

                            {/* Type & Target */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 20 }}>
                                <div>
                                    <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>🏷️ Type</label>
                                    <select value={type} onChange={(e) => setType(e.target.value)}
                                        style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', cursor: 'pointer', background: 'white', boxSizing: 'border-box' }}>
                                        <option value="general">📢 General</option>
                                        <option value="alert">🚨 Alert</option>
                                        <option value="promotion">🎉 Promotion</option>
                                        <option value="reminder">⏰ Reminder</option>
                                    </select>
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>👤 Send To</label>
                                    <select value={targetUserId} onChange={(e) => setTargetUserId(e.target.value)}
                                        style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', cursor: 'pointer', background: 'white', boxSizing: 'border-box' }}>
                                        <option value="all">📢 All Users (Broadcast)</option>
                                        {users.map(u => <option key={u.id} value={u.id}>{u.name || u.email}</option>)}
                                    </select>
                                </div>
                            </div>

                            {/* Buttons */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                                <button type="button" onClick={() => setShowForm(false)}
                                    style={{ padding: '14px', background: '#f1f5f9', color: '#475569', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15 }}>
                                    Cancel
                                </button>
                                <button type="submit"
                                    style={{ padding: '14px', background: 'linear-gradient(135deg, #6366f1, #a855f7)', color: 'white', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15 }}>
                                    📤 Send Notification
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Notifications List */}
            {loading ? (
                <div style={{ display: 'flex', justifyContent: 'center', padding: 48 }}>
                    <div style={{ width: 48, height: 48, border: '4px solid #e0e7ff', borderTopColor: '#6366f1', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                </div>
            ) : (
                <div style={{ display: 'grid', gap: 12 }}>
                    {notifications.map((notif) => (
                        <div key={notif.id} style={{ background: 'white', borderRadius: 16, padding: 20, boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                                    <span style={{ padding: '4px 12px', borderRadius: 20, fontSize: 11, fontWeight: 600, background: typeColors[notif.type]?.bg || '#f1f5f9', color: typeColors[notif.type]?.text || '#64748b' }}>
                                        {notif.type.toUpperCase()}
                                    </span>
                                    <span style={{ padding: '4px 12px', borderRadius: 20, fontSize: 11, fontWeight: 600, background: notif.user_id ? '#fef3c7' : '#dbeafe', color: notif.user_id ? '#d97706' : '#1d4ed8' }}>
                                        {notif.user_id ? '👤 Individual' : '📢 Broadcast'}
                                    </span>
                                </div>
                                <button onClick={() => handleDelete(notif.id)} style={{ background: '#fee2e2', color: '#dc2626', border: 'none', padding: '6px 12px', borderRadius: 8, cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>
                                    🗑️ Delete
                                </button>
                            </div>
                            <h3 style={{ margin: '0 0 8px 0', fontSize: 16, fontWeight: 600, color: '#1e293b' }}>{notif.title}</h3>
                            <p style={{ margin: 0, fontSize: 14, color: '#64748b', lineHeight: 1.5 }}>{notif.message}</p>
                            <p style={{ margin: '12px 0 0 0', fontSize: 12, color: '#94a3b8' }}>
                                📅 {new Date(notif.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                            </p>
                        </div>
                    ))}
                    {notifications.length === 0 && (
                        <div style={{ textAlign: 'center', padding: 64, background: 'white', borderRadius: 20 }}>
                            <p style={{ fontSize: 48, margin: 0 }}>🔔</p>
                            <p style={{ fontSize: 18, color: '#64748b', margin: '16px 0 0 0' }}>No notifications sent yet</p>
                        </div>
                    )}
                </div>
            )}

            <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </AdminLayout>
    );
}
