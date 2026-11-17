import { Link } from 'react-router-dom';
import { Shield, ArrowLeft, Lock, CheckCircle2, FileText } from '../components/Icons';
import Footer from '../components/Footer';

export default function PrivacyPolicy() {
  return (
    <div className="min-h-screen bg-slate-50 flex flex-col font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Top Navigation Bar */}
      <header className="bg-white border-b border-slate-200 sticky top-0 z-30">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Link to="/" className="flex items-center gap-2.5 text-slate-900 hover:text-emerald-700 transition-colors">
              <div className="w-8 h-8 rounded-lg bg-slate-900 text-emerald-400 flex items-center justify-center">
                <Shield className="w-4 h-4" />
              </div>
              <span className="font-bold text-base tracking-tight">UPI Scam Analyzer</span>
            </Link>
          </div>
          <Link
            to="/"
            className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-md transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Back to Dashboard</span>
          </Link>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 max-w-4xl mx-auto px-4 sm:px-6 py-10 w-full">
        <div className="bg-white border border-slate-200 rounded-lg p-6 sm:p-10 shadow-sm space-y-8">
          {/* Header */}
          <div className="border-b border-slate-200 pb-6">
            <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold uppercase tracking-wider mb-3">
              <FileText className="w-3.5 h-3.5" />
              <span>Legal Document</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight">
              Privacy Policy
            </h1>
            <p className="text-slate-500 text-xs mt-2">
              Effective Date: November 17, 2026 | Last Updated: November 17, 2026
            </p>
          </div>

          {/* Section 1: Overview */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">1. Overview and Purpose</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              UPI Scam Analyzer operates as an independent cyber safety utility dedicated to helping individuals and organizations verify digital payment identifiers, URLs, and communication snippets before financial transactions occur. This Privacy Policy describes how we collect, handle, store, and safeguard your information in accordance with applicable Indian data protection principles and standard security practices.
            </p>
          </section>

          {/* Section 2: Data We Collect */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">2. Information We Process</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              We practice strict data minimization. Depending on how you interact with our utility, we process the following categories of information:
            </p>
            <div className="space-y-2.5 text-sm text-slate-600">
              <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-md">
                <strong className="text-slate-800 block text-xs uppercase tracking-wide mb-1">A. Analysis Input Data</strong>
                UPI Virtual Payment Addresses (VPAs), web URLs, SMS or messaging text snippets, and uploaded screenshot images submitted specifically for fraud pattern analysis.
              </div>
              <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-md">
                <strong className="text-slate-800 block text-xs uppercase tracking-wide mb-1">B. Account Identifiers</strong>
                When you create an account, we collect your verified email address and encrypted password hash solely to provide authenticated session management and personal scan audit logs.
              </div>
              <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-md">
                <strong className="text-slate-800 block text-xs uppercase tracking-wide mb-1">C. Technical & Diagnostic Logs</strong>
                Standard HTTP request headers, timestamps, browser user agent strings, and anonymized error traces required for system reliability, performance monitoring, and anti-abuse controls.
              </div>
            </div>
          </section>

          {/* Section 3: How Information Is Used */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">3. How We Use Collected Data</h2>
            <ul className="space-y-2 text-sm text-slate-600 list-disc pl-5 leading-relaxed">
              <li>
                <strong>Heuristic Fraud Evaluation:</strong> Evaluating submitted text and identifiers against recognized fraud indicators, suspicious domain registries, and known scam syntax.
              </li>
              <li>
                <strong>Personal Scan Audit:</strong> Enabling signed-in users to review past scan timestamps, inputs, and risk verdicts in their personal account history.
              </li>
              <li>
                <strong>Threat Intelligence:</strong> Compiling aggregated, non-personally identifiable blacklist statistics to protect other users from recurring fraud campaigns.
              </li>
              <li>
                <strong>Security and Abuse Prevention:</strong> Detecting automated denial of service attacks, scraping attempts, and misuse of public scanning endpoints.
              </li>
            </ul>
          </section>

          {/* Section 4: Data Storage and Security */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">4. Data Storage, Retention, and Security</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              All communications between your browser and our servers are transmitted using Transport Layer Security (TLS 1.3) with standard HTTPS encryption.
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
              <div className="p-3 bg-emerald-50/70 border border-emerald-200 rounded-md text-emerald-950 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-700 flex-shrink-0 mt-0.5" />
                <span>Uploaded images for OCR analysis are processed in memory and not permanently retained on external image servers.</span>
              </div>
              <div className="p-3 bg-emerald-50/70 border border-emerald-200 rounded-md text-emerald-950 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-700 flex-shrink-0 mt-0.5" />
                <span>Passwords are hashed cryptographically using modern salted hash algorithms before storage.</span>
              </div>
            </div>
          </section>

          {/* Section 5: Cookies & Local Storage */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">5. Cookies and Local Storage</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              We do not employ third-party advertising cookies, cross-site trackers, or commercial monetization scripts. Browser LocalStorage and session cookies are utilized exclusively for essential functions:
            </p>
            <ul className="space-y-1.5 text-sm text-slate-600 list-disc pl-5">
              <li>Persisting your authenticated user session token across page navigation.</li>
              <li>Saving UI preferences and client-side offline scan cache.</li>
            </ul>
          </section>

          {/* Section 6: Third-Party Disclosures */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">6. Third-Party Service Providers</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              We do not sell, rent, or lease personal information to third parties. Information may be processed through trusted cloud infrastructure providers (such as Google Firebase) strictly under enterprise confidentiality and security terms for authentication and database management.
            </p>
          </section>

          {/* Section 7: User Rights */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">7. Your Rights and Data Controls</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              You retain full ownership and control over your account data. At any time, you have the right to:
            </p>
            <ul className="space-y-1.5 text-sm text-slate-600 list-disc pl-5">
              <li>Inspect your historical scan records via the Scan History console.</li>
              <li>Clear or delete past scan logs directly from your device.</li>
              <li>Request full account termination and removal of associated email records.</li>
            </ul>
          </section>

          {/* Section 8: Contact */}
          <section className="space-y-3 border-t border-slate-200 pt-6">
            <h2 className="text-lg font-bold text-slate-900">8. Contact Information and Privacy Inquiries</h2>
            <p className="text-slate-600 text-sm leading-relaxed">
              If you have inquiries regarding this Privacy Policy, your data rights, or our technical security measures, please reach out to our privacy team at:
            </p>
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-md text-xs space-y-1 text-slate-700">
              <p><strong>Team:</strong> UPI Scam Analyzer Privacy & Information Security</p>
              <p><strong>Email:</strong> privacy@scamanalyzer.internal</p>
              <p><strong>Cyber Helpline Integration:</strong> Indian Cyber Crime Coordination Centre (I4C), Helpline 1930</p>
            </div>
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}
