import { useState } from 'react';
import AppLayout from '../components/AppLayout';

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
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">🚨 Report Fraudulent Scam</h1>
          <p className="text-slate-500 text-xs mt-1">
            Submit suspicious UPI handles, phishing URLs, or scam SMS. Approved reports will be added to the global blacklist database for community protection.
          </p>
        </div>

        <div className="bg-white p-6 md:p-8 rounded-[20px] border border-slate-200 shadow-sm">
          {submitted ? (
            <div className="p-8 text-center bg-emerald-50 border border-emerald-200 rounded-2xl">
              <div className="text-5xl mb-3">✅</div>
              <h3 className="text-xl font-extrabold text-emerald-900 mb-2">Report Submitted Successfully!</h3>
              <p className="text-xs text-emerald-700 mb-6">
                Your report for <b>{target}</b> has been queued for Admin Moderation (<b>nandakumarreddy63@gmail.com</b>).
              </p>
              <button
                type="button"
                className="bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 px-6 rounded-full text-xs transition shadow"
                onClick={() => { setSubmitted(false); setTarget(''); setReason(''); setProofText(''); }}
              >
                Report Another Scam Entity
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  Scam Category
                </label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-700"
                >
                  <option value="UPI">💳 UPI ID / VPA Handle</option>
                  <option value="URL">🔗 Phishing Web Link</option>
                  <option value="SMS">💬 SMS / WhatsApp Message</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  Reported Entity / Target
                </label>
                <input
                  type="text"
                  placeholder={type === 'UPI' ? 'e.g. fake-refund-care@ybl' : type === 'URL' ? 'e.g. http://fake-bank-login.com' : 'e.g. +919876543210'}
                  value={target}
                  onChange={(e) => setTarget(e.target.value)}
                  required
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  Reason / What Happened?
                </label>
                <textarea
                  rows={3}
                  placeholder="Describe how the scam occurred, e.g. Asked to enter UPI PIN to receive refund..."
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  required
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  Evidence Notes / Screenshot URL Proof (Optional)
                </label>
                <input
                  type="text"
                  placeholder="e.g. Screenshot link or message text evidence"
                  value={proofText}
                  onChange={(e) => setProofText(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>

              <button
                type="submit"
                className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3.5 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
              >
                🚨 Submit Report for Admin Moderation
              </button>
            </form>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
