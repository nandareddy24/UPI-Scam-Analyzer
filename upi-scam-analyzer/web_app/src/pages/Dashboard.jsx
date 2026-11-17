import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeUpiId, analyzeUrl, analyzeMessage, analyzeOcrQr } from '../services/analyzer';
import { 
  CreditCard, 
  LinkIcon, 
  MessageSquare, 
  Camera, 
  QrCode, 
  Search, 
  ShieldAlert, 
  ShieldCheck, 
  AlertTriangle, 
  CheckCircle2, 
  PhoneCall, 
  Info,
  ExternalLink
} from '../components/Icons';

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
    }, 250);
  }

  return (
    <AppLayout>
      <div className="space-y-6">
        {/* National Cyber Crime Helpline Notice */}
        <div className="bg-slate-900 text-white p-5 rounded-lg border border-slate-800 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-start sm:items-center gap-3">
            <div className="w-10 h-10 rounded-md bg-emerald-600 text-white flex items-center justify-center flex-shrink-0">
              <PhoneCall className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-bold uppercase tracking-wider bg-emerald-800 text-emerald-200 px-2 py-0.5 rounded">
                  Helpline 1930
                </span>
                <span className="text-xs font-semibold text-slate-300">National Cyber Crime Portal</span>
              </div>
              <p className="text-xs text-slate-300 mt-1">
                If you have been targeted by financial fraud, contact the national helpline immediately to initiate account freezing within the golden hour.
              </p>
            </div>
          </div>
          <a
            href="https://cybercrime.gov.in"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-400 hover:text-emerald-300 bg-slate-800 hover:bg-slate-700 px-3.5 py-2 rounded-md border border-slate-700 transition-colors whitespace-nowrap self-start sm:self-center"
          >
            <span>Official Portal</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
        </div>

        {/* System Capabilities Overview (Authentic & Verified) */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm flex items-center gap-3.5">
            <div className="w-10 h-10 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center flex-shrink-0">
              <CreditCard className="w-5 h-5" />
            </div>
            <div>
              <div className="text-sm font-bold text-slate-900">Multi-Vector Scanner</div>
              <div className="text-xs text-slate-500">UPI VPAs, URLs, SMS & QR Codes</div>
            </div>
          </div>

          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm flex items-center gap-3.5">
            <div className="w-10 h-10 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center flex-shrink-0">
              <ShieldCheck className="w-5 h-5 text-emerald-700" />
            </div>
            <div>
              <div className="text-sm font-bold text-slate-900">Heuristic Threat Scoring</div>
              <div className="text-xs text-slate-500">Pattern analysis & blacklist matching</div>
            </div>
          </div>

          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm flex items-center gap-3.5">
            <div className="w-10 h-10 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center flex-shrink-0">
              <Info className="w-5 h-5 text-blue-700" />
            </div>
            <div>
              <div className="text-sm font-bold text-slate-900">NPCI Safety Standards</div>
              <div className="text-xs text-slate-500">Guidance on PIN & beneficiary checks</div>
            </div>
          </div>
        </div>

        {/* Multi-Scanner Form Card */}
        <div className="bg-white p-6 sm:p-8 rounded-lg border border-slate-200 shadow-sm">
          <div className="border-b border-slate-200 pb-4 mb-6">
            <h2 className="text-xl font-bold text-slate-900">Payment Safety Scanner</h2>
            <p className="text-xs text-slate-500 mt-1">
              Select an analysis category to inspect suspicious payment identifiers before proceeding.
            </p>
          </div>

          {/* Clean Segmented Tab Buttons */}
          <div className="flex gap-1.5 bg-slate-100 p-1 rounded-md mb-6 overflow-x-auto border border-slate-200 text-xs font-semibold">
            <button
              type="button"
              className={`flex-1 py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'upi' ? 'bg-white text-slate-900 font-bold shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('upi'); setResult(null); setInputText(''); }}
            >
              <CreditCard className="w-4 h-4 text-emerald-700" />
              <span>UPI VPA</span>
            </button>
            <button
              type="button"
              className={`flex-1 py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'url' ? 'bg-white text-slate-900 font-bold shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('url'); setResult(null); setInputText(''); }}
            >
              <LinkIcon className="w-4 h-4 text-emerald-700" />
              <span>Web URL</span>
            </button>
            <button
              type="button"
              className={`flex-1 py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'sms' ? 'bg-white text-slate-900 font-bold shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('sms'); setResult(null); setInputText(''); }}
            >
              <MessageSquare className="w-4 h-4 text-emerald-700" />
              <span>SMS / Message</span>
            </button>
            <button
              type="button"
              className={`flex-1 py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'ocr' ? 'bg-white text-slate-900 font-bold shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('ocr'); setResult(null); setInputText(''); }}
            >
              <Camera className="w-4 h-4 text-emerald-700" />
              <span>Screenshot OCR</span>
            </button>
            <button
              type="button"
              className={`flex-1 py-2 px-3 rounded text-xs transition-colors flex items-center justify-center gap-2 whitespace-nowrap ${
                activeTab === 'qr' ? 'bg-white text-slate-900 font-bold shadow-sm' : 'text-slate-600 hover:text-slate-900'
              }`}
              onClick={() => { setActiveTab('qr'); setResult(null); setInputText(''); }}
            >
              <QrCode className="w-4 h-4 text-emerald-700" />
              <span>QR Code</span>
            </button>
          </div>

          <form onSubmit={handleScan} className="space-y-4">
            {activeTab === 'upi' && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  UPI Virtual Payment Address (VPA)
                </label>
                <input
                  type="text"
                  placeholder="e.g. cashback-support@ybl or refund-care@oksbi"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>
            )}

            {activeTab === 'url' && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  Target Website Link or URL
                </label>
                <input
                  type="text"
                  placeholder="e.g. http://192.168.1.10/verify-bank-account or http://kyc-update.com"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>
            )}

            {activeTab === 'sms' && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                  SMS or WhatsApp Message Content
                </label>
                <textarea
                  rows={4}
                  placeholder="Paste message content here, e.g. Dear customer, your electricity connection will be disconnected tonight. Call 9876543210..."
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                />
              </div>
            )}

            {(activeTab === 'ocr' || activeTab === 'qr') && (
              <div className="space-y-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                    Select Screenshot or QR Image File
                  </label>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={(e) => setFileInput(e.target.files[0])}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-300 rounded-md text-xs text-slate-700"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                    Optional Extracted UPI Text or URL
                  </label>
                  <input
                    type="text"
                    placeholder="Extracted upi:// link or text payload (optional)"
                    value={inputText}
                    onChange={(e) => setInputText(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
                  />
                </div>
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 px-4 rounded-md text-xs tracking-wide transition-colors shadow-sm inline-flex items-center justify-center gap-2"
            >
              {loading ? (
                <span>Inspecting Payload...</span>
              ) : (
                <>
                  <Search className="w-3.5 h-3.5" />
                  <span>Execute Threat Analysis</span>
                </>
              )}
            </button>
          </form>

          {/* Verdict Result Card */}
          {result && (
            <div className={`mt-6 p-5 rounded-md border-l-4 shadow-sm ${
              result.score >= 10 ? 'bg-red-50 border-red-600 text-red-950' :
              result.score >= 5 ? 'bg-amber-50 border-amber-600 text-amber-950' :
              'bg-emerald-50 border-emerald-600 text-emerald-950'
            }`}>
              <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-3 border-b border-black/10 pb-3 mb-4">
                <div className="flex items-center gap-2.5">
                  {result.score >= 10 ? (
                    <ShieldAlert className="w-5 h-5 text-red-600 flex-shrink-0" />
                  ) : result.score >= 5 ? (
                    <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0" />
                  ) : (
                    <ShieldCheck className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                  )}
                  <div>
                    <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded border ${
                      result.score >= 10 ? 'bg-red-100 text-red-800 border-red-200' :
                      result.score >= 5 ? 'bg-amber-100 text-amber-800 border-amber-200' :
                      'bg-emerald-100 text-emerald-800 border-emerald-200'
                    }`}>
                      {result.status}
                    </span>
                    <h3 className="text-base font-bold mt-1 text-slate-900">{result.result}</h3>
                  </div>
                </div>

                <div className="flex items-center gap-4 text-xs">
                  <div>
                    <div className="text-[10px] font-semibold uppercase text-slate-500">Confidence</div>
                    <div className="text-sm font-bold text-slate-900">{result.confidence}%</div>
                  </div>
                  <div>
                    <div className="text-[10px] font-semibold uppercase text-slate-500">Risk Score</div>
                    <div className="text-sm font-bold text-slate-900">{result.score} / 25</div>
                  </div>
                </div>
              </div>

              <div className="space-y-3 text-xs">
                <div>
                  <span className="font-bold uppercase text-[10px] tracking-wide text-slate-700 block mb-1">
                    Detection Findings
                  </span>
                  <div className="bg-white/80 p-3 rounded border border-black/5 text-slate-800 leading-relaxed font-medium">
                    {result.findings}
                  </div>
                </div>

                <div>
                  <span className="font-bold uppercase text-[10px] tracking-wide text-slate-700 block mb-1">
                    Safety Guidance
                  </span>
                  <div className="bg-white p-3 rounded border border-black/5 text-slate-900 leading-relaxed font-semibold flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-700 flex-shrink-0 mt-0.5" />
                    <span>{result.advice}</span>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
