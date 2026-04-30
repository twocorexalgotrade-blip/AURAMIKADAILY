'use client';

import { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

function LoginForm() {
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const searchParams = useSearchParams();
  const callbackUrl = searchParams.get('callbackUrl') || '/admin';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const res = await fetch('/api/admin/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password }),
      });

      if (res.ok) {
        router.push(callbackUrl);
        router.refresh();
      } else {
        const data = await res.json();
        setError(data.error || 'Invalid password');
      }
    } catch (err) {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      {error && (
        <div className="mb-4 p-3 text-sm text-red-400 bg-red-900/20 border border-red-500/20 rounded-lg">
          {error}
        </div>
      )}
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-neutral-400 mb-1.5" htmlFor="password">
            Admin Password
          </label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full px-4 py-2.5 bg-neutral-950 border border-neutral-800 rounded-lg focus:outline-none focus:ring-2 focus:ring-white/20 text-neutral-100 placeholder-neutral-600 transition-all"
            placeholder="Enter passcode"
            required
          />
        </div>
        <button
          type="submit"
          disabled={loading}
          className="w-full py-2.5 px-4 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 focus:outline-none focus:ring-2 focus:ring-white/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Authenticating...' : 'Enter Portal'}
        </button>
      </form>
    </>
  );
}

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-neutral-950 text-neutral-100">
      <div className="w-full max-w-sm p-8 bg-neutral-900 border border-neutral-800 rounded-2xl shadow-xl">
        <h1 className="text-2xl font-bold mb-6 text-center tracking-wide">Admin Portal</h1>
        <Suspense fallback={<div className="text-center text-neutral-500">Loading...</div>}>
          <LoginForm />
        </Suspense>
      </div>
    </div>
  );
}
