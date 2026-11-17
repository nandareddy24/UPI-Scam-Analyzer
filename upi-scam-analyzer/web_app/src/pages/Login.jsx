import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { login } from '../services/authService';
import { Shield, Lock, AlertCircle, ArrowRight } from '../components/Icons';

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
      setError('Enter your account password.');
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
    <div className="min-h-screen flex flex-col justify-between p-4 sm:p-6 bg-slate-50 font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="flex-1 flex items-center justify-center">
        <div className="w-full max-w-md">
          {/* Logo & Header */}
          <div className="text-center mb-6">
            <Link to="/" className="inline-flex items-center gap-2 mb-3 text-slate-900 hover:text-emerald-800 transition-colors">
              <div className="w-10 h-10 rounded-lg bg-slate-900 text-emerald-400 flex items-center justify-center">
                <Shield className="w-5 h-5" />
              </div>
              <span className="font-extrabold text-xl tracking-tight text-slate-900">UPI Scam Analyzer</span>
            </Link>
            <p className="text-slate-500 text-xs">Sign in to access your threat analysis dashboard</p>
          </div>

          {/* Login Card */}
          <div className="bg-white border border-slate-200 shadow-sm rounded-lg p-6 sm:p-8">
            <div className="mb-6 border-b border-slate-200 pb-3">
              <h2 className="text-lg font-bold text-slate-900">Account Authentication</h2>
              <p className="text-slate-500 text-xs mt-0.5">Enter your registered email address and password.</p>
            </div>

            {error && (
              <div className="mb-5 bg-red-50 border border-red-200 p-3.5 rounded-md flex items-start gap-2.5 text-xs text-red-800">
                <AlertCircle className="w-4 h-4 text-red-600 flex-shrink-0 mt-0.5" />
                <div className="leading-relaxed">
                  <strong className="block text-red-900 font-bold">Authentication Error</strong>
                  {error}
                </div>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Email Address
                </label>
                <input
                  type="email"
                  placeholder="name@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>

              <div>
                <div className="flex justify-between items-center mb-1.5">
                  <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide">
                    Password
                  </label>
                  <Link to="/verify-otp" className="text-xs font-semibold text-emerald-700 hover:text-emerald-800">
                    Forgot Password?
                  </Link>
                </div>
                <input
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 px-4 rounded-md text-xs tracking-wide transition-colors shadow-sm inline-flex items-center justify-center gap-2"
                >
                  <span>{loading ? 'Authenticating...' : 'Sign In to Security Dashboard'}</span>
                  {!loading && <ArrowRight className="w-3.5 h-3.5" />}
                </button>
              </div>
            </form>

            <div className="mt-6 pt-5 border-t border-slate-100 text-center">
              <p className="text-xs text-slate-600">
                Do not have an account?{' '}
                <Link to="/signup" className="text-emerald-700 font-bold hover:underline">
                  Create Free Account
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Accessible Legal Footer */}
      <footer className="text-center py-4 text-xs text-slate-500 space-x-3">
        <Link to="/privacy" className="hover:text-slate-800">Privacy Policy</Link>
        <span>&bull;</span>
        <Link to="/terms" className="hover:text-slate-800">Terms of Service</Link>
        <span>&bull;</span>
        <Link to="/" className="hover:text-slate-800">Home</Link>
      </footer>
    </div>
  );
}
