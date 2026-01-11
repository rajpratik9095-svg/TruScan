'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import AdminLayout from '@/components/AdminLayout';

interface Ad {
    id: number;
    title: string;
    description: string;
    image_url: string;
    action_url: string;
    category: string;
    is_active: boolean;
    created_at: string;
}

export default function AdsPage() {
    const [ads, setAds] = useState<Ad[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editingAd, setEditingAd] = useState<Ad | null>(null);

    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [imageUrl, setImageUrl] = useState('');
    const [actionUrl, setActionUrl] = useState('');
    const [category, setCategory] = useState('general');
    const [isActive, setIsActive] = useState(true);

    useEffect(() => { fetchAds(); }, []);

    const fetchAds = async () => {
        setLoading(true);
        const { data } = await supabase.from('ads').select('*').order('created_at', { ascending: false });
        if (data) setAds(data);
        setLoading(false);
    };

    const resetForm = () => {
        setTitle(''); setDescription(''); setImageUrl(''); setActionUrl('');
        setCategory('general'); setIsActive(true); setEditingAd(null); setShowForm(false);
    };

    const handleEdit = (ad: Ad) => {
        setEditingAd(ad); setTitle(ad.title); setDescription(ad.description);
        setImageUrl(ad.image_url); setActionUrl(ad.action_url);
        setCategory(ad.category); setIsActive(ad.is_active); setShowForm(true);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const adData = { title, description, image_url: imageUrl, action_url: actionUrl, category, is_active: isActive };
        if (editingAd) await supabase.from('ads').update(adData).eq('id', editingAd.id);
        else await supabase.from('ads').insert([adData]);
        resetForm(); fetchAds();
    };

    const handleDelete = async (id: number) => {
        if (confirm('Delete this ad?')) {
            await supabase.from('ads').delete().eq('id', id);
            fetchAds();
        }
    };

    const toggleActive = async (ad: Ad) => {
        await supabase.from('ads').update({ is_active: !ad.is_active }).eq('id', ad.id);
        fetchAds();
    };

    const categories = ['general', 'health', 'fitness', 'nutrition', 'product'];

    return (
        <AdminLayout title="Advertisements" subtitle="Manage ads shown in the app">
            {/* Add Button */}
            <button onClick={() => setShowForm(true)}
                className="mb-6 px-5 py-3 bg-gradient-to-r from-pink-500 to-orange-500 text-white font-semibold rounded-xl flex items-center gap-2">
                ➕ Create Ad
            </button>

            {/* Form Modal */}
            {showForm && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => resetForm()}>
                    <div className="bg-white rounded-2xl p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
                        <h2 className="text-xl font-bold text-slate-800 mb-4">{editingAd ? 'Edit Ad' : 'Create Ad'}</h2>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Ad Title"
                                className="w-full px-4 py-3 border rounded-xl text-slate-800" required />
                            <textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description"
                                className="w-full px-4 py-3 border rounded-xl text-slate-800 h-20" required />
                            <input type="url" value={imageUrl} onChange={(e) => setImageUrl(e.target.value)} placeholder="Image URL"
                                className="w-full px-4 py-3 border rounded-xl text-slate-800" />
                            <input type="url" value={actionUrl} onChange={(e) => setActionUrl(e.target.value)} placeholder="Click URL"
                                className="w-full px-4 py-3 border rounded-xl text-slate-800" />
                            <select value={category} onChange={(e) => setCategory(e.target.value)}
                                className="w-full px-4 py-3 border rounded-xl text-slate-800">
                                {categories.map(c => <option key={c} value={c}>{c}</option>)}
                            </select>
                            <label className="flex items-center gap-2">
                                <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} className="w-5 h-5" />
                                <span className="text-slate-700">Active</span>
                            </label>
                            <div className="flex gap-3">
                                <button type="submit" className="flex-1 py-3 bg-pink-500 text-white font-semibold rounded-xl">Save</button>
                                <button type="button" onClick={resetForm} className="flex-1 py-3 bg-slate-200 text-slate-700 rounded-xl">Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Ads Grid */}
            {loading ? (
                <div className="flex justify-center py-12">
                    <div className="w-12 h-12 border-4 border-pink-200 border-t-pink-600 rounded-full animate-spin"></div>
                </div>
            ) : (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {ads.map((ad) => (
                        <div key={ad.id} className="bg-white rounded-xl overflow-hidden shadow-sm">
                            {ad.image_url && (
                                <img src={ad.image_url} alt={ad.title} className="w-full h-32 object-cover" />
                            )}
                            <div className="p-4">
                                <div className="flex items-center gap-2 mb-2">
                                    <span className="px-2 py-1 bg-pink-100 text-pink-700 rounded text-xs">{ad.category}</span>
                                    <button onClick={() => toggleActive(ad)}
                                        className={`px-2 py-1 rounded text-xs ${ad.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'}`}>
                                        {ad.is_active ? '✓ Active' : 'Inactive'}
                                    </button>
                                </div>
                                <p className="font-semibold text-slate-800 truncate">{ad.title}</p>
                                <p className="text-slate-500 text-sm truncate">{ad.description}</p>
                                <div className="flex gap-2 mt-3">
                                    <button onClick={() => handleEdit(ad)} className="flex-1 py-2 bg-indigo-50 text-indigo-600 rounded-lg text-sm">✏️ Edit</button>
                                    <button onClick={() => handleDelete(ad.id)} className="flex-1 py-2 bg-red-50 text-red-600 rounded-lg text-sm">🗑️ Delete</button>
                                </div>
                            </div>
                        </div>
                    ))}
                    {ads.length === 0 && <p className="col-span-full text-center py-12 text-slate-500">No ads yet. Create your first ad!</p>}
                </div>
            )}
        </AdminLayout>
    );
}
