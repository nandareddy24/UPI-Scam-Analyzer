import { useState } from 'react';

export default function FloatingChat() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState([
    { sender: 'ai', text: '👋 Hello! I am your AI Cyber Protection Assistant. Ask me about suspicious UPI IDs, SMS scams, or Helpline 1930 guidance.' }
  ]);
  const [input, setInput] = useState('');

  function handleSend(e) {
    e.preventDefault();
    if (!input.trim()) return;

    const userMsg = input.trim();
    setMessages((prev) => [...prev, { sender: 'user', text: userMsg }]);
    setInput('');

    setTimeout(() => {
      let reply = '';
      const text = userMsg.toLowerCase();
      if (text.includes('1930') || text.includes('helpline') || text.includes('report')) {
        reply = '🚨 **National Cyber Crime Helpline: 1930**. If you lost money in a UPI scam, call 1930 within the golden hour to freeze the fraudulent recipient bank account.';
      } else if (text.includes('upi') || text.includes('@')) {
        reply = '💳 **UPI Safety Tip**: Never enter your UPI PIN to receive money! Entering your PIN always deducts money from your account.';
      } else if (text.includes('link') || text.includes('http') || text.includes('url')) {
        reply = '🔗 **URL Caution**: Avoid links sent via SMS claiming your bank account or KYC is blocked. Official banks never send raw IP links or bit.ly shorteners.';
      } else {
        reply = `🤖 I scanned "${userMsg}". Always verify the beneficiary name on your UPI app screen before entering any PIN. For active fraud, call Helpline 1930.`;
      }
      setMessages((prev) => [...prev, { sender: 'ai', text: reply }]);
    }, 400);
  }

  return (
    <div style={{ position: 'fixed', bottom: 24, right: 24, zIndex: 999 }}>
      {!isOpen && (
        <button
          onClick={() => setIsOpen(true)}
          style={{
            width: 60,
            height: 60,
            borderRadius: '50%',
            background: '#047857',
            color: 'white',
            border: 'none',
            fontSize: 26,
            boxShadow: '0 8px 24px rgba(4, 120, 87, 0.4)',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            transition: 'transform 0.2s ease',
          }}
          title="Ask AI Cyber Assistant"
        >
          💬
        </button>
      )}

      {isOpen && (
        <div style={{
          width: 360,
          maxHeight: 520,
          height: '80vh',
          background: 'white',
          borderRadius: 20,
          boxShadow: '0 12px 36px rgba(0,0,0,0.2)',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          border: '1px solid #e2e8f0',
        }}>
          {/* Header */}
          <div style={{
            background: '#0f172a',
            color: 'white',
            padding: '14px 18px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ background: '#047857', width: 32, height: 32, borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16 }}>🛡️</div>
              <div>
                <div style={{ fontWeight: 800, fontSize: 14 }}>AI Cyber Protection Assistant</div>
                <div style={{ fontSize: 10, color: '#a7f3d0' }}>Online • Helpline 1930</div>
              </div>
            </div>
            <button
              onClick={() => setIsOpen(false)}
              style={{ background: 'none', border: 'none', color: '#94a3b8', fontSize: 18, cursor: 'pointer' }}
            >
              ✕
            </button>
          </div>

          {/* Messages Container */}
          <div style={{ flex: 1, padding: 16, overflowY: 'auto', background: '#f8fafc', display: 'flex', flexDirection: 'column', gap: 12 }}>
            {messages.map((m, idx) => (
              <div
                key={idx}
                style={{
                  alignSelf: m.sender === 'user' ? 'flex-end' : 'flex-start',
                  maxWidth: '85%',
                  background: m.sender === 'user' ? '#047857' : 'white',
                  color: m.sender === 'user' ? 'white' : '#0f172a',
                  padding: '10px 14px',
                  borderRadius: 14,
                  fontSize: 13,
                  border: m.sender === 'user' ? 'none' : '1px solid #e2e8f0',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
                  lineHeight: 1.4,
                }}
              >
                {m.text}
              </div>
            ))}
          </div>

          {/* Input Form */}
          <form onSubmit={handleSend} style={{ padding: 12, borderTop: '1px solid #e2e8f0', display: 'flex', gap: 8, background: 'white' }}>
            <input
              type="text"
              placeholder="Ask AI cyber assistant..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              style={{
                flex: 1,
                padding: '10px 14px',
                border: '1px solid #cbd5e1',
                borderRadius: 10,
                fontSize: 13,
                marginBottom: 0,
              }}
            />
            <button
              type="submit"
              style={{
                background: '#047857',
                color: 'white',
                border: 'none',
                padding: '0 16px',
                borderRadius: 10,
                fontWeight: 700,
                fontSize: 13,
                cursor: 'pointer',
              }}
            >
              Send
            </button>
          </form>
        </div>
      )}
    </div>
  );
}
