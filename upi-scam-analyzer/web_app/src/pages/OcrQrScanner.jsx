import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeOcrQr } from '../services/analyzer';

export default function OcrQrScanner() {
  const [ocrFileName, setOcrFileName] = useState('');
  const [qrFileName, setQrFileName] = useState('');
  const [qrPayload, setQrPayload] = useState('');
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  function handleOcrScan(e) {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      const res = analyzeOcrQr(ocrFileName || 'payment_screenshot.png', 'Suspicious UPI VPA extracted: refund-care@ybl');
      setResult(res);
      setLoading(false);
    }, 400);
  }

  function handleQrScan(e) {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      const payload = qrPayload || 'upi://pay?pa=scamuser@ybl&pn=FakeRefundCare&am=4999';
      const res = analyzeOcrQr(qrFileName || 'qr_image.png', payload);
      setResult(res);
      setLoading(false);
    }, 400);
  }

  return (
    <AppLayout>
      <div className="space-y-6">
        {/* Page Title Header matching Image 2 */}
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">OCR Screenshot & QR Scanner</h1>
          <p className="text-slate-500 text-xs mt-1 leading-relaxed">
            Upload payment screenshots, WhatsApp chats, or QR images to extract and verify threat data automatically.
          </p>
        </div>

        {/* 2-Card Grid matching Image 2 */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* OCR Screenshot Scanner Card */}
          <div className="bg-white border border-slate-200 shadow-sm rounded-[20px] p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                  </svg>
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-slate-900">OCR Screenshot Scanner</h3>
                  <p className="text-xs text-slate-400 font-medium">Extracts UPI VPAs & URLs from images</p>
                </div>
              </div>

              <form onSubmit={handleOcrScan} className="space-y-4">
                <div className="border-2 border-dashed border-slate-200 hover:border-emerald-700 rounded-2xl p-6 text-center bg-slate-50/50 cursor-pointer transition-colors">
                  <input
                    type="file"
                    id="ocrFile"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => setOcrFileName(e.target.files[0]?.name || '')}
                  />
                  <label htmlFor="ocrFile" className="cursor-pointer">
                    <svg className="w-8 h-8 text-slate-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
                    </svg>
                    <span className="text-xs font-semibold text-slate-600 block">
                      {ocrFileName ? `Selected: ${ocrFileName}` : 'Click to upload screenshot (.png, .jpg, .webp)'}
                    </span>
                  </label>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 rounded-xl text-xs transition-colors shadow"
                >
                  {loading ? 'Running OCR Scan...' : 'Scan Screenshot'}
                </button>
              </form>
            </div>
          </div>

          {/* QR Fraud Detector Card */}
          <div className="bg-white border border-slate-200 shadow-sm rounded-[20px] p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
                  </svg>
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-slate-900">QR Fraud Detector</h3>
                  <p className="text-xs text-slate-400 font-medium">Decodes UPI QR codes & pay payloads</p>
                </div>
              </div>

              <form onSubmit={handleQrScan} className="space-y-4">
                <div className="border-2 border-dashed border-slate-200 hover:border-emerald-700 rounded-2xl p-6 text-center bg-slate-50/50 cursor-pointer transition-colors">
                  <input
                    type="file"
                    id="qrFile"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => setQrFileName(e.target.files[0]?.name || '')}
                  />
                  <label htmlFor="qrFile" className="cursor-pointer">
                    <svg className="w-8 h-8 text-slate-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    <span className="text-xs font-semibold text-slate-600 block">
                      {qrFileName ? `Selected: ${qrFileName}` : 'Click to upload QR Image'}
                    </span>
                  </label>
                </div>

                <input
                  type="text"
                  placeholder="or paste payload: upi://pay?pa=scamuser@ybl..."
                  value={qrPayload}
                  onChange={(e) => setQrPayload(e.target.value)}
                  className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-mono focus:outline-none focus:border-emerald-700"
                />

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#14532d] hover:bg-[#166534] text-white font-bold py-3 rounded-xl text-xs transition-colors shadow"
                >
                  {loading ? 'Decoding QR...' : 'Decode & Scan QR'}
                </button>
              </form>
            </div>
          </div>
        </div>

        {/* Scan Result Output */}
        {result && (
          <div className="bg-white p-6 rounded-[20px] border border-slate-200 shadow-sm space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between pb-4 border-b border-slate-100 gap-2">
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">Classification Result</span>
                <h3 className="text-xl font-extrabold text-slate-900">{result.result} ({result.status})</h3>
              </div>
              <div className="sm:text-right">
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">Threat Score</span>
                <div className="text-2xl font-extrabold font-mono text-slate-900">
                  {result.score} <span className="text-xs font-normal text-slate-400">/ 25</span>
                </div>
              </div>
            </div>

            <div>
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-1">Extraction Findings</h4>
              <p className="text-xs font-mono bg-slate-50 p-3 rounded-xl border border-slate-200 text-slate-700 leading-relaxed">
                {result.findings}
              </p>
            </div>

            <div className="p-3 bg-emerald-50/70 rounded-xl border border-emerald-200 text-xs font-semibold text-emerald-900 flex items-start gap-2">
              <span className="text-base">💡</span>
              <span>{result.advice}</span>
            </div>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
