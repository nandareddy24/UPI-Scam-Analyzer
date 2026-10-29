export default function RiskBadge({ level, score }) {
  const labels = { low: 'LOW RISK', medium: 'MEDIUM RISK', high: 'HIGH RISK' };
  const icons = { low: '✅', medium: '⚠️', high: '⛔' };

  return (
    <span className={`risk-badge ${level}`}>
      <span>{icons[level]}</span>
      {labels[level]} · {score}/100
    </span>
  );
}
