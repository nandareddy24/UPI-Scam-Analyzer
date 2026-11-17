import { Link } from 'react-router-dom';
import { Shield, PhoneCall, ExternalLink, Lock } from './Icons';

export default function Footer() {
  return (
    <footer className="border-t border-slate-200 bg-white text-slate-600 text-xs mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          {/* Brand & Purpose */}
          <div className="md:col-span-2 space-y-3">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-slate-900 text-emerald-400 flex items-center justify-center">
                <Shield className="w-4 h-4" />
              </div>
              <span className="font-bold text-slate-900 text-sm tracking-tight">UPI Scam Analyzer</span>
            </div>
            <p className="text-slate-500 text-xs leading-relaxed max-w-md">
              A specialized cybersecurity utility dedicated to early detection of UPI fraud, phishing links, and deceptive SMS patterns. Built to empower consumers and protect digital payments in India.
            </p>
            <div className="flex items-center gap-2 text-slate-700 font-medium">
              <PhoneCall className="w-4 h-4 text-emerald-700" />
              <span>National Cyber Crime Helpline: <strong className="text-slate-900">1930</strong> (24x7 Toll Free)</span>
            </div>
          </div>

          {/* Verification Tools */}
          <div>
            <h4 className="font-semibold text-slate-900 text-xs uppercase tracking-wider mb-3">Security Tools</h4>
            <ul className="space-y-2">
              <li><Link to="/upi" className="hover:text-emerald-700 transition-colors">UPI VPA Checker</Link></li>
              <li><Link to="/url" className="hover:text-emerald-700 transition-colors">Phishing URL Scanner</Link></li>
              <li><Link to="/message" className="hover:text-emerald-700 transition-colors">SMS & Message Analyzer</Link></li>
              <li><Link to="/ocr_qr" className="hover:text-emerald-700 transition-colors">OCR & QR Code Scanner</Link></li>
              <li><Link to="/report" className="hover:text-emerald-700 transition-colors">Report Suspicious Fraud</Link></li>
            </ul>
          </div>

          {/* Legal & Governance */}
          <div>
            <h4 className="font-semibold text-slate-900 text-xs uppercase tracking-wider mb-3">Trust & Compliance</h4>
            <ul className="space-y-2">
              <li><Link to="/privacy" className="hover:text-emerald-700 font-medium text-slate-800 transition-colors">Privacy Policy</Link></li>
              <li><Link to="/terms" className="hover:text-emerald-700 font-medium text-slate-800 transition-colors">Terms and Conditions</Link></li>
              <li>
                <a 
                  href="https://cybercrime.gov.in" 
                  target="_blank" 
                  rel="noopener noreferrer" 
                  className="inline-flex items-center gap-1 hover:text-emerald-700 transition-colors"
                >
                  <span>National Cyber Crime Portal</span>
                  <ExternalLink className="w-3 h-3 text-slate-400" />
                </a>
              </li>
              <li>
                <a 
                  href="https://www.npci.org.in" 
                  target="_blank" 
                  rel="noopener noreferrer" 
                  className="inline-flex items-center gap-1 hover:text-emerald-700 transition-colors"
                >
                  <span>NPCI Guidelines</span>
                  <ExternalLink className="w-3 h-3 text-slate-400" />
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4 text-[11px] text-slate-500">
          <p>
            &copy; {new Date().getFullYear()} UPI Scam Analyzer. Educational and preventative cybersecurity utility. Not affiliated with NPCI or RBI.
          </p>
          <div className="flex items-center gap-4">
            <Link to="/privacy" className="hover:underline">Privacy</Link>
            <span>&bull;</span>
            <Link to="/terms" className="hover:underline">Terms</Link>
            <span>&bull;</span>
            <span className="flex items-center gap-1">
              <Lock className="w-3 h-3 text-emerald-700" />
              <span>TLS 1.3 Encrypted</span>
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
}
