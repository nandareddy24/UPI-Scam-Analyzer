import { Link } from 'react-router-dom';

export default function Landing() {
  return (
    <div className="relative min-h-screen bg-[linear-gradient(135deg,#0f172a,#1d4ed8,#38bdf8)] text-white overflow-hidden flex flex-col justify-center items-center text-center px-6">
      {/* Background Glow Circles */}
      <div className="absolute rounded-full filter blur-[90px] opacity-30 bg-blue-400 w-96 h-96 top-0 left-0"></div>
      <div className="absolute rounded-full filter blur-[90px] opacity-30 bg-cyan-300 w-96 h-96 bottom-0 right-0"></div>

      {/* Main Container */}
      <div className="h-screen flex flex-col justify-center items-center text-center px-6 relative z-10 max-w-5xl">
        {/* Logo */}
        <div className="text-7xl mb-6 floating animate-bounce">
          🚀
        </div>

        {/* Title */}
        <h1 className="text-5xl md:text-7xl font-extrabold mb-6 tracking-wide text-white">
          UPI Scam Analyzer
        </h1>

        {/* Description */}
        <p className="text-lg md:text-2xl text-blue-100 mb-10 max-w-3xl leading-relaxed font-medium">
          Detect fraudulent UPI IDs, phishing URLs, and scam SMS messages instantly using AI-powered smart analysis and real-time protection.
        </p>

        {/* Buttons */}
        <div className="flex gap-6 mb-16">
          <Link
            to="/login"
            className="bg-white text-blue-900 px-8 py-4 rounded-2xl font-bold text-lg shadow-xl hover:scale-105 hover:bg-gray-200 transition duration-300"
          >
            🔐 Login
          </Link>
          <Link
            to="/signup"
            className="bg-gradient-to-r from-emerald-500 to-emerald-700 text-white px-8 py-4 rounded-2xl font-bold text-lg shadow-xl hover:scale-105 transition duration-300"
          >
            📝 Register
          </Link>
        </div>

        {/* Feature Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-left w-full">
          <div className="bg-white/10 backdrop-blur-md border border-white/20 p-6 rounded-2xl transition duration-300 hover:-translate-y-2 hover:shadow-2xl">
            <div className="text-4xl mb-3">💳</div>
            <h3 className="text-xl font-extrabold text-white mb-2">UPI Detection</h3>
            <p className="text-blue-100 text-sm leading-relaxed">
              Analyze suspicious UPI IDs and identify fake payment handles instantly before sending funds.
            </p>
          </div>

          <div className="bg-white/10 backdrop-blur-md border border-white/20 p-6 rounded-2xl transition duration-300 hover:-translate-y-2 hover:shadow-2xl">
            <div className="text-4xl mb-3">🔗</div>
            <h3 className="text-xl font-extrabold text-white mb-2">URL Scanner</h3>
            <p className="text-blue-100 text-sm leading-relaxed">
              Detect phishing links, credential harvesting sites, and dangerous redirects in real-time.
            </p>
          </div>

          <div className="bg-white/10 backdrop-blur-md border border-white/20 p-6 rounded-2xl transition duration-300 hover:-translate-y-2 hover:shadow-2xl">
            <div className="text-4xl mb-3">💬</div>
            <h3 className="text-xl font-extrabold text-white mb-2">SMS Analyzer</h3>
            <p className="text-blue-100 text-sm leading-relaxed">
              Identify scam SMS & WhatsApp messages using AI-driven pattern detection and threat scoring.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
