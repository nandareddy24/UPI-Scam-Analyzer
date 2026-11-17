import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { AlertTriangle, CheckCircle2, ArrowRight } from '../components/Icons';

export default function ReportScam() {
  const [type, setType] = useState('UPI');
  const [target, setTarget] = useState('');
  const [reason, setReason] = useState('');
  const [proofText, setProofText] = useState('');
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e) {
    e.preventDefault();
    if (!target.trim() || !reason.trim()) return;
    setSubmitted(true);
  }

  return (
    <AppLayout>
      <div className="space-y-6 max-w-3xl">
        <div className="border-b border-slate-200 pb-4">
          <div className="flex items-center gap-2.5 mb-1">
            <div className="w-8 h-8 rounded-md bg-red-50 border border-red-200 text-red-700 flex items-center justify-center">
              <AlertTriangle className="w-4 h-4" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Report Fraudulent Entity</h1>
          </div>
          <p className="text-xs text-slate-500">
            Submit suspicious UPI handles, phishing web links, or deceptive SMS senders. Verified entries are flagged in the heuristic blacklist to warn other users.
          </p>
        </div>

        <div className="bg-white p-6 sm:p-8 rounded-lg border border-slate-200 shadow-sm">
          {submitted ? (
            <div className="p-8 text-center bg-emerald-50 border border-emerald-200 rounded-lg space-y-4">
              <div className="w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center mx-auto">
                <CheckCircle2 className="w-6 h-6" />
              </div>
              <div>
                <h3 className="text-base font-bold text-emerald-950">Report Submitted for Verification</h3>
                <p className="text-xs text-emerald-800 mt-1 max-w-md mx-auto leading-relaxed">
                  Your report for <strong className="font-mono text-emerald-950">{target}</strong> has been logged into the moderation review queue.
                </p>
              </div>
              <button
                type="button"
                className="bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2 px-4 rounded-md text-xs transition-colors shadow-sm"
                onClick={() => { setSubmitted(false); setTarget(''); setReason(''); setProofText(''); }}
              >
                Submit Another Report
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Threat Category
                </label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-semibold text-slate-800 focus:outline-none focus:border-emerald-700"
                >
                  <option value="UPI">UPI Virtual Payment Address (VPA)</option>
                  <option value="URL">Phishing Web Link / Domain</option>
                  <option value="SMS">SMS or WhatsApp Message Sender</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Reported Identifier or Link
                </label>
                <input
                  type="text"
                  placeholder={
                    type === 'UPI'
                      ? 'e.g. fake-refund-care@ybl'
                      : type === 'URL'
                      ? 'e.g. http://fake-bank-login.com'
                      : 'e.g. +919876543210'
                  }
                  value={target}
                  onChange={(e) => setTarget(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Details of the Scam Incident
                </label>
                <textarea
                  rows={3}
                  placeholder="Describe the fraud method, e.g. caller impersonated customer support and requested a collect authorization..."
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Evidence Notes or Source URL (Optional)
                </label>
                <input
                  type="text"
                  placeholder="e.g. Screenshot URL, SMS sender header (e.g. VK-SBIINB)"
                  value={proofText}
                  onChange={(e) => setProofText(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 px-4 rounded-md text-xs tracking-wide transition-colors shadow-sm inline-flex items-center justify-center gap-2"
                >
                  <span>Submit Fraud Report</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
