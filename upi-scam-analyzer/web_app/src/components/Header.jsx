import { Link, useLocation, useNavigate } from 'react-router-dom';
import { signOut, getCurrentUser } from '../services/authService';

export default function Header() {
  const location = useLocation();
  const navigate = useNavigate();
  const currentUser = getCurrentUser();
  const userEmail = currentUser?.email || '';
  const isAdmin = userEmail === 'nandakumarreddy63@gmail.com';

  async function handleLogout() {
    await signOut();
    navigate('/login');
  }

  const path = location.pathname;

  return (
    <nav className="navbar">
      <Link to="/" className="nav-brand">
        <div className="brand-icon">🛡️</div>
        <div>
          <div className="brand-title">UPI Scam Analyzer</div>
          <div className="brand-subtitle">AI Threat Shield • 1930 Helpline</div>
        </div>
      </Link>

      <div className="nav-links">
        <Link to="/" className={`nav-link ${path === '/' ? 'active' : ''}`}>
          📊 Dashboard
        </Link>
        <Link to="/upi" className={`nav-link ${path === '/upi' ? 'active' : ''}`}>
          💳 UPI Check
        </Link>
        <Link to="/url" className={`nav-link ${path === '/url' ? 'active' : ''}`}>
          🔗 URL Check
        </Link>
        <Link to="/message" className={`nav-link ${path === '/message' ? 'active' : ''}`}>
          💬 SMS Check
        </Link>
        <Link to="/history" className={`nav-link ${path === '/history' ? 'active' : ''}`}>
          📜 History
        </Link>
        <Link to="/report" className={`nav-link ${path === '/report' ? 'active' : ''}`}>
          🚨 Report Scam
        </Link>

        {/* Admin Link for nandakumarreddy63@gmail.com */}
        <Link
          to="/admin"
          className={`nav-link ${path === '/admin' ? 'active' : ''}`}
          style={{
            background: isAdmin ? '#047857' : 'rgba(255,255,255,0.08)',
            border: '1px solid rgba(167, 243, 208, 0.4)',
            color: '#a7f3d0',
            fontWeight: 800,
          }}
        >
          🛡️ Admin Panel
        </Link>

        <button onClick={handleLogout} className="nav-logout">
          Logout
        </button>
      </div>
    </nav>
  );
}
