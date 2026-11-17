import AppLayout from '../components/AppLayout';
import { Clock, ShieldAlert, ShieldCheck, AlertTriangle } from '../components/Icons';

export default function History() {
  const mockScans = [
    { type: 'UPI', target: 'scam-refund@ybl', result: 'High Risk Scam Handle', badge: 'danger', score: '22/25', date: 'Just now' },
    { type: 'URL', target: 'http://192.168.1.1/login', result: 'Phishing Domain', badge: 'danger', score: '18/25', date: '10 mins ago' },
    { type: 'SMS', target: 'Dear customer your account will be blocked...', result: 'Suspicious Warning', badge: 'warning', score: '9/25', date: '1 hour ago' },
    { type: 'UPI', target: 'nandareddy@oksbi', result: 'Verified Standard Handle', badge: 'safe', score: '0/25', date: 'Yesterday' },
  ];

  return (
    <AppLayout>
      <div className="space-y-6 max-w-4xl">
        <div className="border-b border-slate-200 pb-4">
          <div className="flex items-center gap-2.5 mb-1">
            <div className="w-8 h-8 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center">
              <Clock className="w-4 h-4" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Personal Scan Audit History</h1>
          </div>
          <p className="text-xs text-slate-500">
            Review past inspections, threat scores, and flagged payloads across your account session.
          </p>
        </div>

        <div className="bg-white rounded-lg border border-slate-200 shadow-sm divide-y divide-slate-100">
          {mockScans.map((item, idx) => (
            <div
              key={idx}
              className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors gap-3"
            >
              <div className="flex items-center gap-3">
                <div
                  className={`w-9 h-9 rounded-md flex items-center justify-center font-bold text-xs ${
                    item.badge === 'danger'
                      ? 'bg-red-50 text-red-700 border border-red-200'
                      : item.badge === 'warning'
                      ? 'bg-amber-50 text-amber-700 border border-amber-200'
                      : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                  }`}
                >
                  {item.type}
                </div>

                <div>
                  <h4 className="font-semibold text-slate-900 text-xs font-mono">{item.target}</h4>
                  <p className="text-[11px] text-slate-500 mt-0.5">{item.result} &bull; {item.date}</p>
                </div>
              </div>

              <div className="text-right">
                <span
                  className={`text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider ${
                    item.badge === 'danger'
                      ? 'bg-red-100 text-red-800'
                      : item.badge === 'warning'
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-emerald-100 text-emerald-800'
                  }`}
                >
                  {item.badge}
                </span>
                <div className="text-xs font-semibold text-slate-600 mt-1 font-mono">
                  Score: {item.score}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AppLayout>
  );
}
