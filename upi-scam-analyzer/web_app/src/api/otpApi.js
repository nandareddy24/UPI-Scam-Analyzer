const BASE_URL = import.meta.env.VITE_OTP_API_BASE || 'http://localhost:4000';

async function post(path, body) {
  try {
    const res = await fetch(`${BASE_URL}${path}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const data = await res.json();
    return { success: data.success === true, message: data.message || 'Unknown response.' };
  } catch (err) {
    return { success: false, message: `Could not reach the OTP server. Is it running? (${err.message})` };
  }
}

export function sendOtp(email) {
  return post('/api/send-otp', { email });
}

export function verifyOtp(email, otp) {
  return post('/api/verify-otp', { email, otp });
}
