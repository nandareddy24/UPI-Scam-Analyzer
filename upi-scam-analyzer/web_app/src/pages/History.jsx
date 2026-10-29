import AppLayout from '../components/AppLayout';

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
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">📜 Scan Audit History</h1>
          <p className="text-slate-500 text-xs mt-1">
            Review past inspections, threat scores, and flagged payloads across your account.
          </p>
        </div>

        <div className="bg-white p-6 rounded-[20px] border border-slate-200 shadow-sm space-y-4">
          {mockScans.map((item, idx) => (
            <div
              key={idx}
              className="p-4 rounded-xl border border-slate-100 bg-slate-50/60 flex items-center justify-between hover:bg-slate-50 transition-colors"
            >
              <div className="flex items-center gap-3.5">
                <div
                  className={`w-10 h-10 rounded-xl flex items-center justify-center font-extrabold text-xs ${
                    item.badge === 'danger'
                      ? 'bg-red-100 text-red-700 border border-red-200'
                      : item.badge === 'warning'
                      ? 'bg-amber-100 text-amber-700 border border-amber-200'
                      : 'bg-emerald-100 text-emerald-700 border border-emerald-200'
                  }`}
                >
                  {item.type}
                </div>

                <div>
                  <h4 className="font-bold text-slate-900 text-sm font-mono">{item.target}</h4>
                  <p className="text-xs text-slate-500">{item.result} • {item.date}</p>
                </div>
              </div>

              <div className="text-right">
                <span
                  className={`text-[10px] font-extrabold px-2.5 py-0.5 rounded-full uppercase tracking-wider ${
                    item.badge === 'danger'
                      ? 'bg-red-100 text-red-800'
                      : item.badge === 'warning'
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-emerald-100 text-emerald-800'
                  }`}
                >
                  {item.badge}
                </span>
                <div className="text-xs font-bold text-slate-600 mt-1 font-mono">
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
