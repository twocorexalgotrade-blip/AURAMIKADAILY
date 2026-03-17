"use client";

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Camera, Video, Loader2, ArrowLeft, Plus, X } from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';

const CATEGORIES = ['All', 'Chains', 'Rings', 'Earrings', 'Bracelets'];
const BADGES = ['', 'New', 'Bestseller', 'Hot', 'Sale'];

export default function NewProductForm() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    originalPrice: '',
    quantity: '',
    category: 'All',
    badge: '',
  });

  const [features, setFeatures] = useState<string[]>(['']);
  const [images, setImages] = useState<File[]>([]);
  const [videos, setVideos] = useState<File[]>([]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleFeatureChange = (index: number, value: string) => {
    setFeatures(prev => prev.map((f, i) => i === index ? value : f));
  };

  const addFeature = () => setFeatures(prev => [...prev, '']);
  const removeFeature = (index: number) => setFeatures(prev => prev.filter((_, i) => i !== index));

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, type: 'image' | 'video') => {
    if (e.target.files) {
      const newFiles = Array.from(e.target.files);
      if (type === 'image') setImages(prev => [...prev, ...newFiles]);
      if (type === 'video') setVideos(prev => [...prev, ...newFiles]);
    }
  };

  const removeFile = (index: number, type: 'image' | 'video') => {
    if (type === 'image') setImages(prev => prev.filter((_, i) => i !== index));
    if (type === 'video') setVideos(prev => prev.filter((_, i) => i !== index));
  };

  const uploadFiles = async (files: File[]) => {
    const urls: string[] = [];
    for (const file of files) {
      const data = new FormData();
      data.append('file', file);
      const res = await fetch('/api/admin/upload', { method: 'POST', body: data });
      if (!res.ok) throw new Error('Failed to upload media');
      const { url } = await res.json();
      urls.push(url);
    }
    return urls;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const imageUrls = images.length > 0 ? await uploadFiles(images) : [];
      const videoUrls = videos.length > 0 ? await uploadFiles(videos) : [];

      const productRes = await fetch('/api/products', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          price: parseFloat(formData.price),
          originalPrice: formData.originalPrice ? parseFloat(formData.originalPrice) : null,
          quantity: parseInt(formData.quantity, 10),
          badge: formData.badge || null,
          features: features.filter(f => f.trim() !== ''),
          images: imageUrls,
          videos: videoUrls,
        }),
      });

      if (!productRes.ok) throw new Error('Failed to create product');
      router.push('/admin/products');
      router.refresh();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Something went wrong');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/admin/products" className="p-2 bg-neutral-900 border border-neutral-800 rounded-lg hover:bg-neutral-800 transition-colors">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <h1 className="text-2xl font-bold tracking-tight">Add New Product</h1>
      </div>

      <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-8">
        {error && (
          <div className="mb-6 p-4 bg-red-900/20 border border-red-500/20 text-red-400 rounded-lg text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-8">

          {/* General Information */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold border-b border-neutral-800 pb-2">General Information</h2>

            <div>
              <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="name">Product Name *</label>
              <input id="name" name="name" type="text" required value={formData.name} onChange={handleInputChange}
                className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                placeholder="E.g. Classic Rope Chain" />
            </div>

            <div>
              <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="description">Description *</label>
              <textarea id="description" name="description" required rows={4} value={formData.description} onChange={handleInputChange}
                className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                placeholder="Describe the product in detail..." />
            </div>
          </div>

          {/* Pricing & Inventory */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold border-b border-neutral-800 pb-2">Pricing & Inventory</h2>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="price">Selling Price (₹) *</label>
                <input id="price" name="price" type="number" step="0.01" min="0" required value={formData.price} onChange={handleInputChange}
                  className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                  placeholder="1499.00" />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="originalPrice">Original / MRP (₹)</label>
                <input id="originalPrice" name="originalPrice" type="number" step="0.01" min="0" value={formData.originalPrice} onChange={handleInputChange}
                  className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                  placeholder="2999.00 (shows strikethrough)" />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="quantity">Qty Available *</label>
                <input id="quantity" name="quantity" type="number" min="0" required value={formData.quantity} onChange={handleInputChange}
                  className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                  placeholder="50" />
              </div>
            </div>
          </div>

          {/* Categorisation */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold border-b border-neutral-800 pb-2">Categorisation</h2>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="category">Category *</label>
                <select id="category" name="category" value={formData.category} onChange={handleInputChange}
                  className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100">
                  {CATEGORIES.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="badge">Badge Label</label>
                <select id="badge" name="badge" value={formData.badge} onChange={handleInputChange}
                  className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100">
                  {BADGES.map(b => <option key={b} value={b}>{b || 'None'}</option>)}
                </select>
              </div>
            </div>
          </div>

          {/* Features / Bullet Points */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold border-b border-neutral-800 pb-2">Product Features</h2>
            <p className="text-sm text-neutral-500">These appear as bullet points on the product page (e.g. "18k Gold Plated", "Waterproof")</p>
            <div className="space-y-3">
              {features.map((feature, index) => (
                <div key={index} className="flex gap-2">
                  <input
                    type="text"
                    value={feature}
                    onChange={e => handleFeatureChange(index, e.target.value)}
                    placeholder={`Feature ${index + 1}...`}
                    className="flex-1 px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600"
                  />
                  {features.length > 1 && (
                    <button type="button" onClick={() => removeFeature(index)}
                      className="p-2.5 text-red-400 hover:bg-red-500/10 rounded-lg transition-colors">
                      <X className="w-4 h-4" />
                    </button>
                  )}
                </div>
              ))}
              <button type="button" onClick={addFeature}
                className="flex items-center gap-2 text-sm text-neutral-400 hover:text-white transition-colors">
                <Plus className="w-4 h-4" /> Add Feature
              </button>
            </div>
          </div>

          {/* Media */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold border-b border-neutral-800 pb-2">Media</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Photos */}
              <div className="space-y-3">
                <label className="block text-sm font-medium text-neutral-400">Photos</label>
                <div className="flex flex-wrap gap-3">
                  {images.map((file, i) => (
                    <div key={i} className="relative w-24 h-24 rounded-lg overflow-hidden border border-neutral-700">
                      <Image src={URL.createObjectURL(file)} alt="preview" fill className="object-cover" />
                      <button type="button" onClick={() => removeFile(i, 'image')}
                        className="absolute top-1 right-1 bg-black/50 text-white rounded-full w-5 h-5 flex items-center justify-center hover:bg-black">
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                  <label className="w-24 h-24 flex flex-col items-center justify-center border-2 border-dashed border-neutral-800 rounded-lg cursor-pointer hover:border-neutral-600 hover:bg-neutral-800/50 transition-colors">
                    <Camera className="w-6 h-6 text-neutral-500 mb-1" />
                    <span className="text-xs text-neutral-500 font-medium">Add Photo</span>
                    <input type="file" accept="image/*" multiple onChange={e => handleFileChange(e, 'image')} className="hidden" />
                  </label>
                </div>
              </div>

              {/* Videos */}
              <div className="space-y-3">
                <label className="block text-sm font-medium text-neutral-400">Videos</label>
                <div className="flex flex-wrap gap-3">
                  {videos.map((file, i) => (
                    <div key={i} className="relative w-24 h-24 rounded-lg overflow-hidden border border-neutral-700 bg-black flex items-center justify-center">
                      <Video className="w-8 h-8 text-neutral-600" />
                      <button type="button" onClick={() => removeFile(i, 'video')}
                        className="absolute top-1 right-1 bg-black/50 text-white rounded-full w-5 h-5 flex items-center justify-center hover:bg-black">
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                  <label className="w-24 h-24 flex flex-col items-center justify-center border-2 border-dashed border-neutral-800 rounded-lg cursor-pointer hover:border-neutral-600 hover:bg-neutral-800/50 transition-colors">
                    <Video className="w-6 h-6 text-neutral-500 mb-1" />
                    <span className="text-xs text-neutral-500 font-medium">Add Video</span>
                    <input type="file" accept="video/*" multiple onChange={e => handleFileChange(e, 'video')} className="hidden" />
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div className="pt-4 border-t border-neutral-800">
            <button type="submit" disabled={loading}
              className="w-full flex items-center justify-center py-3 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-all disabled:opacity-50 disabled:cursor-not-allowed">
              {loading ? (
                <><Loader2 className="w-5 h-5 animate-spin mr-2" />Saving Product...</>
              ) : 'Save Product'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
