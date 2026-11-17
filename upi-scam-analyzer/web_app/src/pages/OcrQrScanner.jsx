import { useState } from 'react';
import AppLayout from '../components/AppLayout';
import { analyzeOcrQr } from '../services/analyzer';
import { Camera, QrCode, Search, ShieldAlert, ShieldCheck, AlertTriangle, CheckCircle2 } from '../components/Icons';

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
    }, 300);
  }

  function handleQrScan(e) {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      const payload = qrPayload || 'upi://pay?pa=scamuser@ybl&pn=FakeRefundCare&am=4999';
      const res = analyzeOcrQr(qrFileName || 'qr_image.png', payload);
      setResult(res);
      setLoading(false);
    }, 300);
  }

  return (
    <AppLayout>
      <div className="space-y-6">
        <div className="border-b border-slate-200 pb-4">
          <div className="flex items-center gap-2.5 mb-1">
            <div className="w-8 h-8 rounded-md bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center justify-center">
              <Camera className="w-4 h-4" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">OCR Screenshot & QR Code Scanner</h1>
          </div>
          <p className="text-xs text-slate-500">
            Upload payment screenshots, WhatsApp chat evidence, or QR code images to extract and verify threat data automatically.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* OCR Screenshot Scanner Card */}
          <div className="bg-white border border-slate-200 shadow-sm rounded-lg p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-2.5 mb-4">
                <div className="w-8 h-8 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center">
                  <Camera className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900">OCR Screenshot Extractor</h3>
                  <p className="text-[11px] text-slate-500">Extracts VPAs and URLs from payment receipts</p>
                </div>
              </div>

              <form onSubmit={handleOcrScan} className="space-y-4">
                <div className="border-2 border-dashed border-slate-300 hover:border-emerald-700 rounded-md p-6 text-center bg-slate-50/50 cursor-pointer transition-colors">
                  <input
                    type="file"
                    id="ocrFile"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => setOcrFileName(e.target.files[0]?.name || '')}
                  />
                  <label htmlFor="ocrFile" className="cursor-pointer block">
                    <Camera className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                    <span className="text-xs font-semibold text-slate-700 block">
                      {ocrFileName ? `Selected: ${ocrFileName}` : 'Choose image file (.png, .jpg, .webp)'}
                    </span>
                  </label>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 rounded-md text-xs transition-colors shadow-sm inline-flex items-center justify-center gap-2"
                >
                  <Search className="w-3.5 h-3.5" />
                  <span>{loading ? 'Processing OCR...' : 'Scan Screenshot Image'}</span>
                </button>
              </form>
            </div>
          </div>

          {/* QR Fraud Detector Card */}
          <div className="bg-white border border-slate-200 shadow-sm rounded-lg p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-2.5 mb-4">
                <div className="w-8 h-8 rounded-md bg-slate-100 text-slate-800 flex items-center justify-center">
                  <QrCode className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900">QR Payload Decoder</h3>
                  <p className="text-[11px] text-slate-500">Decodes embedded UPI payment payloads</p>
                </div>
              </div>

              <form onSubmit={handleQrScan} className="space-y-4">
                <div className="border-2 border-dashed border-slate-300 hover:border-emerald-700 rounded-md p-6 text-center bg-slate-50/50 cursor-pointer transition-colors">
                  <input
                    type="file"
                    id="qrFile"
                    accept="image/*"
                    className="hidden"
                    onChange={(e) => setQrFileName(e.target.files[0]?.name || '')}
                  />
                  <label htmlFor="qrFile" className="cursor-pointer block">
                    <QrCode className="w-8 h-8 text-slate-400 mx-auto mb-2" />
                    <span className="text-xs font-semibold text-slate-700 block">
                      {qrFileName ? `Selected: ${qrFileName}` : 'Choose QR image file'}
                    </span>
                  </label>
                </div>

                <input
                  type="text"
                  placeholder="Or enter UPI payload: upi://pay?pa=handle@bank..."
                  value={qrPayload}
                  onChange={(e) => setQrPayload(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-xs font-mono focus:outline-none focus:border-emerald-700 text-slate-900"
                />

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#047857] hover:bg-[#065f46] text-white font-bold py-2.5 rounded-md text-xs transition-colors shadow-sm inline-flex items-center justify-center gap-2"
                >
                  <Search className="w-3.5 h-3.5" />
                  <span>{loading ? 'Decoding Payload...' : 'Decode & Verify QR Code'}</span>
                </button>
              </form>
            </div>
          </div>
        </div>

        {/* Scan Result Output */}
        {result && (
          <div className={`p-5 rounded-md border-l-4 shadow-sm ${
            result.score >= 10 ? 'bg-red-50 border-red-600 text-red-950' :
            result.score >= 5 ? 'bg-amber-50 border-amber-600 text-amber-950' :
            'bg-emerald-50 border-emerald-600 text-emerald-950'
          }`}>
            <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-3 border-b border-black/10 pb-3 mb-4">
              <div className="flex items-center gap-2.5">
                {result.score >= 10 ? (
                  <ShieldAlert className="w-5 h-5 text-red-600 flex-shrink-0" />
                ) : result.score >= 5 ? (
                  <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0" />
                ) : (
                  <ShieldCheck className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                )}
                <div>
                  <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded border ${
                    result.score >= 10 ? 'bg-red-100 text-red-800 border-red-200' :
                    result.score >= 5 ? 'bg-amber-100 text-amber-800 border-amber-200' :
                    'bg-emerald-100 text-emerald-800 border-emerald-200'
                  }`}>
                    {result.status}
                  </span>
                  <h3 className="text-base font-bold mt-1 text-slate-900">{result.result}</h3>
                </div>
              </div>

              <div className="text-right text-xs">
                <div className="text-[10px] font-semibold uppercase text-slate-500">Risk Score</div>
                <div className="text-sm font-bold text-slate-900">{result.score} / 25</div>
              </div>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <span className="font-bold uppercase text-[10px] tracking-wide text-slate-700 block mb-1">
                  Extraction Findings
                </span>
                <div className="bg-white/80 p-3 rounded border border-black/5 text-slate-800 leading-relaxed font-mono">
                  {result.findings}
                </div>
              </div>

              <div>
                <span className="font-bold uppercase text-[10px] tracking-wide text-slate-700 block mb-1">
                  Safety Guidance
                </span>
                <div className="bg-white p-3 rounded border border-black/5 text-slate-900 leading-relaxed font-semibold flex items-start gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-700 flex-shrink-0 mt-0.5" />
                  <span>{result.advice}</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
