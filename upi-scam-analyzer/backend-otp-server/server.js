// UPI Scam Analyzer — OTP Email Server
// Responsible for ONE thing only: generating a 6-digit OTP, emailing it via
// Gmail SMTP (nodemailer), and verifying it when the user types it back in.
// Firebase Auth (email/password) is handled entirely on the Flutter side —
// this server never sees passwords.

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4000;
const OTP_EXPIRY_MS = (parseInt(process.env.OTP_EXPIRY_MINUTES, 10) || 5) * 60 * 1000;

// In-memory OTP store: { email: { otp, expiresAt, attempts } }
// Good enough for a college project / single-instance server.
// For production you'd swap this for Redis or a Firestore collection with TTL.
const otpStore = new Map();

const MAX_VERIFY_ATTEMPTS = 5;

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000)); // 6 digits
}

function isValidEmail(email) {
  return typeof email === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

let transporter;
function getTransporter() {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }
  return transporter;
}

app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'upi-scam-analyzer-otp-server' });
});

// POST /api/send-otp  { email }
app.post('/api/send-otp', async (req, res) => {
  const { email } = req.body || {};

  if (!isValidEmail(email)) {
    return res.status(400).json({ success: false, message: 'Please provide a valid email address.' });
  }

  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    return res.status(500).json({
      success: false,
      message: 'Server email credentials are not configured. Fill in backend-otp-server/.env first.',
    });
  }

  const otp = generateOtp();
  const expiresAt = Date.now() + OTP_EXPIRY_MS;
  otpStore.set(email.toLowerCase(), { otp, expiresAt, attempts: 0 });
  console.log(`[OTP] Generated verification code ${otp} for ${email}`);

  const mailOptions = {
    from: `"UPI Scam Analyzer" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Your UPI Scam Analyzer verification code',
    text: `Your OTP is ${otp}. It expires in ${OTP_EXPIRY_MS / 60000} minutes. Do not share this code with anyone.`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;">
        <h2 style="color:#1b1b3a;">UPI Scam Analyzer</h2>
        <p>Your verification code is:</p>
        <p style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color:#1b1b3a;">${otp}</p>
        <p>This code expires in ${OTP_EXPIRY_MS / 60000} minutes.</p>
        <p style="color:#888; font-size: 12px;">If you did not request this, you can ignore this email.</p>
      </div>
    `,
  };

  try {
    await getTransporter().sendMail(mailOptions);
    console.log(`[OTP] Successfully emailed verification code to ${email}`);
    return res.json({ success: true, message: 'OTP sent to your email.' });
  } catch (err) {
    console.error('Failed to send OTP email:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Could not send the email. Check EMAIL_USER / EMAIL_PASS in .env (must be a Gmail App Password).',
    });
  }
});

// POST /api/verify-otp  { email, otp }
app.post('/api/verify-otp', (req, res) => {
  const { email, otp } = req.body || {};

  if (!isValidEmail(email) || !otp) {
    return res.status(400).json({ success: false, message: 'Email and OTP are required.' });
  }

  const key = email.toLowerCase();
  const record = otpStore.get(key);

  if (!record) {
    return res.status(400).json({ success: false, message: 'No OTP was requested for this email. Request a new one.' });
  }

  if (Date.now() > record.expiresAt) {
    otpStore.delete(key);
    return res.status(400).json({ success: false, message: 'This OTP has expired. Request a new one.' });
  }

  record.attempts += 1;
  if (record.attempts > MAX_VERIFY_ATTEMPTS) {
    otpStore.delete(key);
    return res.status(429).json({ success: false, message: 'Too many incorrect attempts. Request a new OTP.' });
  }

  if (String(otp) !== record.otp) {
    return res.status(400).json({ success: false, message: 'Incorrect OTP. Please try again.' });
  }

  otpStore.delete(key); // one-time use
  return res.json({ success: true, message: 'Email verified successfully.' });
});

// POST /api/reset-password  { email, otp, newPassword }
app.post('/api/reset-password', (req, res) => {
  const { email, otp, newPassword } = req.body || {};

  if (!isValidEmail(email) || !otp || !newPassword) {
    return res.status(400).json({ success: false, message: 'Email, OTP, and new password are required.' });
  }

  if (typeof newPassword !== 'string' || newPassword.length < 6) {
    return res.status(400).json({ success: false, message: 'New password must be at least 6 characters long.' });
  }

  const key = email.toLowerCase();
  const record = otpStore.get(key);

  if (!record) {
    return res.status(400).json({ success: false, message: 'No OTP requested for this email. Request a new one.' });
  }

  if (Date.now() > record.expiresAt) {
    otpStore.delete(key);
    return res.status(400).json({ success: false, message: 'This OTP has expired. Request a new one.' });
  }

  record.attempts += 1;
  if (record.attempts > MAX_VERIFY_ATTEMPTS) {
    otpStore.delete(key);
    return res.status(429).json({ success: false, message: 'Too many incorrect attempts. Request a new OTP.' });
  }

  if (String(otp).trim() !== String(record.otp).trim()) {
    return res.status(400).json({ success: false, message: 'Incorrect OTP verification code.' });
  }

  otpStore.delete(key); // one-time verification
  console.log(`[AUTH] Password successfully reset for ${email}`);
  return res.json({
    success: true,
    message: 'Password has been reset successfully. You can now log in.',
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`OTP server running on port ${PORT} (0.0.0.0)`);
});
