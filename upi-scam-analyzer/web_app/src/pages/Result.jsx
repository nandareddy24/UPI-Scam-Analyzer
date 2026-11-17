import { useLocation, useNavigate, Link } from 'react-router-dom';
import AppLayout from '../components/AppLayout';
import RiskBadge from '../components/RiskBadge';
import { ArrowLeft, ShieldAlert, ShieldCheck, AlertTriangle, CheckCircle2 } from '../components/Icons';

export default function Result() {
  const location = useLocation();
  const navigate = useNavigate();
  const result = location.state?.result;

  if (!result) {
    navigate('/');
    return null;
  }

  return (
    <AppLayout>
      <div className="space-y-6 max-w-3xl">
        <div className="border-b border-slate-200 pb-4">
          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-600 hover:text-slate-900 mb-3 bg-slate-100 hover:bg-slate-200 px-3 py-1.5 rounded-md transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Return to Scanner</span>
          </button>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Threat Analysis Verdict</h1>
          <p className="text-xs text-slate-500">
            Heuristic classification for inspected payment payload.
          </p>
        </div>

        <div className="bg-white p-6 sm:p-8 rounded-lg border border-slate-200 shadow-sm space-y-6">
          <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-3 border-b border-slate-100 pb-4">
            <div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-1">
                Inspected Payload
              </div>
              <p className="font-mono text-sm font-bold text-slate-900 break-all">{result.input}</p>
            </div>
            <div>
              <RiskBadge level={result.riskLevel} score={result.score} />
            </div>
          </div>

          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700 mb-3">
              Identified Threat Indicators
            </h3>
            <ul className="space-y-2">
              {result.reasons?.map((reason, idx) => (
                <li key={idx} className="flex items-start gap-2.5 text-xs text-slate-700 bg-slate-50 p-3 rounded-md border border-slate-200">
                  <AlertTriangle className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
                  <span className="leading-relaxed font-medium">{reason}</span>
                </li>
              ))}
            </ul>
          </div>

          {result.riskLevel !== 'low' ? (
            <div className="p-4 bg-red-50 border border-red-200 rounded-md text-xs text-red-950 flex items-start gap-3">
              <ShieldAlert className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
              <div className="leading-relaxed">
                <strong className="block text-red-900 font-bold mb-1">Critical Payment Security Rule</strong>
                Never enter your secret UPI PIN or approve a collect request to receive money. Official financial organizations and merchant platforms never demand PIN authorization to disburse refunds or cashbacks.
              </div>
            </div>
          ) : (
            <div className="p-4 bg-emerald-50 border border-emerald-200 rounded-md text-xs text-emerald-950 flex items-start gap-3">
              <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0 mt-0.5" />
              <div className="leading-relaxed">
                <strong className="block text-emerald-900 font-bold mb-1">Standard Safety Practice</strong>
                Always verify the recipient name rendered by the NPCI banking gateway inside your mobile UPI application before concluding payment.
              </div>
            </div>
          )}
        </div>
      </div>
    </AppLayout>
  );
}
