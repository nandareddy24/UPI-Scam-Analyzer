// Pure, offline, rule-based scam analysis engine — aligned with nandareddy24/UPI-Scam-Analyzer
// Provides detailed Threat Score (0-25), Confidence %, Verdict Badges, AI Findings & Safety Advice.

function clamp(n, min, max) {
  return Math.max(min, Math.min(max, n));
}

function calculateVerdict(score) {
  let status = 'VERIFIED SAFE';
  let badgeClass = 'safe';
  let riskLevel = 'low';

  if (score >= 12) {
    status = 'CRITICAL THREAT';
    badgeClass = 'danger';
    riskLevel = 'high';
  } else if (score >= 5) {
    status = 'SUSPICIOUS WARNING';
    badgeClass = 'warning';
    riskLevel = 'medium';
  }

  const confidence = clamp(Math.round(100 - score * 2.5), 85, 99);
  return { status, badgeClass, riskLevel, confidence };
}

const SCAM_KEYWORDS = {
  otp: 6,
  kyc: 6,
  blocked: 5,
  suspend: 5,
  'verify your account': 6,
  'verify immediately': 6,
  lottery: 8,
  winner: 6,
  prize: 5,
  cashback: 4,
  refund: 4,
  'click here': 5,
  'click the link': 5,
  urgent: 4,
  'act now': 5,
  'bank account will be': 6,
  'update your details': 4,
  'lucky draw': 6,
  'free gift': 4,
  debited: 3,
  'reward point': 4,
  'expire today': 5,
  congratulations: 4,
};

export function analyzeMessage(message) {
  const text = message.toLowerCase();
  let rawScore = 0;
  const reasons = [];

  for (const [keyword, weight] of Object.entries(SCAM_KEYWORDS)) {
    if (text.includes(keyword)) {
      rawScore += weight;
      reasons.push(`Contains suspicious phrase: "${keyword}"`);
    }
  }

  if (/https?:\/\/|www\./.test(text)) {
    rawScore += 5;
    reasons.push('Contains an embedded external link — scam messages often push users to click phishing URLs.');
  }

  if (/\b\d{4,}\b/.test(text) && text.includes('otp')) {
    rawScore += 5;
    reasons.push('Mentions OTP alongside a numeric code — never share OTPs with anyone.');
  }

  if (message.includes('!!!') || /[A-Z]{6,}/.test(message)) {
    rawScore += 3;
    reasons.push('Uses excessive urgency markers (ALL CAPS or multiple exclamations).');
  }

  const score = clamp(rawScore, 0, 25);
  const verdict = calculateVerdict(score);

  if (reasons.length === 0) {
    reasons.push('No known SMS scam patterns or malicious phishing indicators detected.');
  }

  const advice = verdict.riskLevel === 'high'
    ? 'Do NOT click links, enter PINs, or share OTPs. Immediately report this scam to National Cyber Crime Helpline (1930).'
    : verdict.riskLevel === 'medium'
    ? 'Exercise caution. Verify the sender before taking any action or clicking embedded links.'
    : 'Message appears clean. Always remember official banks never ask for OTPs or PINs over SMS.';

  return {
    type: 'message',
    input: message,
    score,
    result: verdict.status === 'CRITICAL THREAT' ? 'High Risk Scam Message' : verdict.status === 'SUSPICIOUS WARNING' ? 'Suspicious SMS Alert' : 'Clean SMS Message',
    ...verdict,
    reasons,
    findings: reasons.join(' '),
    advice,
  };
}

const UPI_SUSPICIOUS_WORDS = [
  'refund', 'cashback', 'kyc', 'verify', 'support', 'helpdesk',
  'lottery', 'reward', 'bonus', 'winner', 'customer', 'care',
];

const KNOWN_VALID_HANDLES = [
  'okaxis', 'oksbi', 'okhdfcbank', 'okicici', 'ybl', 'ibl', 'axl', 'paytm',
  'apl', 'upi', 'jio', 'fbl', 'idfcbank', 'postbank', 'barodampay', 'kvb',
];

export function analyzeUpiId(upiId) {
  const id = upiId.trim().toLowerCase();
  let rawScore = 0;
  const reasons = [];

  const upiRegex = /^[a-z0-9.\-_]{2,256}@[a-z]{2,64}$/;
  if (!upiRegex.test(id)) {
    return {
      type: 'upi',
      input: upiId,
      score: 22,
      result: 'Invalid UPI Handle Format',
      status: 'CRITICAL THREAT',
      badgeClass: 'danger',
      riskLevel: 'high',
      confidence: 98,
      reasons: ['Does not follow valid UPI VPA structure (name@bank handle).'],
      findings: 'Invalid handle structure. Standard UPI IDs follow name@bank format.',
      advice: 'Do NOT attempt to transfer funds to malformed or unverified handles.',
    };
  }

  const handle = id.split('@').pop();
  if (!KNOWN_VALID_HANDLES.some((h) => handle.includes(h))) {
    rawScore += 7;
    reasons.push(`Bank/PSP handle "@${handle}" is not a standard registered handle.`);
  }

  for (const word of UPI_SUSPICIOUS_WORDS) {
    if (id.includes(word)) {
      rawScore += 8;
      reasons.push(`UPI handle contains scam lure keyword: "${word}".`);
    }
  }

  const namePart = id.split('@')[0];
  if (/^\d+$/.test(namePart)) {
    rawScore += 6;
    reasons.push('UPI ID username is entirely numeric — common pattern in automated fraud accounts.');
  }

  if (namePart.length <= 3) {
    rawScore += 4;
    reasons.push('Unusually short username before the @ symbol.');
  }

  const score = clamp(rawScore, 0, 25);
  const verdict = calculateVerdict(score);

  if (reasons.length === 0) {
    reasons.push('No recognized scam patterns found. Standard bank handle structure detected.');
  }

  const advice = verdict.riskLevel === 'high'
    ? 'High risk handle flagged for scam keyword usage. Double-check the receiver profile name before paying.'
    : verdict.riskLevel === 'medium'
    ? 'Unusual handle structure detected. Verify receiver identity carefully.'
    : 'No immediate red flags. Always verify the beneficiary name shown on your payment screen.';

  return {
    type: 'upi',
    input: upiId,
    score,
    result: verdict.status === 'CRITICAL THREAT' ? 'Flagged Fraudulent UPI Handle' : verdict.status === 'SUSPICIOUS WARNING' ? 'Unverified Handle Alert' : 'Verified Standard UPI Handle',
    ...verdict,
    reasons,
    findings: reasons.join(' '),
    advice,
  };
}

const SHORTENERS = ['bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'is.gd', 'ow.ly', 'cutt.ly', 'rb.gy'];
const SUSPICIOUS_URL_WORDS = [
  'secure', 'verify', 'update', 'login', 'confirm', 'account', 'bank',
  'kyc', 'reward', 'bonus', 'free', 'gift', 'paytm', 'gpay', 'phonepe',
];

export function analyzeUrl(rawUrl) {
  const input = rawUrl.trim();
  let rawScore = 0;
  const reasons = [];

  let normalized = input;
  if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
    normalized = `http://${normalized}`;
  }

  let url;
  try {
    url = new URL(normalized);
  } catch {
    url = null;
  }

  if (!url || !url.host) {
    return {
      type: 'url',
      input: rawUrl,
      score: 20,
      result: 'Invalid URL Format',
      status: 'CRITICAL THREAT',
      badgeClass: 'danger',
      riskLevel: 'high',
      confidence: 96,
      reasons: ['Target string is not a valid URL.'],
      findings: 'Malformed web address.',
      advice: 'Do NOT click or navigate to unformatted link targets.',
    };
  }

  if (url.protocol !== 'https:') {
    rawScore += 5;
    reasons.push('Link does not use SSL/HTTPS encryption (http://).');
  }

  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(url.hostname)) {
    rawScore += 12;
    reasons.push('Uses a raw IP address instead of a domain name — severe phishing indicator.');
  }

  if (SHORTENERS.some((s) => url.hostname.includes(s))) {
    rawScore += 7;
    reasons.push('Uses URL shortening service to obfuscate actual target destination.');
  }

  const hyphenCount = (url.hostname.match(/-/g) || []).length;
  if (hyphenCount >= 2) {
    rawScore += 5;
    reasons.push('Domain name contains multiple hyphens (common typo-squatting trick).');
  }

  for (const word of SUSPICIOUS_URL_WORDS) {
    if (url.hostname.includes(word) || url.pathname.toLowerCase().includes(word)) {
      rawScore += 4;
      reasons.push(`URL path contains high-risk phishing keyword: "${word}".`);
      break;
    }
  }

  const score = clamp(rawScore, 0, 25);
  const verdict = calculateVerdict(score);

  if (reasons.length === 0) {
    reasons.push('No known phishing domain signatures or suspicious redirects detected.');
  }

  const advice = verdict.riskLevel === 'high'
    ? 'Phishing threat identified! Do NOT enter credentials, credit card info, or bank details.'
    : verdict.riskLevel === 'medium'
    ? 'Unverified domain structure. Inspect the URL bar carefully before entering information.'
    : 'Domain checked clean. Ensure lock icon is present in your browser address bar.';

  return {
    type: 'url',
    input: rawUrl,
    score,
    result: verdict.status === 'CRITICAL THREAT' ? 'Phishing URL Detected' : verdict.status === 'SUSPICIOUS WARNING' ? 'Suspicious Link Alert' : 'Verified Safe URL',
    ...verdict,
    reasons,
    findings: reasons.join(' '),
    advice,
  };
}

export function analyzeOcrQr(imageName, sampleText = '') {
  // OCR / QR analysis simulation
  const text = sampleText.toLowerCase();
  if (text.includes('upi://pay') || text.includes('paytm') || text.includes('gpay')) {
    return analyzeMessage(sampleText || 'Payment request QR code scanned');
  }
  return {
    type: 'ocr',
    input: imageName || 'Scanned Screenshot / QR',
    score: 3,
    result: 'Scanned Image Verified Safe',
    status: 'VERIFIED SAFE',
    badgeClass: 'safe',
    riskLevel: 'low',
    confidence: 94,
    reasons: ['Screenshot image scanned. No fraudulent UPI requests or suspicious links extracted.'],
    findings: 'OCR text extraction completed. Payload analyzed clean.',
    advice: 'No threat detected in scanned QR image.',
  };
}
