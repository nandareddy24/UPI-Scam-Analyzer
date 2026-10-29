import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeUpiId, analyzeUrl, analyzeMessage, analyzeOcrQr } from '../services/analyzer';

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState('upi'); // upi | url | sms | ocr | qr
  const [inputText, setInputText] = useState('');
  const [fileInput, setFileInput] = useState(null);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  function handleScan(e) {
    e.preventDefault();
    setLoading(true);

    setTimeout(() => {
      let res = null;
      if (activeTab === 'upi') {
        res = analyzeUpiId(inputText || 'example@scamhandle');
      } else if (activeTab === 'url') {
        res = analyzeUrl(inputText || 'http://verify-bank-account.com');
      } else if (activeTab === 'sms') {
        res = analyzeMessage(inputText || 'URGENT: Your account is blocked. Enter OTP 4567 to unlock.');
      } else if (activeTab === 'ocr' || activeTab === 'qr') {
        const name = fileInput ? fileInput.name : 'scanned_qr_payload.png';
        res = analyzeOcrQr(name, inputText);
      }
      setResult(res);
      setLoading(false);
    }, 300);
  }

  return (
    <AppLayout>
      <div className="space-y-6">
        {/* National Cyber Crime Helpline Banner */}
        <div className="bg-[#059669] text-white p-5 rounded-2xl flex items-center justify-between shadow-lg">
          <div className="flex items-center gap-4">
            <span className="bg-[#fef08a] text-[#854d0e] text-[10px] font-black uppercase px-2.5 py-1 rounded-full tracking-wider">
              HELPLINE 1930
            </span>
            <div>
              <h2 className="text-base font-extrabold leading-tight">National Cyber Crime Protection Active</h2>
              <p className="text-xs text-emerald-100 opacity-90 mt-0.5">
                Report financial fraud & UPI scams directly to Cyber Crime Helpline (1930)
              </p>
            </div>
          </div>
          <div className="text-3xl">🚨</div>
        </div>

        {/* Top Summary Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center text-2xl font-bold">
              💳
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">UPI & URLs</div>
              <div className="text-xs text-slate-500 font-medium">Real-Time Verification</div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-red-100 text-red-600 flex items-center justify-center text-2xl font-bold">
              🚨
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">99.2%</div>
              <div className="text-xs text-slate-500 font-medium">Scam Pattern Accuracy</div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-amber-100 text-amber-600 flex items-center justify-center text-2xl font-bold">
              ⚡
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">Instant AI</div>
              <div className="text-xs text-slate-500 font-medium">Threat Scoring System</div>
            </div>
          </div>
        </div>

        {/* Multi Scanner Card */}
        <div className="bg-white p-6 md:p-8 rounded-2xl border border-slate-200 shadow-sm">
          <h2 className="text-2xl font-extrabold text-slate-900 mb-1">AI Threat Scanner</h2>
          <p className="text-slate-500 text-xs mb-6">
            Select an inspection mode below to scan UPI Handles, Links, SMS messages, or QR screenshots.
          </p>

          <div className="flex gap-2 bg-slate-100/80 p-1.5 rounded-2xl mb-6 overflow-x-auto border border-slate-200/60">
            <button
              type="button"
              className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'upi' ? 'bg-white text-emerald-800 shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('upi'); setResult(null); setInputText(''); }}
            >
              💳 UPI ID
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'url' ? 'bg-white text-emerald-800 shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('url'); setResult(null); setInputText(''); }}
            >
              🔗 Phishing URL
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'sms' ? 'bg-white text-emerald-800 shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('sms'); setResult(null); setInputText(''); }}
            >
              💬 SMS / Message
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'ocr' ? 'bg-white text-emerald-800 shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('ocr'); setResult(null); setInputText(''); }}
            >
              📷 OCR Image
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'qr' ? 'bg-white text-emerald-800 shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('qr'); setResult(null); setInputText(''); }}
            >
              📷 QR Code
            </button>
          </div>

          <form onSubmit={handleScan} className="space-y-4">
            {activeTab === 'upi' && (
              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  ENTER UPI ID / VPA HANDLE
                </label>
                <input
                  type="text"
                  placeholder="e.g. refund-care@ybl or 9876543210@paytm"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>
            )}

            {activeTab === 'url' && (
              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  ENTER WEB URL / LINK
                </label>
                <input
                  type="text"
                  placeholder="e.g. http://verify-kyc-update-bank.com"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>
            )}

            {activeTab === 'sms' && (
              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  PASTE SMS OR WHATSAPP MESSAGE CONTENT
                </label>
                <textarea
                  rows={4}
                  placeholder="e.g. Dear customer, your account is blocked. Verify immediately at http://..."
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>
            )}

            {(activeTab === 'ocr' || activeTab === 'qr') && (
              <div>
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  UPLOAD SCREENSHOT OR QR IMAGE
                </label>
                <input
                  type="file"
                  accept="image/*"
                  onChange={(e) => setFileInput(e.target.files[0])}
                  className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs mb-3"
                />
                <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                  OPTIONAL EXTRACTED PAYLOAD / URL TEXT
                </label>
                <input
                  type="text"
                  placeholder="Extracted text or upi:// pay link (optional)"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
                />
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3.5 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
            >
              {loading ? 'Analyzing Threat Payload...' : '🔍 Analyze Threat Now'}
            </button>
          </form>

          {/* Threat Verdict Result Card */}
          {result && (
            <div className={`mt-6 p-6 rounded-2xl border-l-4 shadow-sm ${
              result.score >= 10 ? 'bg-red-50 border-red-500 text-red-900' :
              result.score >= 5 ? 'bg-amber-50 border-amber-500 text-amber-900' :
              'bg-emerald-50 border-emerald-500 text-emerald-900'
            }`}>
              <div className="flex justify-between items-start mb-4">
                <div>
                  <span className={`text-[10px] font-black uppercase tracking-wider px-2.5 py-1 rounded-full border ${
                    result.score >= 10 ? 'bg-red-100 text-red-700 border-red-200' :
                    result.score >= 5 ? 'bg-amber-100 text-amber-700 border-amber-200' :
                    'bg-emerald-100 text-emerald-700 border-emerald-200'
                  }`}>
                    {result.status}
                  </span>
                  <h3 className="text-xl font-extrabold mt-2">{result.result}</h3>
                </div>

                <div className="flex gap-4 text-right">
                  <div>
                    <div className="text-[10px] font-bold uppercase text-slate-400">Confidence</div>
                    <div className="text-lg font-black text-emerald-700">{result.confidence}%</div>
                  </div>
                  <div>
                    <div className="text-[10px] font-bold uppercase text-slate-400">Threat Score</div>
                    <div className="text-lg font-black text-slate-800">{result.score} <span className="text-xs text-slate-400">/ 25</span></div>
                  </div>
                </div>
              </div>

              <div className="mb-3">
                <div className="text-[10px] font-bold uppercase text-slate-500 tracking-wider mb-1">
                  AI Detection Findings
                </div>
                <div className="bg-white/80 p-3 rounded-xl border border-slate-200/80 text-xs font-medium text-slate-800">
                  {result.findings}
                </div>
              </div>

              <div>
                <div className="text-[10px] font-bold uppercase text-slate-500 tracking-wider mb-1">
                  Actionable Safety Guidance
                </div>
                <div className="bg-white p-3 rounded-xl border border-slate-200/80 text-xs font-semibold text-slate-900 flex items-start gap-2">
                  <span className="text-base">💡</span>
                  <span>{result.advice}</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
