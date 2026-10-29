import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeUrl } from '../services/analyzer';

export default function UrlAnalyzer() {
  const [url, setUrl] = useState('');
  const [result, setResult] = useState(null);

  function handleCheck(e) {
    e.preventDefault();
    if (!url.trim()) return;
    setResult(analyzeUrl(url));
  }

  return (
    <AppLayout>
      <div className="space-y-6 max-w-3xl">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">🔗 Phishing URL & Link Analyzer</h1>
          <p className="text-slate-500 text-xs mt-1">
            Detect fake banking websites, IP-based links, link shorteners, and credential harvesting pages.
          </p>
        </div>

        <div className="bg-white p-6 md:p-8 rounded-[20px] border border-slate-200 shadow-sm">
          <form onSubmit={handleCheck} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">
                Target Web Link / URL
              </label>
              <input
                type="text"
                placeholder="e.g. http://192.168.1.1/login or http://verify-kyc-bank.com"
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
              />
            </div>
            <button
              type="submit"
              className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3.5 px-4 rounded-full text-xs tracking-wide transition-colors shadow"
            >
              Analyze Link Safety →
            </button>
          </form>

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

                <div className="text-right">
                  <div className="text-[10px] font-bold uppercase text-slate-400">Threat Score</div>
                  <div className="text-lg font-black text-slate-800">{result.score} <span className="text-xs text-slate-400">/ 25</span></div>
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
