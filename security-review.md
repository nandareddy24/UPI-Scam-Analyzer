# 🔐 Scam Shield AI — Comprehensive Backend Security Review

**Assessment Date:** August 2026  
**Assessor Role:** Senior Application Security Engineer / Penetration Tester  
**Application:** Scam Shield AI (UPI-Scam-Analyzer)  
**Framework:** Python Flask 3.x  
**Database:** SQLite (Primary) / PostgreSQL (Fallback)  
**Classification:** CONFIDENTIAL — Student Project Security Audit

---

## 📋 EXECUTIVE OVERVIEW

| Category | Count |
|---|---|
| 🔴 Critical Severity | 7 |
| 🟠 High Severity | 9 |
| 🟡 Medium Severity | 11 |
| 🔵 Low Severity | 8 |
| ℹ️ Informational | 6 |
| **Total Findings** | **41** |

**Overall Risk Rating: 🔴 CRITICAL**

---

## 📦 PHASE 1 — BACKEND INVENTORY

### Technology Stack
| Component | Detail |
|---|---|
| Language | Python 3.x |
| Framework | Flask 3.0+ |
| ORM | None (raw SQL via DBWrapper) |
| Primary Database | SQLite 3 (file: database.db) |
| Fallback Database | PostgreSQL (psycopg2-binary) |
| Authentication | Flask session + bcrypt password hashing |
| Authorization | Hardcoded admin email constant |
| ML Models | scikit-learn (joblib .pkl files) |
| File Upload | OCR screenshots, QR images (cv2/PIL) |
| Email | Brevo, SendGrid, Resend, SMTP |
| External APIs | VirusTotal v3, Google Safe Browsing v4 |
| Session Handling | Flask server-side session (cookie-based) |
| CORS | Wildcard * on extension endpoints |
| Deployment | Gunicorn + Render.yaml |

### OTP Storage
- otp_storage = {} — In-memory Python dict (not persistent, not thread-safe)
- reset_otp_storage = {} — Same pattern for password reset

---

## 🗂️ PHASE 2 — API ENDPOINT INVENTORY

| # | Method | Endpoint | Auth Required | Input | Output |
|---|---|---|---|---|---|
| 1 | GET | / | No | None | Redirect to /login |
| 2 | GET/POST | /register | No | name, email, password, confirm | OTP page |
| 3 | POST | /verify_otp | No | email, otp | Redirect to /login |
| 4 | POST | /verify_reset_otp | No | email, otp | Reset password page |
| 5 | GET/POST | /login | No | email, password | Redirect to /dashboard |
| 6 | GET | /logout | No | None | Redirect to /login |
| 7 | GET/POST | /forgot | No | email | OTP reset page |
| 8 | POST | /update_password | No | email, password, confirm | Redirect to /login |
| 9 | GET | /dashboard | Session | None | Dashboard HTML |
| 10 | GET/POST | /admin | Session + Admin | data, type, reason | Admin HTML |
| 11 | POST | /admin/approve_report/id | Session + Admin | Path ID | Redirect |
| 12 | POST | /admin/reject_report/id | Session + Admin | Path ID | Redirect |
| 13 | POST | /delete_blacklist/id | NONE (BUG) | Path ID | Redirect |
| 14 | GET | /scan | Session | None | Scan Hub HTML |
| 15 | GET | /history | Session | None | History HTML |
| 16 | GET | /ocr_qr | Session | None | OCR/QR HTML |
| 17 | POST | /scan_qr | NONE (BUG) | payload/qr_image file | JSON |
| 18 | POST | /scan_ocr | NONE (BUG) | screenshot file | JSON |
| 19 | GET | /download_pdf_report/id | Session | Path ID | PDF Binary |
| 20 | GET | /upi | Session | None | UPI HTML |
| 21 | GET | /url | Session | None | URL HTML |
| 22 | GET | /sms | Session | None | SMS HTML |
| 23 | POST | /check_upi | NONE (BUG) | JSON: {upi} | JSON |
| 24 | POST | /api/v1/scan/upi | NONE (BUG) | JSON: {upi} | JSON |
| 25 | POST | /check_phone | NONE (BUG) | JSON: {phone} | JSON |
| 26 | POST | /api/v1/scan/phone | NONE (BUG) | JSON: {phone} | JSON |
| 27 | POST | /check_url | NONE (BUG) | JSON: {url} | JSON |
| 28 | POST | /api/v1/scan/url | NONE (BUG) | JSON: {url} | JSON |
| 29 | POST | /check_sms | NONE (BUG) | JSON: {sms} | JSON |
| 30 | POST | /api/v1/scan/sms | NONE (BUG) | JSON: {sms} | JSON |
| 31 | GET | /report | Session | None | Report HTML |
| 32 | POST | /report_scam | Session | JSON: {data, type, reason, proof} | JSON |
| 33 | GET | /export_data | Session | None | CSV Download |
| 34 | POST | /api/v1/analyze | NONE (BUG) | JSON: {type, data} | JSON |
| 35 | GET | /chatbot | Session | None | Chatbot HTML |
| 36 | POST | /api/v1/chat | NONE (BUG) | JSON: {message} | JSON |
| 37 | POST/OPTIONS | /api/v1/extension/check_url | NONE (BUG) | JSON: {url} | JSON + CORS * |
| 38 | GET | /extension | Session | None | Extension HTML |
| 39 | GET | /download_extension_zip | Session | None | ZIP Binary |
| 40 | GET | /mobile, /mobile_app | NONE (BUG) | None | HTML |
| 41 | GET | /android | Session | None | Android HTML |
| 42 | GET | /download_android_zip | Session | None | ZIP Binary |
| 43 | POST | /api/v1/auth/register | No | JSON: {name, email, password} | JSON |
| 44 | POST | /api/v1/auth/login | No | JSON: {email, password} | JSON |
| 45 | POST | /api/v1/auth/logout | No | None | JSON |
| 46 | GET | /api/v1/auth/me | Session | None | JSON |
| 47 | GET | /api/v1/admin/blacklist | Session + Admin | None | JSON |
| 48 | GET | /api/v1/admin/reports | Session + Admin | None | JSON |

---

## 🔍 PHASE 3 — STATIC APPLICATION SECURITY TESTING (SAST)

---

### FINDING #001 — CRITICAL: Hardcoded Secret Key Fallback

**Severity:** Critical | **CWE:** CWE-798 | **OWASP:** A02:2021

**File:** app.py, Line 29

```python
# VULNERABLE:
app.secret_key = os.getenv("SECRET_KEY", "secret123")
```

**Impact:** If SECRET_KEY is not set in environment, Flask uses "secret123" as the session signing secret. An attacker can forge arbitrary session cookies, impersonate any user including admin.

**Fix:**
```python
secret_key = os.getenv("SECRET_KEY")
if not secret_key:
    raise RuntimeError("SECRET_KEY environment variable is not set.")
app.secret_key = secret_key
```

---

### FINDING #002 — CRITICAL: Hardcoded Admin Email in Source Code

**Severity:** Critical | **CWE:** CWE-798 | **OWASP:** A01:2021

**File:** app.py, Line 31

```python
# VULNERABLE:
ADMIN_EMAIL = "nandakumarreddy63@gmail.com"
```

**Impact:** Admin email visible in source code. All admin authorization relies on this single hardcoded string. The admin identity is also leaked in API responses via is_admin comparisons.

**Fix:**
```python
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL")
if not ADMIN_EMAIL:
    raise RuntimeError("ADMIN_EMAIL must be configured as an environment variable.")
```

---

### FINDING #003 — CRITICAL: Missing Authentication on Core Scan APIs

**Severity:** Critical | **CWE:** CWE-306 | **OWASP:** A01:2021

**Affected Endpoints:**
- POST /check_upi, /api/v1/scan/upi
- POST /check_phone, /api/v1/scan/phone
- POST /check_url, /api/v1/scan/url
- POST /check_sms, /api/v1/scan/sms
- POST /api/v1/analyze
- POST /api/v1/chat
- POST /api/v1/extension/check_url

**Impact:** Any unauthenticated attacker can call all scan APIs. Enables mass automated abuse, API scraping, unauthorized database writes, DoS via bulk requests.

**Fix:**
```python
from functools import wraps

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user' not in session:
            return jsonify({"error": "Authentication required"}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/api/v1/scan/upi', methods=['POST'])
@login_required
def check_upi():
    ...
```

---

### FINDING #004 — CRITICAL: Missing Authentication on File Upload Endpoints

**Severity:** Critical | **CWE:** CWE-434 | **OWASP:** A01:2021

**File:** app.py, Lines 1002-1030, 1033-1090

**Impact:** Unauthenticated users can upload arbitrary files to /scan_qr and /scan_ocr. No file size limit, no MIME type validation, no extension check.

**Fix:**
```python
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024  # 5MB limit

@app.route('/scan_qr', methods=['POST'])
@login_required
def scan_qr():
    if 'qr_image' in request.files:
        file = request.files['qr_image']
        allowed_types = {'image/jpeg', 'image/png', 'image/gif', 'image/webp'}
        if file.content_type not in allowed_types:
            return jsonify({"error": "Invalid file type"}), 400
```

---

### FINDING #005 — CRITICAL: IDOR on PDF Report Download

**Severity:** Critical | **CWE:** CWE-639 | **OWASP:** A01:2021

**File:** app.py, Lines 1093-1166

```python
# VULNERABLE: No user_id filter
cursor.execute("SELECT ... FROM scans WHERE id=%s", (scan_id,))
```

**Impact:** Any authenticated user can enumerate scan IDs and download PDF reports from other users, exposing their scanned UPI handles, phone numbers, URLs.

**Fix:**
```python
uid = get_current_user_id()
cursor.execute(
    "SELECT ... FROM scans WHERE id=%s AND user_id=%s",
    (scan_id, uid)
)
```

---

### FINDING #006 — CRITICAL: Zero Authentication on Blacklist Delete

**Severity:** Critical | **CWE:** CWE-285 | **OWASP:** A01:2021

**File:** app.py, Lines 963-973

```python
# VULNERABLE: No auth at all!
@app.route('/delete_blacklist/<int:id>', methods=['POST'])
def delete_blacklist(id):
    cursor.execute("DELETE FROM blacklist WHERE id=%s", (id,))
    db.commit()
```

**Impact:** ANY unauthenticated attacker can delete any blacklist entry by iterating integer IDs, destroying core fraud detection data.

**Fix:**
```python
def delete_blacklist(id):
    if 'user' not in session or session['user'] != ADMIN_EMAIL:
        return jsonify({"error": "Unauthorized"}), 403
    cursor.execute("DELETE FROM blacklist WHERE id=%s", (id,))
    db.commit()
```

---

### FINDING #007 — CRITICAL: In-Memory OTP Storage Race Condition

**Severity:** Critical | **CWE:** CWE-362 | **OWASP:** A04:2021

**File:** app.py, Lines 199-200

```python
# VULNERABLE: Not thread-safe, not persistent
otp_storage = {}
reset_otp_storage = {}
```

**Impact:** In Gunicorn multi-worker deployment, each worker has its own otp_storage. OTP stored by worker-1 cannot be read by worker-2. OTPs lost on server restart. Race conditions with concurrent registrations.

**Fix:** Use Redis or a database for OTP storage.

---

### FINDING #008 — HIGH: No Rate Limiting on Authentication Endpoints

**Severity:** High | **CWE:** CWE-307 | **OWASP:** A07:2021

**Impact:** No brute force protection on /login, /verify_otp, /forgot. Attackers can brute-force 6-digit OTPs (~1,000,000 combos) or passwords without restriction.

**Fix:**
```python
from flask_limiter import Limiter
limiter = Limiter(app=app, key_func=get_remote_address)

@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("5/minute")
def login():
    ...
```

---

### FINDING #009 — HIGH: CORS Wildcard on Extension API

**Severity:** High | **CWE:** CWE-942 | **OWASP:** A05:2021

**File:** app.py, Lines 1312-1345

```python
response.headers.add("Access-Control-Allow-Origin", "*")
```

**Impact:** Any website can call the extension API from any browser, enabling CSRF-like abuse and data exfiltration.

---

### FINDING #010 — HIGH: Password Reset Without OTP Verification

**Severity:** High | **CWE:** CWE-640 | **OWASP:** A07:2021

**File:** app.py, Lines 826-854

```python
# VULNERABLE: No check that OTP was verified!
@app.route('/update_password', methods=['POST'])
def update_password():
    email = request.form['email']
    password = request.form['password']
    # Directly updates password without confirming OTP challenge was passed
    cursor.execute("UPDATE users SET password=%s WHERE email=%s", (hashed, email))
```

**Impact:** Attacker who knows any registered email can bypass OTP and reset password directly via POST.

---

### FINDING #011 — HIGH: Scan History Exposes ALL Users' Data

**Severity:** High | **CWE:** CWE-200 | **OWASP:** A01:2021

**File:** app.py, Lines 975-992

```python
# VULNERABLE: No WHERE user_id filter
cursor.execute("SELECT ... FROM scans ORDER BY id DESC")
```

**Impact:** Any authenticated user sees all other users' scan histories — full privacy violation.

---

### FINDING #012 — HIGH: Export CSV Exposes ALL Users' Data

**Severity:** High | **CWE:** CWE-200 | **OWASP:** A01:2021

**File:** app.py, Line 1639

**Impact:** Any authenticated user can download a full database dump of all user scan activity as CSV.

---

### FINDING #013 — HIGH: Dashboard Statistics Leak Global Data

**Severity:** High | **CWE:** CWE-200 | **OWASP:** A01:2021

**File:** app.py, Lines 876-889

**Impact:** Dashboard shows global scan stats and last 5 scans from ALL users to any authenticated user.

---

### FINDING #014 — HIGH: Flask Debug Mode Enabled

**Severity:** High | **CWE:** CWE-94 | **OWASP:** A05:2021

**File:** app.py, Line 1767

```python
app.run(debug=True)
```

**Impact:** Werkzeug interactive debugger exposed. Can execute arbitrary Python code on server if an exception occurs.

---

### FINDING #015 — HIGH: User Enumeration via Login Error Messages

**Severity:** High | **CWE:** CWE-204 | **OWASP:** A07:2021

**File:** app.py, Lines 746-747, 800-801

```python
return "User not found ❌"    # Confirms email not registered
return "Email not found ❌"   # Confirms email not registered
```

**Impact:** Attackers can enumerate valid registered email addresses.

---

### FINDING #016 — HIGH: Sensitive Data Logged to Console

**Severity:** High | **CWE:** CWE-532 | **OWASP:** A09:2021

**File:** app.py, Lines 653, 817, 770-772

```python
print(f"REGISTRATION OTP for {email}: {otp}")   # OTP in logs
print(f"RESET OTP for {email}: {otp}")          # OTP in logs
print("Stored Password:", stored)               # Password hash in logs
```

---

### FINDING #017 — MEDIUM: No CSRF Protection on State-Changing Forms

**Severity:** Medium | **CWE:** CWE-352 | **OWASP:** A01:2021

**Impact:** All POST forms lack CSRF tokens. Attackers can craft malicious pages that silently submit forms on behalf of authenticated users.

---

### FINDING #018 — MEDIUM: No Input Validation on Report Fields

**Severity:** Medium | **CWE:** CWE-79 | **OWASP:** A03:2021

**Impact:** Unlimited-length reason and proof fields stored directly in DB. Risk of stored XSS when rendered in admin panel.

---

### FINDING #019 — MEDIUM: Raw Exception Messages in API Responses

**Severity:** Medium | **CWE:** CWE-209 | **OWASP:** A05:2021

```python
return jsonify({"status": "error", "message": str(e)}), 500
```

**Impact:** Exposes database schema, file paths, SQL errors to API consumers.

---

### FINDING #020 — MEDIUM: Missing Security Headers

**Severity:** Medium | **CWE:** CWE-693 | **OWASP:** A05:2021

**Missing:** Content-Security-Policy, X-Frame-Options, X-Content-Type-Options, Strict-Transport-Security, Referrer-Policy

---

### FINDING #021 — MEDIUM: No File Size Limit on Image Uploads

**Severity:** Medium | **CWE:** CWE-770 | **OWASP:** A05:2021

**Impact:** Uploading large files (100MB+) causes server memory exhaustion and DoS.

---

### FINDING #022 — MEDIUM: SQL Wildcard Injection in Blacklist Query

**Severity:** Medium | **CWE:** CWE-89 | **OWASP:** A03:2021

**File:** app.py, Lines 233-260

**Impact:** User-controlled input with % or _ wildcards in LIKE queries can cause all blacklist entries to match (false positive flood) or never match (blacklist bypass).

---

### FINDING #023 — MEDIUM: No Session Timeout

**Severity:** Medium | **CWE:** CWE-613 | **OWASP:** A07:2021

**Impact:** Sessions never expire server-side. Stolen cookies grant permanent access.

---

### FINDING #024 — MEDIUM: Insecure Session Cookie Attributes

**Severity:** Medium | **CWE:** CWE-614 | **OWASP:** A07:2021

**Missing:** Secure, HttpOnly, SameSite cookie attributes.

---

### FINDING #025 — MEDIUM: No Password Complexity Enforcement

**Severity:** Medium | **CWE:** CWE-521 | **OWASP:** A07:2021

**Impact:** Users can register with single-character or trivially weak passwords.

---

### FINDING #026 — MEDIUM: No Email Format Validation

**Severity:** Medium | **CWE:** CWE-20 | **OWASP:** A03:2021

**Impact:** Malformed emails inserted into DB, causing OTP delivery failures and potential XSS in admin views.

---

### FINDING #027 — MEDIUM: Joblib Pickle Deserialization Risk

**Severity:** Medium | **CWE:** CWE-502 | **OWASP:** A08:2021

```python
sms_model = joblib.load("sms_model.pkl")  # Arbitrary code execution risk
```

**Impact:** Malicious .pkl files execute arbitrary code at startup.

---

### FINDING #028 — MEDIUM: No API Key Authentication for Developer API

**Severity:** Medium | **CWE:** CWE-306

**Impact:** /api/v1/analyze has no rate limiting, no authentication, no usage tracking.

---

### FINDING #029 — LOW: Verbose Error Messages in Login

**Severity:** Low | **CWE:** CWE-532

---

### FINDING #030 — LOW: .env File in Repository Root

**Severity:** Low | **CWE:** CWE-312

**Impact:** If accidentally committed to public Git repository, all secrets exposed.

---

### FINDING #031 — LOW: Browser Extension PEM Key in Repository

**Severity:** Low | **CWE:** CWE-312

**Impact:** Private key for Chrome extension signing exposed in repository.

---

### FINDING #032 — LOW: SQLite Database File in Repository

**Severity:** Low | **CWE:** CWE-312

**Impact:** database.db (36KB) contains user records, bcrypt hashes, blacklist entries.

---

### FINDING #033 — LOW: ML Model Files Committable to Repository

**Severity:** Low

**Impact:** url_model.pkl (8.7MB) in repository. Tampered models could alter fraud detection behavior.

---

### FINDING #034 — LOW: No Security Audit Trail / Logging

**Severity:** Low | **CWE:** CWE-778 | **OWASP:** A09:2021

**Impact:** Failed logins, unauthorized access attempts not logged. Incident response impossible.

---

### FINDING #035 — LOW: No Input Length Limits in APIs

**Severity:** Low

**Impact:** Unlimited-length SMS/URL/UPI strings accepted. ML vectorizer CPU exhaustion via large inputs.

---

### FINDING #036 — INFO: reportlab Lazy Import

**Severity:** Informational | **File:** app.py, Line 1106

Import errors only surface at runtime, not startup.

---

### FINDING #037 — INFO: reportlab Missing from requirements.txt

**Severity:** Informational

reportlab used in /download_pdf_report but absent from requirements.txt. Causes deployment failures.

---

### FINDING #038 — INFO: Shared Database Cursor Not Thread-Safe

**Severity:** Informational | **File:** app.py, Lines 170-177

Global cursor singleton — concurrent requests can mix query results.

---

### FINDING #039 — INFO: Weak OTP PRNG (random.randint)

**Severity:** Informational | **File:** app.py, Line 640

```python
# VULNERABLE:
otp = str(random.randint(100000, 999999))  # Not cryptographically secure

# FIX:
import secrets
otp = str(secrets.randbelow(900000) + 100000)
```

---

### FINDING #040 — INFO: Duplicate Route Versioning

**Severity:** Informational

/check_upi and /api/v1/scan/upi both point to same handler. No clear API versioning strategy.

---

### FINDING #041 — INFO: No Content-Type Validation on JSON Endpoints

**Severity:** Informational

request.get_json(silent=True) silently returns None on malformed/missing Content-Type.

---

## 📊 PHASE 4 — DAST SUMMARY

| Test | Endpoint | Finding |
|---|---|---|
| Unauthenticated API Call | POST /check_upi | 200 OK — no auth |
| Unauthenticated File Upload | POST /scan_qr | Accepts files — no auth |
| Admin Panel Access | GET /admin | Requires session + admin |
| Blacklist Deletion (No Auth) | POST /delete_blacklist/1 | 302 — no auth check |
| IDOR PDF Report | GET /download_pdf_report/1 | Downloads any user's report |
| User Enumeration Login | POST /login wrong email | "User not found" |
| User Enumeration Forgot | POST /forgot wrong email | "Email not found" |
| OTP Brute Force | POST /verify_otp | No rate limiting |
| SQL Wildcards | POST /check_url {url:"%"} | Matches all blacklist entries |
| CORS Wildcard | POST /extension/check_url | Access-Control-Allow-Origin: * |

---

## 📦 PHASE 5 — DEPENDENCY VULNERABILITY ANALYSIS

| Package | Known CVEs / Notes |
|---|---|
| Flask >=3.0.0 | No critical CVEs in 3.x |
| Werkzeug (transitive) | CVE-2023-46136 (DoS) if <3.0.1 |
| bcrypt | Secure; no critical CVEs |
| opencv-python-headless | CVE-2023-4863 in some builds (libwebp) |
| Pillow | CVE-2023-44271 if <10.0.1 |
| scikit-learn/joblib | Pickle deserialization risk |
| reportlab | NOT in requirements.txt — missing |
| psycopg2-binary | Generally secure |
| requests | No critical CVEs |

**Scan Command:**
```bash
pip install safety
safety check -r requirements.txt
```

---

## 🔧 PHASE 6 — REMEDIATION PRIORITY MATRIX

| Priority | Finding | Title | Effort |
|---|---|---|---|
| P0 - Fix Now | #006 | Delete Blacklist — No Auth | 5 min |
| P0 - Fix Now | #001 | Hardcoded Secret Key | 10 min |
| P0 - Fix Now | #010 | Password Reset Auth Bypass | 30 min |
| P0 - Fix Now | #002 | Hardcoded Admin Email | 15 min |
| P1 - This Week | #003 | Missing Auth on Scan APIs | 2 hours |
| P1 - This Week | #004 | Unauthenticated File Upload | 1 hour |
| P1 - This Week | #005 | IDOR PDF Report | 30 min |
| P1 - This Week | #011 | History Exposes All Users | 30 min |
| P1 - This Week | #012 | Export CSV All Users | 15 min |
| P1 - This Week | #014 | Debug Mode in Production | 10 min |
| P2 - This Month | #007 | In-Memory OTP Storage | 4 hours |
| P2 - This Month | #008 | No Rate Limiting | 2 hours |
| P2 - This Month | #009 | CORS Wildcard | 1 hour |
| P2 - This Month | #017 | No CSRF Protection | 3 hours |
| P2 - This Month | #020 | Missing Security Headers | 30 min |
| P2 - This Month | #023 | No Session Timeout | 30 min |
| P3 - Backlog | #015 | User Enumeration | 1 hour |
| P3 - Backlog | #016 | Sensitive Data in Logs | 1 hour |
| P3 - Backlog | #025 | No Password Complexity | 1 hour |
| P3 - Backlog | #039 | Weak OTP PRNG | 15 min |

---

## 🏗️ PHASE 7 — ARCHITECTURAL RECOMMENDATIONS

### 1. Authentication Decorator
```python
from functools import wraps
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user' not in session:
            return jsonify({"error": "Authentication required"}), 401
        return f(*args, **kwargs)
    return decorated
```

### 2. Role-Based Access Control
```sql
ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'user';
-- Use role='admin' instead of hardcoded email comparison
```

### 3. Security Headers Middleware
```python
@app.after_request
def add_security_headers(response):
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['Referrer-Policy'] = 'no-referrer'
    return response
```

### 4. Session Security
```python
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=8)
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### 5. OTP with Secrets Module
```python
import secrets
otp = str(secrets.randbelow(900000) + 100000)
```

---

## 📋 COMPLIANCE MAPPING

| Standard | Relevant Findings | Status |
|---|---|---|
| OWASP Top 10 2021 | A01, A02, A03, A05, A07, A08, A09 | Multiple violations |
| CWE Top 25 | CWE-89, CWE-79, CWE-306, CWE-798, CWE-352 | Multiple violations |
| DPDP Act 2023 (India) | #011, #012, #013 — user data cross-exposure | Non-compliant |
| NIST SP 800-63B | #008, #023, #025 — authentication | Partial compliance |
| PCI DSS | #001, #007, #008 | Not compliant |

---

*Scam Shield AI Security Assessment — August 2026*  
*41 findings across 7 severity levels — Overall Risk: CRITICAL*
