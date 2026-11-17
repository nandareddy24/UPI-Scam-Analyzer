import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { getCurrentUser } from '../services/authService';
import { Lock, Shield, CheckCircle2, Ban, AlertTriangle, User } from '../components/Icons';

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
      proof: 'Screenshot evidence: Ask to approve ₹4999 collect request.',
      status: 'Pending',
      date: '10 mins ago',
    },
    {
      id: 2,
      type: 'URL',
      target: 'http://192.168.1.55/update-kyc-bank',
      reason: 'SMS link claiming SBI account will be blocked if KYC not updated in 2 hours.',
      proof: 'SMS header VK-SBIINB: Click http://192.168.1.55/update-kyc-bank.',
      status: 'Pending',
      date: '1 hour ago',
    },
    {
      id: 3,
      type: 'SMS',
      target: '+919876543210',
      reason: 'Lottery scam message offering ₹25 Lakhs cash prize via KBC WhatsApp.',
      proof: 'Message text: Dear customer, your number won ₹25 Lakhs in Lucky Draw.',
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

  const pendingCount = reports.filter((r) => r.status === 'Pending').length;

  return (
    <AppLayout>
      <div className="space-y-6">
        {/* Admin Header */}
        <div className="bg-slate-900 text-white p-5 rounded-lg border border-slate-800 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="bg-emerald-800 text-emerald-200 text-[10px] font-bold uppercase px-2 py-0.5 rounded tracking-wider">
                Console
              </span>
              <span className="text-xs text-slate-400 font-mono">{userEmail}</span>
            </div>
            <h1 className="text-xl font-bold tracking-tight">Security Moderation Console</h1>
            <p className="text-xs text-slate-400 mt-0.5">
              Review flagged payment entities, investigate community reports, and manage system-wide blacklists.
            </p>
          </div>
          <div className="w-10 h-10 rounded-md bg-slate-800 border border-slate-700 text-emerald-400 flex items-center justify-center flex-shrink-0">
            <Lock className="w-5 h-5" />
          </div>
        </div>

        {!isAdmin && (
          <div className="bg-amber-50 border border-amber-200 text-amber-900 p-3.5 rounded-md text-xs font-medium flex items-center gap-2">
            <AlertTriangle className="w-4 h-4 text-amber-600 flex-shrink-0" />
            <span>Administrator preview active for demonstration. Production actions require root permissions.</span>
          </div>
        )}

        {/* Operational Queue Metrics (Real, Authentic counts) */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm">
            <div className="text-xs font-semibold text-slate-500 uppercase tracking-wide">Pending Queue</div>
            <div className="text-2xl font-bold text-slate-900 mt-1">{pendingCount}</div>
            <div className="text-[11px] text-slate-400 mt-0.5">Awaiting moderator verdict</div>
          </div>

          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm">
            <div className="text-xs font-semibold text-slate-500 uppercase tracking-wide">Total Submissions</div>
            <div className="text-2xl font-bold text-slate-900 mt-1">{reports.length}</div>
            <div className="text-[11px] text-slate-400 mt-0.5">Logged in current session</div>
          </div>

          <div className="bg-white p-4 rounded-lg border border-slate-200 shadow-sm">
            <div className="text-xs font-semibold text-slate-500 uppercase tracking-wide">Blacklisted Entities</div>
            <div className="text-2xl font-bold text-slate-900 mt-1">{blacklists.length}</div>
            <div className="text-[11px] text-slate-400 mt-0.5">Active heuristic rules</div>
          </div>
        </div>

        {/* Community Reports Moderation Queue */}
        <div className="bg-white p-6 rounded-lg border border-slate-200 shadow-sm">
          <div className="border-b border-slate-200 pb-3 mb-4">
            <h3 className="text-base font-bold text-slate-900">User Report Moderation Queue</h3>
            <p className="text-slate-500 text-xs mt-0.5">
              Approving a submitted threat adds the identifier directly to the heuristic blacklist database.
            </p>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50 text-slate-500 font-semibold uppercase text-[10px] tracking-wider border-b border-slate-200">
                  <th className="p-3">Type</th>
                  <th className="p-3">Target</th>
                  <th className="p-3">Incident Description</th>
                  <th className="p-3">Proof Evidence</th>
                  <th className="p-3 text-center">Status</th>
                  <th className="p-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {reports.map((rep) => (
                  <tr key={rep.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="bg-slate-100 text-slate-800 text-[10px] font-bold px-2 py-0.5 rounded border border-slate-200">
                        {rep.type}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-900 font-mono">{rep.target}</td>
                    <td className="p-3 text-slate-600 max-w-xs">{rep.reason}</td>
                    <td className="p-3 text-slate-500 text-[11px] font-mono">{rep.proof}</td>
                    <td className="p-3 text-center">
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider ${
                        rep.status === 'Approved' ? 'bg-emerald-100 text-emerald-800' :
                        rep.status === 'Rejected' ? 'bg-red-100 text-red-800' :
                        'bg-amber-100 text-amber-800'
                      }`}>
                        {rep.status}
                      </span>
                    </td>
                    <td className="p-3 text-right">
                      {rep.status === 'Pending' ? (
                        <div className="flex gap-1.5 justify-end">
                          <button
                            onClick={() => handleApprove(rep.id)}
                            className="bg-[#047857] hover:bg-[#065f46] text-white px-2.5 py-1 rounded text-xs font-semibold transition-colors"
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => handleReject(rep.id)}
                            className="bg-slate-200 hover:bg-slate-300 text-slate-700 px-2.5 py-1 rounded text-xs font-semibold transition-colors"
                          >
                            Reject
                          </button>
                        </div>
                      ) : (
                        <span className="text-slate-400 text-xs">Reviewed</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Add To Blacklist Section */}
        <div className="bg-white p-6 rounded-lg border border-slate-200 shadow-sm">
          <div className="border-b border-slate-200 pb-3 mb-4">
            <h3 className="text-base font-bold text-slate-900">Direct Blacklist Entry</h3>
            <p className="text-slate-500 text-xs mt-0.5">
              Add known fraudulent UPI handles or phishing links directly into the system database.
            </p>
          </div>

          <form onSubmit={handleAddBlacklist} className="flex gap-2.5 flex-col sm:flex-row">
            <select
              value={newBlacklistType}
              onChange={(e) => setNewBlacklistType(e.target.value)}
              className="px-3 py-2 bg-white border border-slate-300 rounded-md text-xs font-semibold text-slate-800 focus:outline-none focus:border-emerald-700"
            >
              <option value="UPI">UPI VPA</option>
              <option value="URL">Phishing URL</option>
              <option value="SMS">SMS / Phone</option>
            </select>

            <input
              type="text"
              placeholder="e.g. scammer-vpa@ybl or http://phishing-site.com"
              value={newBlacklistTarget}
              onChange={(e) => setNewBlacklistTarget(e.target.value)}
              className="flex-1 px-3 py-2 bg-white border border-slate-300 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-900"
            />

            <button
              type="submit"
              className="bg-[#047857] hover:bg-[#065f46] text-white px-4 py-2 rounded-md text-xs font-bold transition-colors shadow-sm whitespace-nowrap"
            >
              Add to Blacklist
            </button>
          </form>
        </div>

        {/* Active Blacklisted Database Table */}
        <div className="bg-white p-6 rounded-lg border border-slate-200 shadow-sm">
          <h3 className="text-base font-bold text-slate-900 mb-3">Active Blacklisted Entities</h3>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50 text-slate-500 font-semibold uppercase text-[10px] tracking-wider border-b border-slate-200">
                  <th className="p-3">Type</th>
                  <th className="p-3">Identifier / Target</th>
                  <th className="p-3">Logged By</th>
                  <th className="p-3 text-right">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {blacklists.map((b, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="bg-red-50 text-red-700 border border-red-200 text-[10px] font-bold px-2 py-0.5 rounded">
                        {b.type}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-900 font-mono">{b.target}</td>
                    <td className="p-3 text-slate-600">{b.addedBy}</td>
                    <td className="p-3 text-right text-slate-500">{b.date}</td>
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
