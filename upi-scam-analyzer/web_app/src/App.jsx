import { useEffect, useState } from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { watchAuthState } from './services/authService';

import Landing from './pages/Landing';
import Login from './pages/Login';
import Signup from './pages/Signup';
import VerifyOtp from './pages/VerifyOtp';
import Dashboard from './pages/Dashboard';
import OcrQrScanner from './pages/OcrQrScanner';
import MessageAnalyzer from './pages/MessageAnalyzer';
import UpiAnalyzer from './pages/UpiAnalyzer';
import UrlAnalyzer from './pages/UrlAnalyzer';
import History from './pages/History';
import Result from './pages/Result';
import Admin from './pages/Admin';
import ReportScam from './pages/ReportScam';

function RequireAuth({ user, children }) {
  if (user === undefined) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8fafc]">
        <p className="text-base font-extrabold text-[#047857]">Initializing Security Shield...</p>
      </div>
    );
  }
  if (!user) return <Navigate to="/landing" replace />;
  return children;
}

function RedirectIfAuthed({ user, children }) {
  if (user) return <Navigate to="/" replace />;
  return children;
}

export default function App() {
  const [user, setUser] = useState(undefined);

  useEffect(() => {
    const unsubscribe = watchAuthState((u) => setUser(u || null));
    return () => unsubscribe();
  }, []);

  return (
    <HashRouter>
      <Routes>
        <Route
          path="/landing"
          element={
            <RedirectIfAuthed user={user}>
              <Landing />
            </RedirectIfAuthed>
          }
        />
        <Route
          path="/login"
          element={
            <RedirectIfAuthed user={user}>
              <Login />
            </RedirectIfAuthed>
          }
        />
        <Route
          path="/signup"
          element={
            <RedirectIfAuthed user={user}>
              <Signup />
            </RedirectIfAuthed>
          }
        />
        <Route path="/verify-otp" element={<VerifyOtp />} />

        <Route
          path="/"
          element={
            <RequireAuth user={user}>
              <Dashboard />
            </RequireAuth>
          }
        />
        <Route
          path="/ocr_qr"
          element={
            <RequireAuth user={user}>
              <OcrQrScanner />
            </RequireAuth>
          }
        />
        <Route
          path="/admin"
          element={
            <RequireAuth user={user}>
              <Admin />
            </RequireAuth>
          }
        />
        <Route
          path="/report"
          element={
            <RequireAuth user={user}>
              <ReportScam />
            </RequireAuth>
          }
        />
        <Route
          path="/message"
          element={
            <RequireAuth user={user}>
              <MessageAnalyzer />
            </RequireAuth>
          }
        />
        <Route
          path="/upi"
          element={
            <RequireAuth user={user}>
              <UpiAnalyzer />
            </RequireAuth>
          }
        />
        <Route
          path="/url"
          element={
            <RequireAuth user={user}>
              <UrlAnalyzer />
            </RequireAuth>
          }
        />
        <Route
          path="/history"
          element={
            <RequireAuth user={user}>
              <History />
            </RequireAuth>
          }
        />
        <Route
          path="/result"
          element={
            <RequireAuth user={user}>
              <Result />
            </RequireAuth>
          }
        />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </HashRouter>
  );
}
