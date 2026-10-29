import { useState } from 'react';
import { useLocation, useNavigate, Link } from 'react-router-dom';
import { verifyOtp, sendOtp } from '../api/otpApi';
import { signUp } from '../services/authService';

export default function VerifyOtp() {
  const location = useLocation();
  const navigate = useNavigate();
  const { email, password } = location.state || {};

  const [otp, setOtp] = useState('');
  const [verifying, setVerifying] = useState(false);
  const [resending, setResending] = useState(false);
  const [error, setError] = useState('');
  const [info, setInfo] = useState('');

  if (!email || !password) {
    navigate('/signup');
    return null;
  }

  async function handleVerify(e) {
    e.preventDefault();
    setError('');

    if (otp.trim().length !== 6) {
      setError('Enter the 6-digit code sent to your email.');
      return;
    }

    setVerifying(true);
    const verifyResult = await verifyOtp(email, otp.trim());

    if (!verifyResult.success) {
      setVerifying(false);
      setError(verifyResult.message);
      return;
    }

    const signupResult = await signUp(email, password);
    setVerifying(false);

    if (!signupResult.success) {
      setError(signupResult.message);
      return;
    }

    navigate('/');
  }

  async function handleResend() {
    setResending(true);
    setError('');
    setInfo('');
    const result = await sendOtp(email);
    setResending(false);
    setInfo(result.success ? 'A new code was sent to your email.' : '');
    if (!result.success) setError(result.message);
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-[#f8fafc]">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-emerald-100 text-emerald-700 mb-3 shadow-sm border border-emerald-200">
            <svg className="w-7 h-7 text-emerald-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
            </svg>
          </div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Security Check</h1>
          <p className="text-slate-500 text-xs mt-1">Enter 6-digit verification code</p>
        </div>

        <div className="card-white p-8 bg-white border border-slate-200 shadow-lg rounded-[24px]">
          {error && (
            <div className="mb-6 bg-red-50 border border-red-200 p-4 rounded-2xl flex items-start gap-3 shadow-sm animate-shake">
              <div className="w-7 h-7 rounded-full bg-red-100 text-red-600 flex items-center justify-center flex-shrink-0 font-extrabold text-sm border border-red-200">
                ⚠️
              </div>
              <div className="flex-1">
                <h4 className="text-xs font-bold text-red-800 uppercase tracking-wider">Verification Error</h4>
                <p className="text-xs font-medium text-red-600 mt-0.5 leading-relaxed">{error}</p>
              </div>
            </div>
          )}

          {info && !error && (
            <div className="mb-6 bg-emerald-50 border border-emerald-200 p-4 rounded-2xl flex items-start gap-3 shadow-sm">
              <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center flex-shrink-0 font-extrabold text-sm border border-emerald-200">
                ✓
              </div>
              <div className="flex-1">
                <h4 className="text-xs font-bold text-emerald-800 uppercase tracking-wider">Success</h4>
                <p className="text-xs font-medium text-emerald-700 mt-0.5 leading-relaxed">{info}</p>
              </div>
            </div>
          )}

          <p className="text-xs text-slate-500 mb-6 text-center leading-relaxed">
            A 6-digit verification code has been sent directly to <br />
            <span className="font-bold text-slate-800">{email}</span>. Please check your inbox & spam folder.
          </p>

          <form onSubmit={handleVerify} className="space-y-4">
            <div>
              <input
                type="text"
                name="otp"
                placeholder="••••••"
                required
                maxLength={6}
                value={otp}
                onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                className="w-full py-3.5 bg-slate-50 border border-slate-200 text-center font-mono text-2xl font-bold tracking-[0.3em] rounded-xl focus:outline-none focus:border-emerald-700"
              />
            </div>

            <button
              type="submit"
              disabled={verifying}
              className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
            >
              {verifying ? 'Verifying Account...' : 'Verify & Create Account →'}
            </button>
          </form>

          <div className="mt-6 pt-6 border-t border-slate-100 flex items-center justify-between">
            <Link to="/signup" className="text-xs text-slate-500 hover:text-slate-800">
              ← Back to Registration
            </Link>

            <button
              type="button"
              onClick={handleResend}
              disabled={resending}
              className="text-xs font-bold text-emerald-700 hover:text-emerald-900 transition-colors cursor-pointer"
            >
              {resending ? 'Resending...' : '🔄 Resend OTP Code'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
