import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { getCurrentUser } from '../services/authService';

export default function Admin() {
  const currentUser = getCurrentUser();
  const userEmail = currentUser?.email || 'nandakumarreddy63@gmail.com';
  const isAdmin = userEmail === 'nandakumarreddy63@gmail.com';

  const [reports, setReports] = useState([
    {
      id: 1,
      type: 'UPI',
      target: 'refund-fake-helpdesk@ybl',
      reason: 'Claimed to refund Google Pay transaction of ₹4,999, asked to accept UPI request.',
      proof: '[IMAGE_SCREENSHOT]: https://via.placeholder.com/150 [TEXT_EVIDENCE]: Send ₹4999 to claim refund.',
      status: 'Pending',
      date: '10 mins ago',
    },
    {
      id: 2,
      type: 'URL',
      target: 'http://192.168.1.55/update-kyc-bank',
      reason: 'SMS link claiming SBI account will be blocked if KYC not updated in 2 hours.',
      proof: '[TEXT_EVIDENCE]: SMS: SBI Urgent Alert - Click http://192.168.1.55/update-kyc-bank immediately.',
      status: 'Pending',
      date: '1 hour ago',
    },
    {
      id: 3,
      type: 'SMS',
      target: '+919876543210',
      reason: 'Lottery scam message offering ₹25 Lakhs cash prize via KBC WhatsApp.',
      proof: '[TEXT_EVIDENCE]: Dear friend, your mobile number won ₹25 Lakhs in KBC Lucky Draw.',
      status: 'Pending',
      date: '3 hours ago',
    },
  ]);

  const [blacklists, setBlacklists] = useState([
    { target: 'lottery-winner-kbc@ybl', type: 'UPI', addedBy: 'nandakumarreddy63@gmail.com', date: 'Yesterday' },
    { target: 'http://verify-bank-account-gpay.com', type: 'URL', addedBy: 'nandakumarreddy63@gmail.com', date: '2 days ago' },
  ]);

  const [newBlacklistTarget, setNewBlacklistTarget] = useState('');
  const [newBlacklistType, setNewBlacklistType] = useState('UPI');

  function handleApprove(id) {
    setReports((prev) =>
      prev.map((r) => {
        if (r.id === id) {
          setBlacklists((bl) => [
            ...bl,
            { target: r.target, type: r.type, addedBy: userEmail, date: 'Just now' },
          ]);
          return { ...r, status: 'Approved' };
        }
        return r;
      })
    );
  }

  function handleReject(id) {
    setReports((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: 'Rejected' } : r))
    );
  }

  function handleAddBlacklist(e) {
    e.preventDefault();
    if (!newBlacklistTarget.trim()) return;
    setBlacklists((prev) => [
      ...prev,
      { target: newBlacklistTarget.trim(), type: newBlacklistType, addedBy: userEmail, date: 'Just now' },
    ]);
    setNewBlacklistTarget('');
  }

  return (
    <AppLayout>
      <div className="space-y-6">
        {/* Admin Header Banner */}
        <div className="bg-gradient-to-r from-slate-900 to-slate-800 text-white p-6 rounded-2xl flex items-center justify-between shadow-lg border border-slate-700/50">
          <div>
            <div className="flex items-center gap-2.5 mb-1.5">
              <span className="bg-emerald-700 text-white text-[10px] font-black uppercase px-2.5 py-0.5 rounded-md tracking-wider">
                ADMIN PANEL
              </span>
              <span className="text-xs text-slate-300 font-medium">{userEmail}</span>
            </div>
            <h2 className="text-2xl font-extrabold tracking-tight">System Moderation & Security Console</h2>
          </div>
          <div className="text-4xl">🛡️</div>
        </div>

        {!isAdmin && (
          <div className="bg-red-50 border border-red-200 text-red-800 p-4 rounded-xl text-xs font-semibold">
            ⚠️ Note: Admin moderation privileges are active for <b>nandakumarreddy63@gmail.com</b>. You are viewing admin preview mode.
          </div>
        )}

        {/* Stats Row */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-11 h-11 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center text-xl font-bold">
              📊
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">1,420</div>
              <div className="text-xs text-slate-500 font-semibold">Total System Scans</div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-11 h-11 rounded-xl bg-red-100 text-red-600 flex items-center justify-center text-xl font-bold">
              🚨
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">184</div>
              <div className="text-xs text-slate-500 font-semibold">Flagged Fraud Targets</div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-11 h-11 rounded-xl bg-amber-100 text-amber-600 flex items-center justify-center text-xl font-bold">
              ⚖️
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">
                {reports.filter((r) => r.status === 'Pending').length}
              </div>
              <div className="text-xs text-slate-500 font-semibold">Pending Review Queue</div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
            <div className="w-11 h-11 rounded-xl bg-sky-100 text-sky-600 flex items-center justify-center text-xl font-bold">
              🎯
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900">99.4%</div>
              <div className="text-xs text-slate-500 font-semibold">Model Accuracy Rate</div>
            </div>
          </div>
        </div>

        {/* Community Reports Moderation Queue */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
          <div className="mb-4">
            <h3 className="text-lg font-extrabold text-slate-900">Community Scam Reports Queue</h3>
            <p className="text-slate-500 text-xs mt-0.5">
              Review user-submitted fraud reports. Approving a report automatically blacklists the entity across the platform.
            </p>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50 text-slate-500 font-extrabold uppercase text-[10px] tracking-wider border-b border-slate-200">
                  <th className="p-3">Type</th>
                  <th className="p-3">Reported Target</th>
                  <th className="p-3">User Description</th>
                  <th className="p-3">Proof Evidence</th>
                  <th className="p-3 text-center">Status</th>
                  <th className="p-3 text-right">Moderation Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {reports.map((rep) => (
                  <tr key={rep.id}>
                    <td className="p-3">
                      <span className="bg-emerald-100 text-emerald-800 text-[10px] font-extrabold px-2 py-0.5 rounded-full">
                        {rep.type}
                      </span>
                    </td>
                    <td className="p-3 font-bold text-slate-900">{rep.target}</td>
                    <td className="p-3 text-slate-600 max-w-xs">{rep.reason}</td>
                    <td className="p-3 text-slate-500 text-[11px] font-mono">{rep.proof}</td>
                    <td className="p-3 text-center">
                      <span className={`text-[10px] font-extrabold px-2.5 py-0.5 rounded-full ${
                        rep.status === 'Approved' ? 'bg-emerald-100 text-emerald-800' :
                        rep.status === 'Rejected' ? 'bg-red-100 text-red-800' :
                        'bg-amber-100 text-amber-800'
                      }`}>
                        {rep.status}
                      </span>
                    </td>
                    <td className="p-3 text-right">
                      {rep.status === 'Pending' ? (
                        <div className="flex gap-2 justify-end">
                          <button
                            onClick={() => handleApprove(rep.id)}
                            className="bg-[#047857] hover:bg-[#065f46] text-white px-3 py-1.5 rounded-lg text-[11px] font-bold transition shadow-sm"
                          >
                            ✓ Approve & Blacklist
                          </button>
                          <button
                            onClick={() => handleReject(rep.id)}
                            className="bg-slate-200 hover:bg-slate-300 text-slate-700 px-3 py-1.5 rounded-lg text-[11px] font-bold transition"
                          >
                            ✕ Reject
                          </button>
                        </div>
                      ) : (
                        <span className="text-slate-400 font-medium text-[11px]">Moderated</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Add To Blacklist Section */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
          <h3 className="text-lg font-extrabold text-slate-900 mb-1">🚫 Add Entity to Blacklist Database</h3>
          <p className="text-slate-500 text-xs mb-4">
            Manually flag & blacklist scam UPI handles, malicious links, or phone numbers system-wide.
          </p>

          <form onSubmit={handleAddBlacklist} className="flex gap-3 flex-wrap">
            <select
              value={newBlacklistType}
              onChange={(e) => setNewBlacklistType(e.target.value)}
              className="px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-800 focus:outline-none focus:border-emerald-700"
            >
              <option value="UPI">UPI ID</option>
              <option value="URL">Phishing URL</option>
              <option value="SMS">SMS / Phone</option>
            </select>

            <input
              type="text"
              placeholder="e.g. scammer-vpa@ybl or http://phishing-site.com"
              value={newBlacklistTarget}
              onChange={(e) => setNewBlacklistTarget(e.target.value)}
              className="flex-1 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-700"
            />

            <button
              type="submit"
              className="bg-[#14532d] hover:bg-[#166534] text-white px-6 py-2.5 rounded-full text-xs font-bold transition shadow"
            >
              Add to Blacklist
            </button>
          </form>
        </div>

        {/* Active Blacklisted Database Table */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
          <h3 className="text-lg font-extrabold text-slate-900 mb-4">📋 Active Blacklisted Database</h3>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50 text-slate-500 font-extrabold uppercase text-[10px] tracking-wider border-b border-slate-200">
                  <th className="p-3">Type</th>
                  <th className="p-3">Blacklisted Target</th>
                  <th className="p-3">Added By</th>
                  <th className="p-3 text-right">Date Added</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {blacklists.map((b, idx) => (
                  <tr key={idx}>
                    <td className="p-3">
                      <span className="bg-red-100 text-red-800 text-[10px] font-extrabold px-2 py-0.5 rounded-full">
                        {b.type}
                      </span>
                    </td>
                    <td className="p-3 font-bold text-slate-900 font-mono">{b.target}</td>
                    <td className="p-3 text-slate-600">{b.addedBy}</td>
                    <td className="p-3 text-right text-slate-400 font-medium">{b.date}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
