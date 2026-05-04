'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import Image from 'next/image';
import { Store, Plus, RefreshCw, Copy, Check, X, ShieldCheck, Upload } from 'lucide-react';

interface Vendor {
  id: string;
  name: string;
  description: string | null;
  is_verified: boolean;
  rating: number;
  username: string | null;
  last_login: string | null;
  product_count: number;
  created_at: string;
}

interface Credentials {
  username: string;
  password: string;
}

export default function AdminVendors() {
  const [vendors, setVendors] = useState<Vendor[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [credentials, setCredentials] = useState<Credentials | null>(null);
  const [credentialVendorName, setCredentialVendorName] = useState('');
  const [copied, setCopied] = useState<'username' | 'password' | null>(null);
  const [creating, setCreating] = useState(false);
  const [resettingId, setResettingId] = useState<string | null>(null);

  const [form, setForm] = useState({ name: '', description: '', logo_url: '' });
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);
  const [uploadingLogo, setUploadingLogo] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);
  const logoInputRef = useRef<HTMLInputElement>(null);

  const fetchVendors = useCallback(async () => {
    setLoading(true);
    const res = await fetch('/api/admin/vendors');
    const data = await res.json() as { vendors: Vendor[] };
    setVendors(data.vendors ?? []);
    setLoading(false);
  }, []);

  useEffect(() => { void fetchVendors(); }, [fetchVendors]);

  function handleLogoChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setLogoFile(file);
    setLogoPreview(URL.createObjectURL(file));
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setCreating(true);

    let logo_url = form.logo_url;
    if (logoFile) {
      setUploadingLogo(true);
      setUploadError(null);
      const fd = new FormData();
      fd.append('file', logoFile);
      const up = await fetch('/api/admin/upload', { method: 'POST', body: fd });
      const upData = await up.json() as { url?: string; error?: string };
      setUploadingLogo(false);
      if (!up.ok || !upData.url) {
        setUploadError(upData.error ?? 'Upload failed — check Cloudinary credentials in .env.local');
        setCreating(false);
        return;
      }
      logo_url = upData.url;
    }

    const res = await fetch('/api/admin/vendors', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...form, logo_url }),
    });
    const data = await res.json() as { vendor: { name: string }; credentials: Credentials };
    setCreating(false);
    setShowCreateForm(false);
    setForm({ name: '', description: '', logo_url: '' });
    setLogoFile(null);
    setLogoPreview(null);
    setCredentialVendorName(data.vendor.name);
    setCredentials(data.credentials);
    void fetchVendors();
  }

  async function handleReset(vendorId: string, vendorName: string) {
    if (!confirm(`Reset credentials for ${vendorName}? The existing password will stop working immediately.`)) return;
    setResettingId(vendorId);
    const res = await fetch(`/api/admin/vendors/${vendorId}/credentials`, { method: 'POST' });
    const data = await res.json() as Credentials;
    setResettingId(null);
    setCredentialVendorName(vendorName);
    setCredentials(data);
  }

  function copyToClipboard(text: string, field: 'username' | 'password') {
    void navigator.clipboard.writeText(text);
    setCopied(field);
    setTimeout(() => setCopied(null), 2000);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Vendors</h1>
          <p className="text-neutral-400 mt-1">Manage vendor accounts and credentials</p>
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="flex items-center gap-2 px-4 py-2 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-colors"
        >
          <Plus className="w-4 h-4" /> Add Vendor
        </button>
      </div>

      {/* Create form modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-neutral-900 border border-neutral-700 rounded-2xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-lg font-semibold">New Vendor</h2>
              <button onClick={() => setShowCreateForm(false)} className="text-neutral-400 hover:text-white">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={(e) => { void handleCreate(e); }} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-neutral-300 mb-1">Shop Name *</label>
                <input
                  required
                  value={form.name}
                  onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-neutral-500"
                  placeholder="e.g. Riya Jewels"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-300 mb-1">Description</label>
                <textarea
                  value={form.description}
                  onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
                  rows={2}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-neutral-500 resize-none"
                  placeholder="Short description of the vendor..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-300 mb-1">Logo</label>
                <input
                  ref={logoInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleLogoChange}
                />
                {logoPreview ? (
                  <div className="relative w-full h-28 rounded-lg overflow-hidden border border-neutral-700 bg-neutral-800">
                    <Image src={logoPreview} alt="Logo preview" fill className="object-contain p-2" />
                    <button
                      type="button"
                      onClick={() => { setLogoFile(null); setLogoPreview(null); }}
                      className="absolute top-1.5 right-1.5 bg-black/60 hover:bg-black/80 rounded-full p-1 transition-colors"
                    >
                      <X className="w-3.5 h-3.5 text-white" />
                    </button>
                  </div>
                ) : (
                  <button
                    type="button"
                    onClick={() => logoInputRef.current?.click()}
                    className="w-full h-28 rounded-lg border border-dashed border-neutral-700 hover:border-neutral-500 bg-neutral-800 hover:bg-neutral-700/50 flex flex-col items-center justify-center gap-1.5 transition-colors text-neutral-500 hover:text-neutral-300"
                  >
                    <Upload className="w-5 h-5" />
                    <span className="text-xs">Click to upload logo</span>
                  </button>
                )}
              </div>
              {uploadError && (
                <p className="text-xs text-red-400 bg-red-500/10 border border-red-500/20 rounded-lg px-3 py-2">{uploadError}</p>
              )}
              <button
                type="submit"
                disabled={creating}
                className="w-full bg-white text-black font-semibold py-2 rounded-lg hover:bg-neutral-200 transition-colors disabled:opacity-50"
              >
                {uploadingLogo ? 'Uploading logo…' : creating ? 'Creating…' : 'Create & Generate Credentials'}
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Credentials reveal modal — shown once after create or reset */}
      {credentials && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-neutral-900 border border-amber-500/40 rounded-2xl p-6 w-full max-w-md">
            <div className="flex items-center gap-3 mb-4">
              <ShieldCheck className="w-6 h-6 text-amber-400 shrink-0" />
              <div>
                <h2 className="text-lg font-semibold">Credentials for {credentialVendorName}</h2>
                <p className="text-xs text-amber-400 mt-0.5">Save these now — the password will not be shown again.</p>
              </div>
            </div>
            <div className="space-y-3">
              <CredentialRow label="Username" value={credentials.username} field="username" copied={copied} onCopy={copyToClipboard} />
              <CredentialRow label="Password" value={credentials.password} field="password" copied={copied} onCopy={copyToClipboard} />
            </div>
            <button
              onClick={() => setCredentials(null)}
              className="mt-5 w-full bg-neutral-800 hover:bg-neutral-700 text-white font-medium py-2 rounded-lg transition-colors"
            >
              I have saved these credentials
            </button>
          </div>
        </div>
      )}

      {/* Vendors table */}
      <div className="bg-neutral-900 border border-neutral-800 rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-neutral-500">Loading…</div>
        ) : vendors.length === 0 ? (
          <div className="p-12 text-center text-neutral-500">
            <Store className="w-8 h-8 mx-auto mb-3 opacity-40" />
            <p>No vendors yet. Add your first vendor above.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-neutral-950 border-b border-neutral-800 text-neutral-400 font-medium">
                <tr>
                  <th className="px-6 py-4">Vendor</th>
                  <th className="px-6 py-4">Username</th>
                  <th className="px-6 py-4">Products</th>
                  <th className="px-6 py-4">Last Login</th>
                  <th className="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-neutral-800">
                {vendors.map(v => (
                  <tr key={v.id} className="hover:bg-neutral-800/40 transition-colors">
                    <td className="px-6 py-4">
                      <p className="font-medium">{v.name}</p>
                      {v.description && <p className="text-xs text-neutral-500 mt-0.5 line-clamp-1">{v.description}</p>}
                    </td>
                    <td className="px-6 py-4 font-mono text-xs text-neutral-300">
                      {v.username ?? <span className="text-neutral-600">—</span>}
                    </td>
                    <td className="px-6 py-4 text-neutral-400">{v.product_count}</td>
                    <td className="px-6 py-4 text-neutral-400 text-xs">
                      {v.last_login
                        ? new Date(v.last_login).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
                        : <span className="text-neutral-600">Never</span>}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => { void handleReset(v.id, v.name); }}
                        disabled={resettingId === v.id}
                        className="flex items-center gap-1.5 ml-auto text-xs text-neutral-400 hover:text-white border border-neutral-700 hover:border-neutral-500 px-3 py-1.5 rounded-lg transition-colors disabled:opacity-50"
                      >
                        <RefreshCw className={`w-3.5 h-3.5 ${resettingId === v.id ? 'animate-spin' : ''}`} />
                        Reset Credentials
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

function CredentialRow({
  label, value, field, copied, onCopy,
}: {
  label: string;
  value: string;
  field: 'username' | 'password';
  copied: 'username' | 'password' | null;
  onCopy: (text: string, field: 'username' | 'password') => void;
}) {
  return (
    <div className="bg-neutral-800 rounded-lg px-4 py-3 flex items-center justify-between gap-3">
      <div className="min-w-0">
        <p className="text-xs text-neutral-500 mb-0.5">{label}</p>
        <p className="font-mono text-sm text-white break-all">{value}</p>
      </div>
      <button
        onClick={() => onCopy(value, field)}
        className="shrink-0 p-1.5 rounded-md hover:bg-neutral-700 transition-colors"
      >
        {copied === field ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4 text-neutral-400" />}
      </button>
    </div>
  );
}
