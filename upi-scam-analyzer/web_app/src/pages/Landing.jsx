import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { 
  Shield, 
  CreditCard, 
  LinkIcon, 
  MessageSquare, 
  QrCode, 
  ArrowRight, 
  PhoneCall, 
  Lock, 
  CheckCircle2, 
  AlertTriangle,
  Search,
  ExternalLink
} from '../components/Icons';
import Footer from '../components/Footer';

export default function Landing() {
  const navigate = useNavigate();
  const [quickInput, setQuickInput] = useState('');
  const [quickType, setQuickType] = useState('upi');

  function handleQuickCheck(e) {
    e.preventDefault();
    if (!quickInput.trim()) return;
    
    // Redirect to login or appropriate analyzer route
    if (quickType === 'upi') {
      navigate('/login');
    } else if (quickType === 'url') {
      navigate('/login');
    } else {
      navigate('/login');
    }
  }

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col text-slate-900 font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Navigation Header */}
      <header className="bg-white border-b border-slate-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-slate-900 text-emerald-400 flex items-center justify-center">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <span className="font-bold text-base tracking-tight text-slate-900">UPI Scam Analyzer</span>
              <span className="hidden sm:inline-block ml-2 text-[10px] font-semibold text-slate-500 uppercase tracking-wider border-l border-slate-200 pl-2">
                Cyber Safety Utility
              </span>
            </div>
          </div>

          <nav className="flex items-center gap-3 sm:gap-4">
            <a 
              href="#tools" 
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 hidden md:block transition-colors"
            >
              Inspection Tools
            </a>
            <a 
              href="#guidelines" 
              className="text-xs font-semibold text-slate-600 hover:text-slate-900 hidden md:block transition-colors"
            >
              Safety Rules
            </a>
            <Link
              to="/login"
              className="text-xs font-semibold text-slate-700 hover:text-slate-900 px-3 py-2 rounded-md hover:bg-slate-100 transition-colors"
            >
              Sign In
            </Link>
            <Link
              to="/signup"
              className="text-xs font-semibold text-white bg-[#047857] hover:bg-[#065f46] px-4 py-2 rounded-md transition-colors shadow-sm inline-flex items-center gap-1.5"
            >
              <span>Get Started</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </nav>
        </div>
      </header>

      {/* Emergency Helpline Banner */}
      <div className="bg-slate-900 text-white border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-2.5 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs">
          <div className="flex items-center gap-2">
            <span className="inline-flex items-center justify-center px-2 py-0.5 rounded bg-red-600 text-white font-bold text-[10px] uppercase tracking-wider">
              Emergency
            </span>
            <span className="text-slate-300">
              Active financial fraud victim? Contact the National Cyber Crime Helpline immediately:
            </span>
            <strong className="text-white font-bold underline">1930</strong>
          </div>
          <a
            href="https://cybercrime.gov.in"
            target="_blank"
            rel="noopener noreferrer"
            className="text-emerald-400 hover:text-emerald-300 font-semibold inline-flex items-center gap-1 text-[11px]"
          >
            <span>cybercrime.gov.in</span>
            <ExternalLink className="w-3 h-3" />
          </a>
        </div>
      </div>

      {/* Hero Section */}
      <section className="bg-white border-b border-slate-200 py-12 sm:py-20">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-slate-100 border border-slate-200 text-slate-700 text-xs font-semibold uppercase tracking-wider mb-6">
            <Lock className="w-3.5 h-3.5 text-emerald-700" />
            <span>Independent Digital Payment Protection</span>
          </div>

          <h1 className="text-3xl sm:text-5xl font-extrabold text-slate-900 tracking-tight leading-tight mb-5 max-w-4xl mx-auto">
            Verify Suspicious UPI Handles, Links, and Fraudulent Messages
          </h1>

          <p className="text-base sm:text-lg text-slate-600 mb-8 max-w-2xl mx-auto leading-relaxed">
            A focused cyber safety tool providing instant heuristic threat analysis for payment identifiers, phishing URLs, and SMS lures before any transaction takes place.
          </p>

          {/* Quick Lookup Card */}
          <div className="max-w-2xl mx-auto bg-slate-50 border border-slate-200 rounded-lg p-4 sm:p-5 shadow-sm text-left">
            <div className="flex gap-2 border-b border-slate-200 pb-3 mb-3 text-xs font-semibold text-slate-600">
              <button
                type="button"
                onClick={() => setQuickType('upi')}
                className={`px-3 py-1.5 rounded transition-colors ${
                  quickType === 'upi' ? 'bg-slate-900 text-white font-bold' : 'hover:bg-slate-200 text-slate-700'
                }`}
              >
                UPI VPA Handle
              </button>
              <button
                type="button"
                onClick={() => setQuickType('url')}
                className={`px-3 py-1.5 rounded transition-colors ${
                  quickType === 'url' ? 'bg-slate-900 text-white font-bold' : 'hover:bg-slate-200 text-slate-700'
                }`}
              >
                Web Link / URL
              </button>
              <button
                type="button"
                onClick={() => setQuickType('sms')}
                className={`px-3 py-1.5 rounded transition-colors ${
                  quickType === 'sms' ? 'bg-slate-900 text-white font-bold' : 'hover:bg-slate-200 text-slate-700'
                }`}
              >
                SMS Message Text
              </button>
            </div>

            <form onSubmit={handleQuickCheck} className="flex flex-col sm:flex-row gap-2">
              <div className="relative flex-1">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <Search className="w-4 h-4" />
                </div>
                <input
                  type="text"
                  placeholder={
                    quickType === 'upi'
                      ? 'e.g. cashback-claim@ybl or refund-care@oksbi'
                      : quickType === 'url'
                      ? 'e.g. http://192.168.1.10/verify-bank-account'
                      : 'Paste suspicious message snippet here...'
                  }
                  value={quickInput}
                  onChange={(e) => setQuickInput(e.target.value)}
                  className="w-full pl-9 pr-3 py-2.5 text-xs bg-white border border-slate-300 rounded-md focus:outline-none focus:border-emerald-700 font-medium"
                />
              </div>
              <button
                type="submit"
                className="bg-[#047857] hover:bg-[#065f46] text-white px-5 py-2.5 rounded-md text-xs font-bold transition-colors shadow-sm flex items-center justify-center gap-1.5 whitespace-nowrap"
              >
                <span>Verify Payload</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </form>

            <p className="text-[11px] text-slate-500 mt-2.5">
              Sign in or create a free account to view detailed confidence metrics, full audit history, and OCR extraction.
            </p>
          </div>
        </div>
      </section>

      {/* Core Tools Section */}
      <section id="tools" className="py-14 sm:py-18 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-12">
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
            Specialized Threat Verification Suite
          </h2>
          <p className="text-sm text-slate-600 mt-2">
            Each scanner module utilizes targeted heuristic rules aligned with known Indian cyber fraud trends.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Card 1 */}
          <div className="bg-white border border-slate-200 rounded-lg p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div className="w-10 h-10 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center mb-4">
                <CreditCard className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">UPI Identifier Verification</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Inspects suspicious Virtual Payment Addresses against known patterns of impersonation, fraudulent refund desks, lottery claims, and unauthorized payment handles.
              </p>
            </div>
            <div className="pt-4 mt-4 border-t border-slate-100">
              <Link to="/upi" className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 inline-flex items-center gap-1">
                <span>Open UPI Checker</span>
                <ArrowRight className="w-3 h-3" />
              </Link>
            </div>
          </div>

          {/* Card 2 */}
          <div className="bg-white border border-slate-200 rounded-lg p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div className="w-10 h-10 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center mb-4">
                <LinkIcon className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">Phishing Link Inspector</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Evaluates URLs for raw IP address routing, deceptive banking subdomains, unencrypted protocols, and disguised link shorteners used in credential harvesting.
              </p>
            </div>
            <div className="pt-4 mt-4 border-t border-slate-100">
              <Link to="/url" className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 inline-flex items-center gap-1">
                <span>Open Link Scanner</span>
                <ArrowRight className="w-3 h-3" />
              </Link>
            </div>
          </div>

          {/* Card 3 */}
          <div className="bg-white border border-slate-200 rounded-lg p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div className="w-10 h-10 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center mb-4">
                <MessageSquare className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">SMS & Messaging Lures</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Flags deceptive keywords common in electricity bill threats, fake lottery awards, urgent bank KYC verification requests, and malicious APK installation lures.
              </p>
            </div>
            <div className="pt-4 mt-4 border-t border-slate-100">
              <Link to="/message" className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 inline-flex items-center gap-1">
                <span>Open SMS Analyzer</span>
                <ArrowRight className="w-3 h-3" />
              </Link>
            </div>
          </div>

          {/* Card 4 */}
          <div className="bg-white border border-slate-200 rounded-lg p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div className="w-10 h-10 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center mb-4">
                <QrCode className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">OCR & QR Code Scanner</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Extracts payment URLs, recipient VPAs, and requested amounts from QR code images or transaction screenshots for automated safety analysis before scanning in UPI apps.
              </p>
            </div>
            <div className="pt-4 mt-4 border-t border-slate-100">
              <Link to="/ocr_qr" className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 inline-flex items-center gap-1">
                <span>Open QR Inspector</span>
                <ArrowRight className="w-3 h-3" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Safety Guidelines Section (Educational & Authentic) */}
      <section id="guidelines" className="bg-white border-t border-b border-slate-200 py-14">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="border-b border-slate-200 pb-6 mb-8 text-center sm:text-left">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-700">Crucial Awareness</span>
            <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight mt-1">
              Essential Rules for UPI Safety
            </h2>
            <p className="text-xs text-slate-500 mt-1">
              Recognized recommendations published by the National Payments Corporation of India (NPCI).
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-5 bg-slate-50 border border-slate-200 rounded-lg space-y-2">
              <div className="w-8 h-8 rounded bg-red-100 text-red-700 flex items-center justify-center font-bold text-xs">
                Rule 1
              </div>
              <h3 className="text-sm font-bold text-slate-900">Never Enter PIN to Receive Money</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                A UPI PIN is exclusively required to debit money from your account. Receiving funds or cashbacks never requires entering your secret PIN.
              </p>
            </div>

            <div className="p-5 bg-slate-50 border border-slate-200 rounded-lg space-y-2">
              <div className="w-8 h-8 rounded bg-amber-100 text-amber-700 flex items-center justify-center font-bold text-xs">
                Rule 2
              </div>
              <h3 className="text-sm font-bold text-slate-900">Verify Beneficiary Name in App</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Always confirm the actual account holder name displayed by the banking network on your phone screen before entering any amount or authorization.
              </p>
            </div>

            <div className="p-5 bg-slate-50 border border-slate-200 rounded-lg space-y-2">
              <div className="w-8 h-8 rounded bg-blue-100 text-blue-700 flex items-center justify-center font-bold text-xs">
                Rule 3
              </div>
              <h3 className="text-sm font-bold text-slate-900">Act Fast in the Golden Hour</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                If money has been wrongfully transferred, dial 1930 immediately. Rapid reporting within the first hour gives law enforcement the highest chance of freezing funds.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Call to Action Bar */}
      <section className="bg-slate-900 text-white py-12">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 text-center space-y-5">
          <h2 className="text-2xl sm:text-3xl font-bold tracking-tight">
            Protect Your Digital Transactions Today
          </h2>
          <p className="text-slate-400 text-xs sm:text-sm max-w-xl mx-auto leading-relaxed">
            Create an account to retain a persistent log of verified handles, monitor community blacklist updates, and report active fraud attempts.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
            <Link
              to="/signup"
              className="w-full sm:w-auto px-6 py-2.5 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold rounded-md transition-colors shadow-sm"
            >
              Create Free Account
            </Link>
            <Link
              to="/login"
              className="w-full sm:w-auto px-6 py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold rounded-md border border-slate-700 transition-colors"
            >
              Sign In to Existing Account
            </Link>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}
