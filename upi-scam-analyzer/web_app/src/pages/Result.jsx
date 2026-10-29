import { useLocation, useNavigate } from 'react-router-dom';
import RiskBadge from '../components/RiskBadge';

export default function Result() {
  const location = useLocation();
  const navigate = useNavigate();
  const result = location.state?.result;

  if (!result) {
    navigate('/');
    return null;
  }

  return (
    <div className="page">
      <a className="back-link" onClick={() => navigate(-1)}>← Back</a>
      <h2 className="title" style={{ textAlign: 'left' }}>Scan Result</h2>

      <div className="card">
        <p style={{ fontWeight: 600, wordBreak: 'break-word' }}>{result.input}</p>
        <RiskBadge level={result.riskLevel} score={result.score} />
      </div>

      <h3 style={{ marginTop: 24 }}>Why we flagged this</h3>
      <ul className="reason-list">
        {result.reasons.map((r, i) => (
          <li key={i}>{r}</li>
        ))}
      </ul>

      {result.riskLevel !== 'low' && (
        <div className="warning-box">
          Never share OTPs, or send money to verify your identity. Legitimate banks and
          companies never ask for this.
        </div>
      )}
    </div>
  );
}
