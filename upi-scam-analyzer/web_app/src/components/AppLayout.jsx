import Sidebar from './Sidebar';
import Footer from './Footer';
import { getCurrentUser } from '../services/authService';
import { Search, Shield, PhoneCall } from './Icons';

export default function AppLayout({ children }) {
  const currentUser = getCurrentUser();
  const userEmail = currentUser?.email || 'user@example.com';
  const initial = userEmail[0]?.toUpperCase() || 'U';

  return (
    <div className="min-h-screen flex flex-col md:flex-row bg-slate-50 font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Left Sidebar */}
      <Sidebar />

      {/* Main Content Area */}
      <main className="flex-1 bg-slate-50 flex flex-col min-h-screen overflow-y-auto">
        {/* Top Header Bar */}
        <div className="bg-white border-b border-slate-200 px-6 py-3.5 flex flex-col sm:flex-row items-center justify-between gap-3 sticky top-0 z-20">
          <div className="flex items-center gap-3 w-full sm:w-auto">
            <div className="relative w-full sm:w-80">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                <Search className="w-3.5 h-3.5" />
              </div>
              <input
                type="text"
                placeholder="Search tools, rules, handles..."
                className="w-full pl-8 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-md text-xs font-medium focus:outline-none focus:border-emerald-700 text-slate-700"
              />
            </div>
          </div>

          <div className="flex items-center gap-4 w-full sm:w-auto justify-between sm:justify-end">
            {/* Helpline indicator */}
            <div className="hidden lg:flex items-center gap-1.5 text-xs text-slate-600 bg-slate-50 border border-slate-200 px-2.5 py-1 rounded-md">
              <PhoneCall className="w-3.5 h-3.5 text-emerald-700" />
              <span className="font-semibold text-slate-800">Helpline: 1930</span>
            </div>

            {/* User Profile Pill */}
            <div className="flex items-center gap-2.5 bg-slate-50 border border-slate-200 px-2.5 py-1 rounded-md">
              <div className="w-6 h-6 rounded bg-slate-900 text-emerald-400 flex items-center justify-center font-bold text-[11px] uppercase">
                {initial}
              </div>
              <div className="text-left">
                <p className="text-xs font-bold text-slate-800 leading-tight max-w-[150px] truncate">{userEmail}</p>
                <p className="text-[10px] text-emerald-700 font-medium">Verified Session</p>
              </div>
            </div>
          </div>
        </div>

        {/* Dynamic Page Content */}
        <div className="flex-1 p-6 md:p-8 max-w-6xl w-full mx-auto">
          {children}
        </div>

        {/* Consistent Footer */}
        <Footer />
      </main>
    </div>
  );
}
