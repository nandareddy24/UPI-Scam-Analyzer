import Sidebar from './Sidebar';
import { getCurrentUser } from '../services/authService';

export default function AppLayout({ children }) {
  const currentUser = getCurrentUser();
  const userEmail = currentUser?.email || 'user@example.com';
  const initial = userEmail[0]?.toUpperCase() || 'U';

  return (
    <div className="p-2 md:p-4 min-h-screen flex justify-center items-center bg-[#eef1f5] font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Outer Container Frame matching Image 2 */}
      <div className="w-full max-w-[1440px] h-[calc(100vh-2rem)] max-h-[920px] min-h-[600px] bg-white rounded-[28px] shadow-2xl border border-slate-200/80 flex flex-col md:flex-row overflow-hidden">
        {/* Left Sidebar */}
        <Sidebar />

        {/* Main Content Area */}
        <main className="flex-1 bg-[#f8fafc] p-6 md:p-8 overflow-y-auto h-full flex flex-col">
          {/* Top Search & Profile Bar */}
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mb-6 flex-shrink-0">
            <div className="relative w-full sm:w-96">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
              </div>
              <input
                type="text"
                placeholder="Search scanner features..."
                className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-full text-xs font-medium focus:outline-none focus:border-emerald-700 shadow-sm text-slate-700"
              />
            </div>

            {/* User Profile Pill */}
            <div className="flex items-center gap-2.5 bg-white border border-slate-200 p-1.5 pr-4 rounded-full shadow-sm">
              <div className="w-8 h-8 rounded-full bg-emerald-700 text-white flex items-center justify-center font-bold text-xs uppercase">
                {initial}
              </div>
              <div className="text-left">
                <p className="text-xs font-bold text-slate-800 leading-tight max-w-[140px] truncate">{userEmail}</p>
                <p className="text-[10px] text-emerald-700 font-semibold">Active User</p>
              </div>
            </div>
          </div>

          {/* Dynamic Page Content */}
          <div className="flex-1">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
