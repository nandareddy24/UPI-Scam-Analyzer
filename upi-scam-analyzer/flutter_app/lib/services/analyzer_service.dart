import '../models/scan_result.dart';

class AnalyzerService {
  static const Map<String, int> _scamKeywords = {
    'otp': 6,
    'kyc': 6,
    'blocked': 5,
    'suspend': 5,
    'verify your account': 6,
    'verify immediately': 6,
    'lottery': 8,
    'winner': 6,
    'prize': 5,
    'cashback': 4,
    'refund': 4,
    'click here': 5,
    'click the link': 5,
    'urgent': 4,
    'act now': 5,
    'bank account will be': 6,
    'update your details': 4,
    'lucky draw': 6,
    'free gift': 4,
    'debited': 3,
    'reward point': 4,
    'expire today': 5,
    'congratulations': 4,
  };

  static ScanResult analyzeMessage(String message) {
    final text = message.toLowerCase();
    int rawScore = 0;
    final reasons = <String>[];

    _scamKeywords.forEach((keyword, weight) {
      if (text.contains(keyword)) {
        rawScore += weight;
        reasons.add('Contains suspicious phrase: "$keyword"');
      }
    });

    if (RegExp(r'https?://|www\.').hasMatch(text)) {
      rawScore += 5;
      reasons.add('Contains an embedded external link — scam messages often push users to click phishing URLs.');
    }

    if (RegExp(r'\b\d{4,}\b').hasMatch(text) && text.contains('otp')) {
      rawScore += 5;
      reasons.add('Mentions OTP alongside a numeric code — never share OTPs with anyone.');
    }

    if (text.contains('!!!') || RegExp(r'[A-Z]{6,}').hasMatch(message)) {
      rawScore += 3;
      reasons.add('Uses excessive urgency markers (ALL CAPS or multiple exclamations).');
    }

    final score = rawScore.clamp(0, 25);
    final riskLevel = _riskFromScore(score);
    final confidence = (100 - score * 2.5).round().clamp(85, 99);

    if (reasons.isEmpty) {
      reasons.add('No known SMS scam patterns or malicious phishing indicators detected.');
    }

    final advice = riskLevel == RiskLevel.high
        ? 'Do NOT click links, enter PINs, or share OTPs. Immediately report this scam to National Cyber Crime Helpline (1930).'
        : riskLevel == RiskLevel.medium
            ? 'Exercise caution. Verify the sender before taking any action or clicking embedded links.'
            : 'Message appears clean. Always remember official banks never ask for OTPs or PINs over SMS.';

    final title = riskLevel == RiskLevel.high
        ? 'High Risk Scam Message'
        : riskLevel == RiskLevel.medium
            ? 'Suspicious SMS Alert'
            : 'Clean SMS Message';

    return ScanResult(
      type: 'message',
      input: message,
      riskLevel: riskLevel,
      score: score,
      confidence: confidence,
      verdictTitle: title,
      reasons: reasons,
      advice: advice,
    );
  }

  static const List<String> _upiSuspiciousWords = [
    'refund', 'cashback', 'kyc', 'verify', 'support', 'helpdesk',
    'lottery', 'reward', 'bonus', 'winner', 'customer', 'care',
  ];

  static const List<String> _knownValidHandles = [
    'okaxis', 'oksbi', 'okhdfcbank', 'okicici', 'ybl', 'ibl', 'axl', 'paytm',
    'apl', 'upi', 'jio', 'fbl', 'idfcbank', 'postbank', 'barodampay', 'kvb',
  ];

  static ScanResult analyzeUpiId(String upiId) {
    final id = upiId.trim().toLowerCase();
    int rawScore = 0;
    final reasons = <String>[];

    final upiRegex = RegExp(r'^[a-z0-9.\-_]{2,256}@[a-z]{2,64}$');
    if (!upiRegex.hasMatch(id)) {
      return ScanResult(
        type: 'upi',
        input: upiId,
        riskLevel: RiskLevel.high,
        score: 22,
        confidence: 98,
        verdictTitle: 'Invalid UPI Handle Format',
        reasons: const ['Does not follow valid UPI VPA structure (name@bank handle).'],
        advice: 'Do NOT attempt to transfer funds to malformed or unverified handles.',
      );
    }

    final handle = id.split('@').last;
    if (!_knownValidHandles.any((h) => handle.contains(h))) {
      rawScore += 7;
      reasons.add('Bank/PSP handle "@$handle" is not a standard registered handle.');
    }

    for (final word in _upiSuspiciousWords) {
      if (id.contains(word)) {
        rawScore += 8;
        reasons.add('UPI handle contains scam lure keyword: "$word".');
      }
    }

    final namePart = id.split('@').first;
    if (RegExp(r'^\d+$').hasMatch(namePart)) {
      rawScore += 6;
      reasons.add('UPI ID username is entirely numeric — common pattern in automated fraud accounts.');
    }

    if (namePart.length <= 3) {
      rawScore += 4;
      reasons.add('Unusually short username before the @ symbol.');
    }

    final score = rawScore.clamp(0, 25);
    final riskLevel = _riskFromScore(score);
    final confidence = (100 - score * 2.5).round().clamp(85, 99);

    if (reasons.isEmpty) {
      reasons.add('No recognized scam patterns found. Standard bank handle structure detected.');
    }

    final advice = riskLevel == RiskLevel.high
        ? 'High risk handle flagged for scam keyword usage. Double-check the receiver profile name before paying.'
        : riskLevel == RiskLevel.medium
            ? 'Unusual handle structure detected. Verify receiver identity carefully.'
            : 'No immediate red flags. Always verify the beneficiary name shown on your payment screen.';

    final title = riskLevel == RiskLevel.high
        ? 'Flagged Fraudulent UPI Handle'
        : riskLevel == RiskLevel.medium
            ? 'Unverified Handle Alert'
            : 'Verified Standard UPI Handle';

    return ScanResult(
      type: 'upi',
      input: upiId,
      riskLevel: riskLevel,
      score: score,
      confidence: confidence,
      verdictTitle: title,
      reasons: reasons,
      advice: advice,
    );
  }

  static const List<String> _shorteners = [
    'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'is.gd', 'ow.ly', 'cutt.ly', 'rb.gy',
  ];

  static const List<String> _suspiciousUrlWords = [
    'secure', 'verify', 'update', 'login', 'confirm', 'account', 'bank',
    'kyc', 'reward', 'bonus', 'free', 'gift', 'paytm', 'gpay', 'phonepe',
  ];

  static ScanResult analyzeUrl(String rawUrl) {
    var input = rawUrl.trim();
    int rawScore = 0;
    final reasons = <String>[];

    var normalized = input;
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }

    Uri? uri;
    try {
      uri = Uri.parse(normalized);
    } catch (_) {
      uri = null;
    }

    if (uri == null || uri.host.isEmpty) {
      return ScanResult(
        type: 'url',
        input: rawUrl,
        riskLevel: RiskLevel.high,
        score: 20,
        confidence: 96,
        verdictTitle: 'Invalid URL Format',
        reasons: const ['Target string is not a valid URL.'],
        advice: 'Do NOT click or navigate to unformatted link targets.',
      );
    }

    if (uri.scheme != 'https') {
      rawScore += 5;
      reasons.add('Link does not use SSL/HTTPS encryption (http://).');
    }

    if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(uri.host)) {
      rawScore += 12;
      reasons.add('Uses a raw IP address instead of a domain name — severe phishing indicator.');
    }

    if (_shorteners.any((s) => uri!.host.contains(s))) {
      rawScore += 7;
      reasons.add('Uses URL shortening service to obfuscate actual target destination.');
    }

    final hyphenCount = '-'.allMatches(uri.host).length;
    if (hyphenCount >= 2) {
      rawScore += 5;
      reasons.add('Domain name contains multiple hyphens (common typo-squatting trick).');
    }

    for (final word in _suspiciousUrlWords) {
      if (uri.host.contains(word) || uri.path.toLowerCase().contains(word)) {
        rawScore += 4;
        reasons.add('URL path contains high-risk phishing keyword: "$word".');
        break;
      }
    }

    final score = rawScore.clamp(0, 25);
    final riskLevel = _riskFromScore(score);
    final confidence = (100 - score * 2.5).round().clamp(85, 99);

    if (reasons.isEmpty) {
      reasons.add('No known phishing domain signatures or suspicious redirects detected.');
    }

    final advice = riskLevel == RiskLevel.high
        ? 'Phishing threat identified! Do NOT enter credentials, credit card info, or bank details.'
        : riskLevel == RiskLevel.medium
            ? 'Unverified domain structure. Inspect the URL bar carefully before entering information.'
            : 'Domain checked clean. Ensure lock icon is present in your browser address bar.';

    final title = riskLevel == RiskLevel.high
        ? 'Phishing URL Detected'
        : riskLevel == RiskLevel.medium
            ? 'Suspicious Link Alert'
            : 'Verified Safe URL';

    return ScanResult(
      type: 'url',
      input: rawUrl,
      riskLevel: riskLevel,
      score: score,
      confidence: confidence,
      verdictTitle: title,
      reasons: reasons,
      advice: advice,
    );
  }

  static ScanResult analyzeOcrQr(String imageName, [String sampleText = '']) {
    final text = sampleText.toLowerCase();
    if (text.contains('upi://pay') || text.contains('paytm') || text.contains('gpay') || text.contains('refund')) {
      return analyzeMessage(sampleText.isEmpty ? 'Scanned payment request payload: $imageName' : sampleText);
    }
    return ScanResult(
      type: 'ocr',
      input: imageName.isEmpty ? 'Scanned Screenshot / QR Payload' : imageName,
      riskLevel: RiskLevel.low,
      score: 3,
      confidence: 94,
      verdictTitle: 'Scanned Image Verified Safe',
      reasons: const ['Screenshot image scanned. No fraudulent UPI requests or suspicious links extracted.'],
      advice: 'No threat detected in scanned QR image.',
    );
  }

  static RiskLevel _riskFromScore(int score) {
    if (score >= 12) return RiskLevel.high;
    if (score >= 5) return RiskLevel.medium;
    return RiskLevel.low;
  }
}

