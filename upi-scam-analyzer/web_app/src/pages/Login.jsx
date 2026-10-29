import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { login } from '../services/authService';

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Enter a valid email address.');
      return;
    }
    if (!password) {
      setError('Enter your password.');
      return;
    }

    setLoading(true);
    const result = await login(email, password);
    setLoading(false);

    if (!result.success) {
      setError(result.message);
      return;
    }
    navigate('/');
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-[#f8fafc]">
      <div className="w-full max-w-md">
        {/* Logo & Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-emerald-100 text-emerald-700 mb-3 shadow-sm border border-emerald-200">
            <svg className="w-7 h-7 text-emerald-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
            </svg>
          </div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Scam Shield</h1>
          <p className="text-slate-500 text-xs mt-1">UPI & Cyber Fraud Intelligence Platform</p>
        </div>

        {/* Login Card */}
        <div className="card-white p-8 bg-white border border-slate-200 shadow-lg rounded-[24px]">
          <div className="mb-6">
            <h2 className="text-xl font-extrabold text-slate-900">Sign In to Account</h2>
            <p className="text-slate-500 text-xs mt-1">Enter your credentials to access security analysis tools.</p>
          </div>

          {error && (
            <div className="mb-6 bg-red-50 border border-red-200 p-4 rounded-2xl flex items-start gap-3 shadow-sm animate-shake">
              <div className="w-7 h-7 rounded-full bg-red-100 text-red-600 flex items-center justify-center flex-shrink-0 font-extrabold text-sm border border-red-200">
                ⚠️
              </div>
              <div className="flex-1">
                <h4 className="text-xs font-bold text-red-800 uppercase tracking-wider">Invalid Credentials</h4>
                <p className="text-xs font-medium text-red-600 mt-0.5 leading-relaxed">{error}</p>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Email Address</label>
              <input
                type="email"
                placeholder="name@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider">Password</label>
                <Link to="/verify-otp" className="text-[11px] font-bold text-emerald-700 hover:underline">
                  Forgot Password?
                </Link>
              </div>
              <input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
            >
              {loading ? 'Authenticating...' : 'Sign In to Dashboard →'}
            </button>
          </form>

          <div className="mt-6 pt-6 border-t border-slate-100 text-center">
            <p className="text-xs text-slate-500">
              Don't have an account?{' '}
              <Link to="/signup" className="text-emerald-700 font-bold hover:underline ml-1">
                Create Account
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
