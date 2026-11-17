import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeUrl } from '../services/analyzer';
import { LinkIcon, Search, ShieldAlert, ShieldCheck, AlertTriangle, CheckCircle2 } from '../components/Icons';

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
        <div className="border-b border-slate-200 pb-4">
          <div className="flex items-center gap-2.5 mb-1">
            <div className="w-8 h-8 rounded-md bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center">
              <LinkIcon className="w-4 h-4" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Phishing Link & URL Scanner</h1>
          </div>
          <p className="text-xs text-slate-500">
            Detect deceptive banking subdomains, raw IP destinations, link shorteners, and credential phishing pages.
          </p>
        </div>

        <div className="bg-white p-6 sm:p-8 rounded-lg border border-slate-200 shadow-sm">
          <form onSubmit={handleCheck} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 uppercase tracking-wide mb-1.5">
                Target Web Link or URL
              </label>
              <input
                type="text"
                placeholder="e.g. http://192.168.1.10/verify-bank-account or http://kyc-update.com"
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
              />
            </div>
            <button
              type="submit"
              className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 px-4 rounded-md text-xs tracking-wide transition-colors shadow-sm inline-flex items-center justify-center gap-2"
            >
              <Search className="w-3.5 h-3.5" />
              <span>Analyze Link Safety</span>
            </button>
          </form>

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

                <div className="text-right text-xs">
                  <div className="text-[10px] font-semibold uppercase text-slate-500">Risk Score</div>
                  <div className="text-sm font-bold text-slate-900">{result.score} / 25</div>
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
