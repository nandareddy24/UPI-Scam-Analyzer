import { Link, useLocation, useNavigate } from 'react-router-dom';
import { signOut, getCurrentUser } from '../services/authService';
import { 
  Shield, 
  LayoutDashboard, 
  Camera, 
  CreditCard, 
  LinkIcon, 
  MessageSquare, 
  AlertTriangle, 
  Clock, 
  Lock, 
  LogOut,
  FileText
} from './Icons';

export default function Sidebar() {
  const location = useLocation();
  const navigate = useNavigate();
  const currentUser = getCurrentUser();
  const userEmail = currentUser?.email || '';
  const isAdmin = userEmail === 'nandakumarreddy63@gmail.com';
  const path = location.pathname;

  async function handleLogout() {
    await signOut();
    navigate('/login');
  }

  const navItems = [
    { label: 'Dashboard', path: '/', icon: <LayoutDashboard className="w-4 h-4" /> },
    { label: 'UPI VPA Checker', path: '/upi', icon: <CreditCard className="w-4 h-4" /> },
    { label: 'Phishing URL Scanner', path: '/url', icon: <LinkIcon className="w-4 h-4" /> },
    { label: 'SMS & Message Lures', path: '/message', icon: <MessageSquare className="w-4 h-4" /> },
    { label: 'OCR & QR Inspector', path: '/ocr_qr', icon: <Camera className="w-4 h-4" /> },
    { label: 'Report Fraud Entity', path: '/report', icon: <AlertTriangle className="w-4 h-4" /> },
    { label: 'Audit History', path: '/history', icon: <Clock className="w-4 h-4" /> },
  ];

  if (isAdmin) {
    navItems.push({
      label: 'Security Console',
      path: '/admin',
      icon: <Lock className="w-4 h-4 text-amber-600" />
    });
  }

  return (
    <aside className="w-full md:w-64 bg-white border-b md:border-b-0 md:border-r border-slate-200 p-5 flex flex-col justify-between flex-shrink-0 h-full overflow-y-auto">
      <div>
        {/* Brand Header */}
        <Link to="/" className="flex items-center gap-2.5 mb-7 px-1 text-slate-900 hover:text-emerald-800 transition-colors">
          <div className="w-9 h-9 rounded-lg bg-slate-900 text-emerald-400 flex items-center justify-center flex-shrink-0">
            <Shield className="w-5 h-5" />
          </div>
          <div>
            <span className="text-sm font-extrabold tracking-tight block text-slate-900 leading-none">
              Scam Analyzer
            </span>
            <span className="text-[10px] text-slate-500 font-medium tracking-wide">
              Payment Fraud Defense
            </span>
          </div>
        </Link>

        {/* Menu Navigation */}
        <div className="space-y-4">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2 px-2.5">
              ANALYSIS MODULES
            </p>
            <nav className="space-y-1">
              {navItems.map((item) => {
                const active = path === item.path;
                return (
                  <Link
                    key={item.path}
                    to={item.path}
                    className={`flex items-center gap-3 px-3 py-2 rounded-md text-xs transition-colors ${
                      active
                        ? 'bg-slate-900 text-white font-bold shadow-sm'
                        : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100 font-medium'
                    }`}
                  >
                    <span className={active ? 'text-emerald-400' : 'text-slate-500'}>
                      {item.icon}
                    </span>
                    <span>{item.label}</span>
                  </Link>
                );
              })}
            </nav>
          </div>
        </div>
      </div>

      <div className="pt-4 border-t border-slate-200 space-y-3">
        {/* Legal Links */}
        <div className="px-2.5 flex items-center justify-between text-[11px] text-slate-500">
          <Link to="/privacy" className="hover:text-emerald-700 transition-colors">Privacy Policy</Link>
          <span>&bull;</span>
          <Link to="/terms" className="hover:text-emerald-700 transition-colors">Terms</Link>
        </div>

        {/* Logout Link */}
        <button
          onClick={handleLogout}
          className="w-full text-slate-600 hover:text-red-700 hover:bg-red-50 flex items-center gap-2.5 px-3 py-2 rounded-md text-xs font-semibold transition-colors"
        >
          <LogOut className="w-4 h-4 text-slate-400" />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
}
