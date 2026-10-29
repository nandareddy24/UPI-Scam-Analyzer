import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { sendOtp } from '../api/otpApi';

export default function Signup() {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters long.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);
    const result = await sendOtp(email);
    setLoading(false);

    if (!result.success) {
      setError(result.message);
      return;
    }

    navigate('/verify-otp', { state: { email, password, name } });
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-[#eef1f5]">
      <div className="w-full max-w-md my-6">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-emerald-100 text-emerald-700 mb-3 shadow-sm border border-emerald-200">
            <svg className="w-7 h-7 text-emerald-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
            </svg>
          </div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Create Account</h1>
          <p className="text-slate-500 text-xs mt-1">Join the Scam Shield Protection Platform</p>
        </div>

        <div className="card-white p-8 bg-white border border-slate-200 shadow-lg rounded-[24px]">
          {error && (
            <div className="mb-6 bg-red-50 border border-red-200 p-4 rounded-2xl flex items-start gap-3 shadow-sm animate-shake">
              <div className="w-7 h-7 rounded-full bg-red-100 text-red-600 flex items-center justify-center flex-shrink-0 font-extrabold text-sm border border-red-200">
                ⚠️
              </div>
              <div className="flex-1">
                <h4 className="text-xs font-bold text-red-800 uppercase tracking-wider">Registration Error</h4>
                <p className="text-xs font-medium text-red-600 mt-0.5 leading-relaxed">{error}</p>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Full Name</label>
              <input
                type="text"
                placeholder="John Doe"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>

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
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Password</label>
              <input
                type="password"
                placeholder="Create password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Confirm Password</label>
              <input
                type="password"
                placeholder="Repeat password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
            >
              {loading ? 'Sending Code...' : 'Send Verification Code →'}
            </button>
          </form>

          <div className="mt-6 pt-6 border-t border-slate-100 text-center">
            <p className="text-xs text-slate-500">
              Already registered?{' '}
              <Link to="/login" className="text-emerald-700 font-bold hover:underline ml-1">
                Sign In
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
