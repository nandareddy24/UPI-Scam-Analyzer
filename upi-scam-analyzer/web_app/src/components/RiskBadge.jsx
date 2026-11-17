import { CheckCircle2, AlertTriangle, ShieldAlert } from './Icons';

export default function RiskBadge({ level, score }) {
  const isHigh = level === 'high' || level === 'danger';
  const isMed = level === 'medium' || level === 'warning';

  if (isHigh) {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-red-100 text-red-800 border border-red-200 text-xs font-bold uppercase tracking-wider">
        <ShieldAlert className="w-3.5 h-3.5 text-red-600" />
        <span>HIGH RISK &bull; {score}/100</span>
      </span>
    );
  }

  if (isMed) {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-amber-100 text-amber-800 border border-amber-200 text-xs font-bold uppercase tracking-wider">
        <AlertTriangle className="w-3.5 h-3.5 text-amber-600" />
        <span>MEDIUM RISK &bull; {score}/100</span>
      </span>
    );
  }

  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded bg-emerald-100 text-emerald-800 border border-emerald-200 text-xs font-bold uppercase tracking-wider">
      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
      <span>LOW RISK &bull; {score}/100</span>
    </span>
  );
}
