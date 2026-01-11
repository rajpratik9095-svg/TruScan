'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import AdminLayout from '@/components/AdminLayout';

interface HealthTip {
    id: number;
    title: string;
    content: string;
    category: string;
    icon: string;
    image_url?: string;
    priority: number;
    is_active: boolean;
    created_at: string;
}

// API key is now fetched from database via Settings page

export default function TipsPage() {
    const [tips, setTips] = useState<HealthTip[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editingTip, setEditingTip] = useState<HealthTip | null>(null);
    const [aiLoading, setAiLoading] = useState(false);
    const [aiCount, setAiCount] = useState(5);
    const [apiKey, setApiKey] = useState('');

    const [title, setTitle] = useState('');
    const [content, setContent] = useState('');
    const [category, setCategory] = useState('health');
    const [imageUrl, setImageUrl] = useState('');
    const [priority, setPriority] = useState(5);
    const [isActive, setIsActive] = useState(true);

    useEffect(() => { fetchTips(); fetchApiKey(); }, []);

    const fetchApiKey = async () => {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            const { data } = await supabase.from('admin_users').select('gemini_api_key').eq('id', user.id).single();
            if (data?.gemini_api_key) setApiKey(data.gemini_api_key);
        }
    };

    const fetchTips = async () => {
        setLoading(true);
        const { data } = await supabase.from('health_tips').select('*').order('created_at', { ascending: false });
        if (data) setTips(data);
        setLoading(false);
    };

    const resetForm = () => {
        setTitle(''); setContent(''); setCategory('health'); setImageUrl(''); setPriority(5); setIsActive(true);
        setEditingTip(null); setShowForm(false);
    };

    const handleEdit = (tip: HealthTip) => {
        setEditingTip(tip); setTitle(tip.title); setContent(tip.content);
        setCategory(tip.category); setImageUrl(tip.image_url || ''); setPriority(tip.priority); setIsActive(tip.is_active);
        setShowForm(true);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const tipData = { title, content, category, icon: 'favorite', image_url: imageUrl || null, priority, is_active: isActive };
        if (editingTip) await supabase.from('health_tips').update(tipData).eq('id', editingTip.id);
        else await supabase.from('health_tips').insert([tipData]);
        resetForm(); fetchTips();
    };

    const handleDelete = async (id: number) => {
        if (confirm('Delete this tip?')) {
            await supabase.from('health_tips').delete().eq('id', id);
            fetchTips();
        }
    };

    const toggleActive = async (tip: HealthTip) => {
        await supabase.from('health_tips').update({ is_active: !tip.is_active }).eq('id', tip.id);
        fetchTips();
    };

    const generateAITips = async () => {
        setAiLoading(true);
        try {
            const prompt = `Generate ${aiCount} unique health tips. Return ONLY valid JSON array: [{"title":"...","content":"...","category":"health","priority":5}]. Categories: health, nutrition, fitness, mental, product.`;
            const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
            });
            const data = await res.json();
            if (data.candidates?.[0]?.content?.parts?.[0]?.text) {
                let json = data.candidates[0].content.parts[0].text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
                const tips = JSON.parse(json).map((t: any) => ({ ...t, icon: 'favorite', is_active: true }));
                await supabase.from('health_tips').insert(tips);
                alert(`✅ Added ${tips.length} tips!`);
                fetchTips();
            }
        } catch (err) { alert('Error: ' + (err as Error).message); }
        setAiLoading(false);
    };

    const categories = ['health', 'nutrition', 'fitness', 'mental', 'product'];
    const categoryColors: Record<string, string> = {
        health: '#ef4444', nutrition: '#22c55e', fitness: '#f97316', mental: '#a855f7', product: '#3b82f6'
    };

    return (
        <AdminLayout title="Health Tips" subtitle="Manage and generate health tips with AI">
            {/* Action Bar */}
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, marginBottom: 24 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'linear-gradient(135deg, #10b981, #059669)', borderRadius: 12, padding: '0 16px', height: 48 }}>
                    <input type="number" min="1" max="20" value={aiCount} onChange={(e) => setAiCount(parseInt(e.target.value) || 5)}
                        style={{ width: 48, background: 'rgba(255,255,255,0.2)', border: 'none', borderRadius: 8, color: 'white', textAlign: 'center', padding: '6px', fontSize: 14 }} />
                    <button onClick={generateAITips} disabled={aiLoading}
                        style={{ background: 'none', border: 'none', color: 'white', fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6, fontSize: 14, opacity: aiLoading ? 0.6 : 1 }}>
                        {aiLoading ? '⏳ Generating...' : '🤖 AI Generate'}
                    </button>
                </div>
                <button onClick={() => setShowForm(true)}
                    style={{ height: 48, padding: '0 24px', background: 'linear-gradient(135deg, #6366f1, #a855f7)', color: 'white', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8, fontSize: 14 }}>
                    ➕ Add New Tip
                </button>
            </div>

            {/* Premium Modal Form */}
            {showForm && (
                <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: 16, backdropFilter: 'blur(4px)' }} onClick={() => resetForm()}>
                    <div style={{ background: 'white', borderRadius: 24, width: '100%', maxWidth: 520, maxHeight: '90vh', overflow: 'auto', boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)' }} onClick={e => e.stopPropagation()}>
                        {/* Modal Header */}
                        <div style={{ padding: '24px 24px 0 24px' }}>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                                    <div style={{ width: 48, height: 48, borderRadius: 14, background: 'linear-gradient(135deg, #6366f1, #a855f7)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <span style={{ fontSize: 24 }}>{editingTip ? '✏️' : '💡'}</span>
                                    </div>
                                    <div>
                                        <h2 style={{ margin: 0, fontSize: 22, fontWeight: 700, color: '#1e293b' }}>{editingTip ? 'Edit Health Tip' : 'Add New Health Tip'}</h2>
                                        <p style={{ margin: 0, fontSize: 13, color: '#64748b' }}>Fill in the details below</p>
                                    </div>
                                </div>
                                <button onClick={resetForm} style={{ background: '#f1f5f9', border: 'none', width: 36, height: 36, borderRadius: 10, cursor: 'pointer', fontSize: 18, color: '#64748b' }}>✕</button>
                            </div>
                        </div>

                        {/* Form */}
                        <form onSubmit={handleSubmit} style={{ padding: 24 }}>
                            {/* Title */}
                            <div style={{ marginBottom: 20 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>📌 Title</label>
                                <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Enter tip title..."
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', transition: 'border 0.2s', boxSizing: 'border-box' }}
                                    onFocus={(e) => e.target.style.borderColor = '#6366f1'} onBlur={(e) => e.target.style.borderColor = '#e2e8f0'} required />
                            </div>

                            {/* Content */}
                            <div style={{ marginBottom: 20 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>📝 Content</label>
                                <textarea value={content} onChange={(e) => setContent(e.target.value)} placeholder="Write detailed health tip content..."
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', minHeight: 100, resize: 'vertical', fontFamily: 'inherit', boxSizing: 'border-box' }}
                                    onFocus={(e) => e.target.style.borderColor = '#6366f1'} onBlur={(e) => e.target.style.borderColor = '#e2e8f0'} required />
                            </div>

                            {/* Image URL */}
                            <div style={{ marginBottom: 20 }}>
                                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>🖼️ Image URL (Optional)</label>
                                <input type="url" value={imageUrl} onChange={(e) => setImageUrl(e.target.value)} placeholder="https://example.com/image.jpg"
                                    style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }}
                                    onFocus={(e) => e.target.style.borderColor = '#6366f1'} onBlur={(e) => e.target.style.borderColor = '#e2e8f0'} />
                                {imageUrl && (
                                    <div style={{ marginTop: 12, borderRadius: 12, overflow: 'hidden', border: '2px solid #e2e8f0' }}>
                                        <img src={imageUrl} alt="Preview" style={{ width: '100%', height: 120, objectFit: 'cover' }} onError={(e) => (e.target as HTMLImageElement).style.display = 'none'} />
                                    </div>
                                )}
                            </div>

                            {/* Category & Priority */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 20 }}>
                                <div>
                                    <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>🏷️ Category</label>
                                    <select value={category} onChange={(e) => setCategory(e.target.value)}
                                        style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', cursor: 'pointer', background: 'white', boxSizing: 'border-box' }}>
                                        {categories.map(c => <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 8 }}>⭐ Priority (1-10)</label>
                                    <input type="number" min="1" max="10" value={priority} onChange={(e) => setPriority(parseInt(e.target.value))}
                                        style={{ width: '100%', padding: '14px 16px', border: '2px solid #e2e8f0', borderRadius: 12, fontSize: 15, color: '#1e293b', outline: 'none', boxSizing: 'border-box' }} />
                                </div>
                            </div>

                            {/* Active Toggle */}
                            <div style={{ marginBottom: 24, padding: 16, background: '#f8fafc', borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                <div>
                                    <p style={{ margin: 0, fontWeight: 600, color: '#374151', fontSize: 14 }}>Status</p>
                                    <p style={{ margin: 0, fontSize: 12, color: '#64748b' }}>Show this tip in the app</p>
                                </div>
                                <label style={{ position: 'relative', display: 'inline-block', width: 52, height: 28 }}>
                                    <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)}
                                        style={{ opacity: 0, width: 0, height: 0 }} />
                                    <span style={{
                                        position: 'absolute', cursor: 'pointer', inset: 0,
                                        background: isActive ? '#22c55e' : '#cbd5e1',
                                        borderRadius: 28, transition: 'background 0.3s'
                                    }}>
                                        <span style={{
                                            position: 'absolute', content: '', height: 22, width: 22,
                                            left: isActive ? 26 : 3, bottom: 3,
                                            background: 'white', borderRadius: '50%', transition: 'left 0.3s',
                                            boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
                                        }}></span>
                                    </span>
                                </label>
                            </div>

                            {/* Buttons */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                                <button type="button" onClick={resetForm}
                                    style={{ padding: '14px', background: '#f1f5f9', color: '#475569', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15 }}>
                                    Cancel
                                </button>
                                <button type="submit"
                                    style={{ padding: '14px', background: 'linear-gradient(135deg, #6366f1, #a855f7)', color: 'white', fontWeight: 600, borderRadius: 12, border: 'none', cursor: 'pointer', fontSize: 15 }}>
                                    {editingTip ? '💾 Update Tip' : '✨ Create Tip'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Tips List */}
            {loading ? (
                <div style={{ display: 'flex', justifyContent: 'center', padding: 48 }}>
                    <div style={{ width: 48, height: 48, border: '4px solid #e0e7ff', borderTopColor: '#6366f1', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                </div>
            ) : (
                <div style={{ display: 'grid', gap: 12 }}>
                    {tips.map((tip) => (
                        <div key={tip.id} style={{ background: 'white', borderRadius: 16, padding: 16, boxShadow: '0 1px 3px rgba(0,0,0,0.1)', display: 'flex', flexDirection: 'column', gap: 12 }}>
                            <div style={{ display: 'flex', gap: 12 }}>
                                {tip.image_url && (
                                    <img src={tip.image_url} alt="" style={{ width: 80, height: 80, borderRadius: 12, objectFit: 'cover', flexShrink: 0 }} />
                                )}
                                <div style={{ flex: 1, minWidth: 0 }}>
                                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 8 }}>
                                        <span style={{ padding: '4px 10px', borderRadius: 20, fontSize: 11, fontWeight: 600, background: `${categoryColors[tip.category]}20`, color: categoryColors[tip.category] }}>
                                            {tip.category}
                                        </span>
                                        <button onClick={() => toggleActive(tip)} style={{ padding: '4px 10px', borderRadius: 20, fontSize: 11, fontWeight: 600, background: tip.is_active ? '#dcfce7' : '#f1f5f9', color: tip.is_active ? '#16a34a' : '#64748b', border: 'none', cursor: 'pointer' }}>
                                            {tip.is_active ? '✓ Active' : 'Inactive'}
                                        </button>
                                    </div>
                                    <p style={{ margin: 0, fontWeight: 600, color: '#1e293b', fontSize: 15 }}>{tip.title}</p>
                                    <p style={{ margin: '4px 0 0 0', color: '#64748b', fontSize: 13, overflow: 'hidden', textOverflow: 'ellipsis', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>{tip.content}</p>
                                </div>
                            </div>
                            <div style={{ display: 'flex', gap: 8, borderTop: '1px solid #f1f5f9', paddingTop: 12 }}>
                                <button onClick={() => handleEdit(tip)} style={{ flex: 1, padding: '10px', background: '#ede9fe', color: '#7c3aed', fontWeight: 600, borderRadius: 10, border: 'none', cursor: 'pointer', fontSize: 13 }}>✏️ Edit</button>
                                <button onClick={() => handleDelete(tip.id)} style={{ flex: 1, padding: '10px', background: '#fee2e2', color: '#dc2626', fontWeight: 600, borderRadius: 10, border: 'none', cursor: 'pointer', fontSize: 13 }}>🗑️ Delete</button>
                            </div>
                        </div>
                    ))}
                    {tips.length === 0 && <p style={{ textAlign: 'center', padding: 48, color: '#64748b' }}>No tips yet. Use AI Generate or add manually!</p>}
                </div>
            )}

            <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </AdminLayout>
    );
}
