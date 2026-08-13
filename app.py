import email
import jwt
import datetime
import warnings
warnings.filterwarnings("ignore")
from functools import wraps


from flask import Flask, render_template, request, redirect, jsonify, session
from flask_cors import CORS
import psycopg2
import bcrypt
import re
import random
import resend
import smtplib
import os
from dotenv import load_dotenv
load_dotenv()

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time
import joblib
import pandas as pd

import cv2
import numpy as np
from PIL import Image
import urllib.parse
from io import BytesIO
import requests
import base64

app = Flask(__name__)
# Restrict CORS to specific origins if known, or at least common web use cases.
# Native apps don't use CORS.
CORS(app)
app.secret_key = os.getenv("SECRET_KEY", os.urandom(24).hex())
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", app.secret_key)

# Flask Session Configuration for Android WebView Persistence
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    SESSION_COOKIE_SECURE=False,  # Set to False for local Wi-Fi HTTP
    PERMANENT_SESSION_LIFETIME=604800 # 7 days persistence
)

ADMIN_EMAIL = os.getenv("ADMIN_EMAIL", "nandakumarreddy63@gmail.com")

# ---------------- AUTH HELPERS ----------------

def create_token(user_id):
    payload = {
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7),
        'iat': datetime.datetime.utcnow(),
        'sub': user_id
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm='HS256')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(" ")[1]

        if token:
            try:
                data = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
                current_user_id = data['sub']
                if cursor is not None:
                    cursor.execute("SELECT id, email FROM users WHERE id=%s", (current_user_id,))
                    row = cursor.fetchone()
                    if not row:
                        return jsonify({"status": "error", "message": "User not found!"}), 401
                    request.user_id = row[0]
                    request.user_email = row[1]
                    return f(*args, **kwargs)
                else:
                    return jsonify({"status": "error", "message": "Database connection unavailable"}), 503
            except jwt.ExpiredSignatureError:
                return jsonify({"status": "error", "message": "Token has expired!"}), 401
            except jwt.InvalidTokenError:
                return jsonify({"status": "error", "message": "Invalid token!"}), 401
            except Exception as e:
                return jsonify({"status": "error", "message": str(e)}), 401

        # Fallback for web sessions when token is absent
        if 'user' in session and cursor is not None:
            try:
                cursor.execute("SELECT id, email FROM users WHERE email=%s", (session['user'],))
                row = cursor.fetchone()
                if row:
                    request.user_id = row[0]
                    request.user_email = row[1]
                    return f(*args, **kwargs)
            except Exception:
                pass

        return jsonify({"status": "error", "message": "Authentication required. Bearer token missing or invalid."}), 401
    return decorated


# ---------------- DATABASE ----------------

import os
import sqlite3

class DBCursorWrapper:
    def __init__(self, db_wrapper):
        self.db_wrapper = db_wrapper
        self.last_cursor = None

    def execute(self, query, params=None):
        if not self.db_wrapper.conn:
            raise Exception("Database is not connected")
        
        cur = self.db_wrapper.conn.cursor()
        if self.db_wrapper.db_type == "sqlite":
            query = query.replace("%s", "?")
        
        if params is not None:
            cur.execute(query, params)
        else:
            cur.execute(query)
        self.last_cursor = cur
        return cur

    def fetchone(self):
        if self.last_cursor:
            return self.last_cursor.fetchone()
        return None

    def fetchall(self):
        if self.last_cursor:
            return self.last_cursor.fetchall()
        return []

class DBWrapper:
    def __init__(self):
        self.conn = None
        self.db_type = None
        self._cursor_wrapper = None
        self.connect()

    def connect(self):
        db_url = os.getenv("DATABASE_URL")
        db_host = os.getenv("DB_HOST")
        db_name = os.getenv("DB_NAME")
        require_postgres = os.getenv("REQUIRE_POSTGRES", "false").lower() == "true"

        if db_url or (db_host and db_name):
            try:
                import psycopg2
                if db_url:
                    if db_url.startswith("postgres://"):
                        db_url = db_url.replace("postgres://", "postgresql://", 1)
                    self.conn = psycopg2.connect(db_url)
                else:
                    self.conn = psycopg2.connect(
                        host=db_host,
                        port=os.getenv("DB_PORT", "5432"),
                        database=db_name,
                        user=os.getenv("DB_USER"),
                        password=os.getenv("DB_PASSWORD")
                    )
                self.db_type = "postgres"
                print("[OK] PostgreSQL Connected Successfully")
                self._init_tables()
                return
            except Exception as e:
                print(f"[CRITICAL] PostgreSQL Connection Error: {str(e)}")
                if require_postgres:
                    print("[CRITICAL] PostgreSQL Required. Halting execution.")
                    raise RuntimeError(f"PostgreSQL Connection Error: {e}")
                print("[WARN] Falling back to SQLite database...")

        if require_postgres:
            print("[CRITICAL] PostgreSQL Database Configuration Missing. Halting execution.")
            raise RuntimeError("DATABASE_URL or DB_HOST/DB_NAME is required when REQUIRE_POSTGRES is true.")

        try:
            db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "database.db")
            self.conn = sqlite3.connect(db_path, check_same_thread=False)
            self.db_type = "sqlite"
            print(f"[OK] SQLite Connected Successfully ({db_path})")
            self._init_tables()
        except Exception as e:
            print("[ERROR] Database Connection Error:", str(e))
            self.conn = None
            self.db_type = None

    def _init_tables(self):
        if not self.conn:
            return
        
        cur = self.conn.cursor()
        pk_type = "INTEGER PRIMARY KEY AUTOINCREMENT" if self.db_type == "sqlite" else "SERIAL PRIMARY KEY"

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS users (
            id {pk_type},
            name VARCHAR(255),
            email VARCHAR(255) UNIQUE,
            password TEXT
        )
        """)

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS blacklist (
            id {pk_type},
            data TEXT,
            type VARCHAR(50),
            reason TEXT
        )
        """)

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS scans (
            id {pk_type},
            user_id INTEGER,
            type VARCHAR(50),
            input_data TEXT,
            score INTEGER,
            result VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS community_reports (
            id {pk_type},
            user_id INTEGER,
            type VARCHAR(50),
            input_data TEXT,
            reason TEXT,
            status VARCHAR(50) DEFAULT 'Pending',
            proof_data TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)

        cur.execute(f"""
        CREATE TABLE IF NOT EXISTS otp_verifications (
            id {pk_type},
            email VARCHAR(255),
            purpose VARCHAR(50),
            otp_hash TEXT,
            expires_at TIMESTAMP,
            attempts INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            verified BOOLEAN DEFAULT FALSE,
            payload_data TEXT
        )
        """)

        try:
            cur.execute("ALTER TABLE community_reports ADD COLUMN proof_data TEXT")
        except Exception:
            pass

        self.conn.commit()
        print("[OK] Database Tables Verified")

    def commit(self):
        if self.conn:
            self.conn.commit()

    def cursor(self):
        if self.conn and not self._cursor_wrapper:
            self._cursor_wrapper = DBCursorWrapper(self)
        return self._cursor_wrapper

# Global database instances
db = DBWrapper()
cursor = db.cursor() if db.conn else None
# ---------------- LOAD MODELS ----------------
try:
    sms_model = joblib.load("sms_model.pkl")
    sms_vectorizer = joblib.load("sms_vectorizer.pkl")
except:
    sms_model = None
    sms_vectorizer = None

try:
    url_model = joblib.load("url_model.pkl")
except:
    url_model = None

try:
    upi_model = joblib.load("upi_model.pkl")
    upi_vectorizer = joblib.load("upi_vectorizer.pkl")
except:
    upi_model = None
    upi_vectorizer = None

# ---------------- OTP PERSISTENCE (DB-BACKED) ----------------
import json

def save_db_otp(email, purpose, otp_code, payload_data=None):
    if cursor is None:
        return False
    otp_hash = bcrypt.hashpw(otp_code.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=10)
    try:
        payload_str = json.dumps(payload_data) if payload_data is not None else None
        cursor.execute(
            "INSERT INTO otp_verifications (email, purpose, otp_hash, expires_at, payload_data) VALUES (%s, %s, %s, %s, %s)",
            (email, purpose, otp_hash, expires_at, payload_str)
        )
        db.commit()
        return True
    except Exception as e:
        print(f"[ERROR] save_db_otp failed: {e}")
        return False

def verify_db_otp(email, purpose, otp_code):
    if cursor is None:
        return False, "Database connection unavailable", None

    now = datetime.datetime.utcnow()
    try:
        cursor.execute(
            "SELECT id, otp_hash, expires_at, attempts, payload_data FROM otp_verifications WHERE email=%s AND purpose=%s AND verified=False ORDER BY id DESC LIMIT 1",
            (email, purpose)
        )
        row = cursor.fetchone()
        if not row:
            return False, "OTP session expired or not found. Please request a new OTP.", None

        otp_id, stored_hash, expires_at, attempts, payload_json = row

        if attempts is not None and attempts >= 5:
            return False, "Too many incorrect OTP attempts. Please request a new OTP.", None

        if isinstance(expires_at, str):
            try:
                expires_at = datetime.datetime.fromisoformat(expires_at)
            except Exception:
                pass

        if expires_at and now > expires_at:
            return False, "OTP has expired. Please request a new OTP.", None

        if isinstance(stored_hash, str):
            stored_hash = stored_hash.encode('utf-8')
        elif isinstance(stored_hash, memoryview):
            stored_hash = stored_hash.tobytes()

        if bcrypt.checkpw(otp_code.encode('utf-8'), stored_hash):
            cursor.execute("UPDATE otp_verifications SET verified=True WHERE id=%s", (otp_id,))
            db.commit()
            payload = json.loads(payload_json) if payload_json else None
            return True, "OTP verified successfully", payload
        else:
            cursor.execute("UPDATE otp_verifications SET attempts = attempts + 1 WHERE id=%s", (otp_id,))
            db.commit()
            return False, "Invalid 6-digit OTP code. Please try again.", None
    except Exception as e:
        print(f"[ERROR] verify_db_otp failed: {e}")
        return False, str(e), None


# ---------------- HELPER ----------------
def get_result(score):
    if score <= 3:
        return "Safe"
    elif score <= 7:
        return "Warning"
    else:
        return "Dangerous"

def get_confidence_and_advice(score):
    if score <= 3:
        confidence = max(88, 100 - score * 4)
        advice = "Low risk detected. Always verify recipient details before finalizing transactions."
    elif score <= 7:
        confidence = min(92, 55 + score * 5)
        advice = "Medium risk detected! Verify identity or link domain authenticity before entering credentials."
    else:
        confidence = min(99, 75 + score * 2)
        advice = "CRITICAL THREAT: Do NOT enter UPI PIN or click link. Report immediately to National Cyber Helpline 1930."
    return confidence, advice

def check_blacklist_or_community(input_data, input_type):
    score_bump = 0
    matches = []
    if cursor is not None and input_data:
        clean_data = input_data.lower().strip()
        clean_type = input_type.lower().strip()
        if clean_type in ['website', 'link']:
            clean_type = 'url'
        try:
            # Check Exact or Substring Blacklist Matches
            cursor.execute("""
                SELECT reason, type, data FROM blacklist 
                WHERE LOWER(data) = %s 
                OR (%s = 'sms' AND LOWER(%s) LIKE '%' || LOWER(data) || '%')
                OR (%s = 'url' AND (LOWER(%s) LIKE '%' || LOWER(data) || '%' OR LOWER(data) LIKE '%' || LOWER(%s) || '%'))
                OR (%s = 'phone' AND (LOWER(data) = %s OR LOWER(%s) LIKE '%' || LOWER(data) || '%'))
                OR (%s = 'upi' AND LOWER(data) = %s)
            """, (clean_data, clean_type, clean_data, clean_type, clean_data, clean_data, clean_type, clean_data, clean_data, clean_type, clean_data))
            b_item = cursor.fetchone()
            if b_item:
                score_bump += 8
                matches.append(f"Matched Global Blacklist Record ({b_item[1]}): {b_item[0]}")
            
            # Check Community Reports
            cursor.execute("""
                SELECT reason, status FROM community_reports 
                WHERE LOWER(input_data) = %s 
                OR (%s = 'sms' AND LOWER(%s) LIKE '%' || LOWER(input_data) || '%')
                OR (%s = 'url' AND (LOWER(%s) LIKE '%' || LOWER(input_data) || '%' OR LOWER(input_data) LIKE '%' || LOWER(%s) || '%'))
                OR (%s = 'phone' AND (LOWER(input_data) = %s OR LOWER(%s) LIKE '%' || LOWER(input_data) || '%'))
                OR (%s = 'upi' AND LOWER(input_data) = %s)
            """, (clean_data, clean_type, clean_data, clean_type, clean_data, clean_data, clean_type, clean_data, clean_data, clean_type, clean_data))
            c_item = cursor.fetchone()
            if c_item:
                score_bump += 5
                matches.append(f"Flagged by Community Fraud Reports (Status: {c_item[1]})")
        except Exception as e:
            print("[WARN] Blacklist/Community check exception:", e)
    return score_bump, matches

def get_auth_user_id():
    if hasattr(request, 'user_id'):
        return request.user_id

    if 'user' in session and cursor is not None:
        try:
            cursor.execute(
                "SELECT id FROM users WHERE email=%s",
                (session['user'],)
            )
            row = cursor.fetchone()
            return row[0] if row else None
        except Exception as e:
            print("[WARN] User ID fetch exception:", e)
    return None
def check_virustotal_api(target_url):
    vt_key = os.getenv("VIRUSTOTAL_API_KEY")
    if not vt_key:
        return {"status": "unconfigured", "flagged": False, "details": "VirusTotal API key unconfigured"}
    
    try:
        url_id = base64.urlsafe_b64encode(target_url.encode()).decode().strip("=")
        headers = {"x-apikey": vt_key}
        res = requests.get(f"https://www.virustotal.com/api/v3/urls/{url_id}", headers=headers, timeout=5)
        if res.status_code == 200:
            stats = res.json().get('data', {}).get('attributes', {}).get('last_analysis_stats', {})
            malicious = stats.get('malicious', 0)
            return {"status": "checked", "flagged": malicious > 0, "malicious_count": malicious, "details": f"VirusTotal flagged by {malicious} security vendors"}
    except Exception as e:
        print("[WARN] VirusTotal API exception:", e)
    return {"status": "fallback", "flagged": False, "details": "VirusTotal request fallback"}

def check_safebrowsing_api(target_url):
    sb_key = os.getenv("GOOGLE_SAFE_BROWSING_API_KEY")
    if not sb_key:
        return {"status": "unconfigured", "flagged": False, "details": "Google Safe Browsing API key unconfigured"}
    
    try:
        body = {
            "client": {"clientId": "scam-shield-ai", "clientVersion": "1.0.0"},
            "threatInfo": {
                "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE"],
                "platformTypes": ["ANY_PLATFORM"],
                "threatEntryTypes": ["URL"],
                "threatEntries": [{"url": target_url}]
            }
        }
        res = requests.post(f"https://safebrowsing.googleapis.com/v4/threatMatches:find?key={sb_key}", json=body, timeout=5)
        if res.status_code == 200:
            matches = res.json().get('matches', [])
            return {"status": "checked", "flagged": len(matches) > 0, "details": "Google Safe Browsing flagged phishing/malware site" if matches else "Clean on Google Safe Browsing"}
    except Exception as e:
        print("[WARN] SafeBrowsing API exception:", e)
    return {"status": "fallback", "flagged": False, "details": "Google Safe Browsing fallback"}

def decode_qr_from_image(file_bytes):
    try:
        np_arr = np.frombuffer(file_bytes, np.uint8)
        img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if img is not None:
            detector = cv2.QRCodeDetector()
            val, pts, qr_code = detector.detectAndDecode(img)
            if val:
                return val
    except Exception as e:
        print("[WARN] QR Decode exception:", e)
    return None

def parse_qr_payload(payload):
    payload = payload.strip()
    if payload.startswith("upi://pay"):
        parsed = urllib.parse.urlparse(payload)
        params = urllib.parse.parse_qs(parsed.query)
        vpa = params.get('pa', [''])[0]
        name = params.get('pn', [''])[0]
        amount = params.get('am', [''])[0]
        return {
            "type": "UPI_QR",
            "vpa": vpa,
            "name": name,
            "amount": amount,
            "raw": payload
        }
    return {
        "type": "URL_OR_TEXT",
        "raw": payload
    }

# ---------------- PURE BUSINESS LOGIC ANALYSIS HELPERS ----------------

def analyze_upi(upi, user_id=None):
    if cursor is None:
        return {"score": 0, "result": "Error", "reason": "Database connection failed", "confidence": 0, "advice": "System offline."}

    clean_upi = upi.lower().strip()
    score = 0
    reasons = []

    bump, matches = check_blacklist_or_community(clean_upi, "UPI")
    score += bump
    reasons.extend(matches)

    if not re.match(r'^[\w.-]+@[\w.-]+$', clean_upi):
        score += 5
        reasons.append("Invalid UPI handle format")

    if any(x in clean_upi for x in ["win", "free", "cash", "offer", "bonus"]):
        score += 5
        reasons.append("Contains suspicious scam keywords")

    if upi_model and upi_vectorizer:
        try:
            vec = upi_vectorizer.transform([clean_upi])
            pred = upi_model.predict(vec)[0]
            if pred == 1:
                score += 3
                reasons.append("Flagged by Machine Learning Model")
        except Exception as e:
            print("UPI Model Error:", e)

    result = get_result(score)
    confidence, advice = get_confidence_and_advice(score)

    if cursor is not None:
        try:
            cursor.execute(
                "INSERT INTO scans (user_id, type, input_data, score, result) VALUES (%s, %s, %s, %s, %s)",
                (user_id, "UPI", clean_upi, score, result)
            )
            db.commit()
        except Exception as e:
            print("Scan Save Error:", e)

    return {
        "status": "success",
        "score": score,
        "result": result,
        "reason": ", ".join(reasons) if reasons else "Handle format looks normal with no threat matches.",
        "confidence": confidence,
        "advice": advice
    }

def analyze_phone(phone, user_id=None):
    if cursor is None:
        return {"score": 0, "result": "Error", "reason": "Database connection failed", "confidence": 0, "advice": "System offline."}

    raw_phone = phone.strip()
    clean_phone = re.sub(r'\D', '', raw_phone)
    score = 0
    reasons = []

    bump, matches = check_blacklist_or_community(clean_phone, "PHONE")
    score += bump
    reasons.extend(matches)

    if len(clean_phone) != 10 and len(clean_phone) != 12:
        score += 3
        reasons.append("Non-standard phone number digit length")

    result = get_result(score)
    confidence, advice = get_confidence_and_advice(score)

    if cursor is not None:
        try:
            cursor.execute(
                "INSERT INTO scans (user_id, type, input_data, score, result) VALUES (%s, %s, %s, %s, %s)",
                (user_id, "PHONE", raw_phone, score, result)
            )
            db.commit()
        except Exception as e:
            print("Scan Save Error:", e)

    return {
        "status": "success",
        "score": score,
        "result": result,
        "reason": ", ".join(reasons) if reasons else "No cybercrime reports or blacklists matched this phone number.",
        "confidence": confidence,
        "advice": advice
    }

def analyze_sms(sms, user_id=None):
    if cursor is None:
        return {"score": 0, "result": "Error", "reason": "Database connection failed", "confidence": 0, "advice": "System offline."}

    clean_sms = sms.lower().strip()
    score = 0
    reasons = []

    bump, matches = check_blacklist_or_community(clean_sms, "SMS")
    score += bump
    reasons.extend(matches)

    if re.search(r'\d{4,}', clean_sms):
        reasons.append("Contains large numeric sequences (amount/code)")

    if any(x in clean_sms for x in ["rs", "₹", "money", "cash"]):
        score += 3
        reasons.append("Money & financial reward terms")

    if any(x in clean_sms for x in ["win", "free", "claim", "urgent"]):
        score += 3
        reasons.append("Urgency & scam offer keywords")

    if any(x in clean_sms for x in ["withdraw", "transfer", "credited"]):
        score += 3
        reasons.append("Transaction triggers")

    if "http" in clean_sms:
        score += 4
        reasons.append("Contains external web link")

    if sms_model and sms_vectorizer:
        try:
            vec = sms_vectorizer.transform([clean_sms])
            pred = sms_model.predict(vec)[0]
            if pred == 1:
                score += 3
                reasons.append("Flagged by TF-IDF Scikit-Learn Model")
        except Exception as e:
            print("SMS Model Error:", e)

    result = get_result(score)
    confidence, advice = get_confidence_and_advice(score)

    if cursor is not None:
        try:
            cursor.execute(
                "INSERT INTO scans (user_id, type, input_data, score, result) VALUES (%s, %s, %s, %s, %s)",
                (user_id, "SMS", sms, score, result)
            )
            db.commit()
        except Exception as e:
            print("Scan Save Error:", e)

    return {
        "status": "success",
        "score": score,
        "result": result,
        "reason": ", ".join(reasons) if reasons else "Message text format appears normal.",
        "confidence": confidence,
        "advice": advice
    }

def analyze_url(url, user_id=None):
    if cursor is None:
        return {"score": 0, "result": "Error", "reason": "Database connection failed", "confidence": 0, "advice": "System offline."}

    clean_url = url.lower().strip()
    score = 0
    reasons = []

    bump, matches = check_blacklist_or_community(clean_url, "URL")
    score += bump
    reasons.extend(matches)

    if any(x in clean_url for x in ["login", "verify", "bank", "secure", "offer", "win"]):
        score += 3
        reasons.append("Suspicious credential/banking keywords")

    if "bit.ly" in clean_url or "tinyurl" in clean_url:
        score += 5
        reasons.append("Shortened URL service used (masks real destination)")

    if clean_url.count('.') > 3:
        score += 2
        reasons.append("Excessive domain sub-levels (multi-dot domain)")

    if re.search(r'\d+\.\d+\.\d+\.\d+', clean_url):
        score += 5
        reasons.append("Raw IP address used instead of domain name")

    if len(clean_url) > 75:
        score += 2
        reasons.append("Unusually long URL length")

    if not clean_url.startswith("https"):
        score += 2
        reasons.append("Unencrypted connection (HTTP without SSL)")

    if "@" in clean_url:
        score += 4
        reasons.append("Contains @ symbol (embedded credentials trick)")

    if url_model:
        try:
            pred = url_model.predict([clean_url])[0]
            if pred == 1:
                score += 3
                reasons.append("Flagged by Machine Learning Phishing Classifier")
        except Exception as e:
            print("URL Model Error:", e)

    vt_res = check_virustotal_api(clean_url)
    if vt_res.get('flagged'):
        score += 8
        reasons.append(vt_res.get('details', 'Flagged by VirusTotal vendors'))

    sb_res = check_safebrowsing_api(clean_url)
    if sb_res.get('flagged'):
        score += 8
        reasons.append(sb_res.get('details', 'Flagged by Google Safe Browsing'))

    result = get_result(score)
    confidence, advice = get_confidence_and_advice(score)

    if cursor is not None:
        try:
            cursor.execute(
                "INSERT INTO scans (user_id, type, input_data, score, result) VALUES (%s, %s, %s, %s, %s)",
                (user_id, "URL", url, score, result)
            )
            db.commit()
        except Exception as e:
            print("Scan Save Error:", e)

    return {
        "status": "success",
        "score": score,
        "result": result,
        "reason": ", ".join(reasons) if reasons else "Domain format appears safe.",
        "confidence": confidence,
        "advice": advice,
        "virustotal": vt_res,
        "safebrowsing": sb_res
    }

# ---------------- ADMIN API ----------------

def is_request_admin():
    email = getattr(request, 'user_email', None)
    if not email and 'user' in session:
        email = session['user']
    return email == ADMIN_EMAIL

@app.route('/api/v1/admin/blacklist', methods=['GET', 'POST'])
@token_required
def api_admin_blacklist():
    if not is_request_admin():
        return jsonify({"status": "error", "message": "Admin privileges required"}), 403

    if request.method == 'POST':
        data_json = request.get_json(silent=True) or {}
        data_val = data_json.get('data', '').strip()
        type_val = data_json.get('type', '').strip()
        reason_val = data_json.get('reason', '').strip()

        if not data_val or not type_val:
            return jsonify({"status": "error", "message": "Missing data or type"}), 400

        cursor.execute(
            "INSERT INTO blacklist (data, type, reason) VALUES (%s, %s, %s)",
            (data_val, type_val, reason_val)
        )
        db.commit()
        return jsonify({"status": "success", "message": "Blacklist record created successfully"}), 201

    cursor.execute("SELECT id, data, type, reason FROM blacklist ORDER BY id DESC")
    rows = cursor.fetchall()
    items = [{"id": r[0], "data": r[1], "type": r[2], "reason": r[3]} for r in rows]
    return jsonify(items)

@app.route('/api/v1/admin/blacklist/<int:id>', methods=['DELETE'])
@token_required
def api_admin_delete_blacklist(id):
    if not is_request_admin():
        return jsonify({"status": "error", "message": "Admin privileges required"}), 403

    cursor.execute("DELETE FROM blacklist WHERE id=%s", (id,))
    db.commit()
    return jsonify({"status": "success", "message": "Blacklist item deleted successfully"})

@app.route('/api/v1/admin/reports', methods=['GET'])
@token_required
def api_admin_reports():
    if not is_request_admin():
        return jsonify({"status": "error", "message": "Admin privileges required"}), 403

    cursor.execute("SELECT id, type, input_data, reason, status, created_at, proof_data FROM community_reports ORDER BY id DESC")
    rows = cursor.fetchall()
    reports = [{"id": r[0], "type": r[1], "input_data": r[2], "reason": r[3], "status": r[4], "created_at": str(r[5]), "proof_data": r[6]} for r in rows]
    return jsonify(reports)

@app.route('/api/v1/admin/reports/<int:id>/approve', methods=['POST'])
@token_required
def api_admin_approve_report(id):
    if not is_request_admin():
        return jsonify({"status": "error", "message": "Admin privileges required"}), 403

    cursor.execute("SELECT type, input_data, reason FROM community_reports WHERE id=%s", (id,))
    rep = cursor.fetchone()
    if rep:
        type_, data_val, reason_val = rep[0], rep[1], rep[2]
        cursor.execute("INSERT INTO blacklist (data, type, reason) VALUES (%s, %s, %s)", (data_val, type_, f"Community Approved: {reason_val}"))
        cursor.execute("UPDATE community_reports SET status='Approved' WHERE id=%s", (id,))
        db.commit()
        return jsonify({"status": "success", "message": "Report approved and added to blacklist"})
    return jsonify({"status": "error", "message": "Report not found"}), 404

@app.route('/api/v1/admin/reports/<int:id>/reject', methods=['POST'])
@token_required
def api_admin_reject_report(id):
    if not is_request_admin():
        return jsonify({"status": "error", "message": "Admin privileges required"}), 403

    cursor.execute("UPDATE community_reports SET status='Rejected' WHERE id=%s", (id,))
    db.commit()
    return jsonify({"status": "success", "message": "Report rejected"})

# ---------------- HOME ----------------
@app.route('/')
def home():
    return redirect('/login')

@app.route('/api/v1/health', methods=['GET'])
def api_health():
    user_count = 0
    if cursor:
        try:
            cursor.execute("SELECT COUNT(*) FROM users")
            user_count = cursor.fetchone()[0]
        except:
            pass

    return jsonify({
        "status": "ok",
        "service": "UPI Scam Analyzer API",
        "database": db.db_type if db.conn else "disconnected",
        "users_in_db": user_count,
        "environment": "production" if os.getenv("RENDER") else "development"
    }), 200

@app.route('/api/v1/debug/otps', methods=['GET'])
def api_debug_otps():
    if not app.debug:
        return jsonify({"error": "Debug mode disabled"}), 403
    return jsonify({
        "registration_otps": {k: v[0] for k, v in otp_storage.items()},
        "reset_otps": {k: v[0] for k, v in reset_otp_storage.items()}
    })

# ---------------- EMAIL HELPER ----------------
def generate_otp_email_html(otp_code, action_name="Account Registration"):
    return f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Security Code</title>
</head>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; color: #333333;">
    <div style="max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 16px; padding: 32px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e2e8f0;">
        <div style="text-align: center; padding-bottom: 20px; border-bottom: 1px solid #f1f5f9;">
            <div style="display: inline-block; background: #dcfce7; color: #15803d; font-size: 11px; font-weight: 700; padding: 6px 14px; border-radius: 20px; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;">
                🛡️ Security Verification
            </div>
            <h1 style="font-size: 22px; font-weight: 800; color: #0f172a; margin: 8px 0 4px 0;">Scam Shield AI</h1>
            <p style="color: #64748b; font-size: 13px; margin: 0;">Verification code for {action_name}</p>
        </div>
        
        <div style="background: #f8fafc; border: 2px dashed #cbd5e1; border-radius: 12px; text-align: center; padding: 24px 16px; margin: 24px 0;">
            <div style="font-size: 11px; color: #64748b; margin-bottom: 8px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase;">Your One-Time Password (OTP)</div>
            <div style="font-family: 'Courier New', monospace; font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #166534;">{otp_code}</div>
            <div style="font-size: 11px; color: #94a3b8; margin-top: 8px;">Valid for 10 minutes</div>
        </div>

        <div style="background: #fef2f2; border: 1px solid #fecaca; border-radius: 10px; padding: 12px 16px; color: #991b1b; font-size: 12px; line-height: 1.5; margin-bottom: 24px;">
            🔒 <strong>Security Warning:</strong> Never share this OTP with anyone. Scam Shield AI staff will never ask for your verification code.
        </div>

        <div style="text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #f1f5f9; padding-top: 16px;">
            If you did not request this OTP, please ignore this email.<br>
            &copy; Scam Shield AI - UPI & Cyber Scam Detection Engine
        </div>
    </div>
</body>
</html>"""


def send_email(to_email, subject, body, html_content=None):
    """
    Sends an email using Brevo API (Sends to ANY recipient address free over HTTPS), Resend API, or SMTP.
    Returns True if sent successfully, False otherwise.
    """
    # 1. Try Brevo API (Sendinblue) - Sends to ANY recipient email address over HTTPS without domain verification
    brevo_key = os.getenv("BREVO_API_KEY")
    if brevo_key:
        clean_brevo_key = brevo_key.strip().strip("'").strip('"')
        if clean_brevo_key:
            try:
                url = "https://api.brevo.com/v3/smtp/email"
                headers = {
                    "api-key": clean_brevo_key,
                    "content-type": "application/json",
                    "accept": "application/json"
                }
                sender = os.getenv("BREVO_SENDER_EMAIL", "nandakumarreddy63@gmail.com")
                payload = {
                    "sender": {"name": "Scam Shield AI", "email": sender},
                    "to": [{"email": to_email}],
                    "subject": subject,
                    "textContent": body
                }
                if html_content:
                    payload["htmlContent"] = html_content

                resp = requests.post(url, json=payload, headers=headers, timeout=10)
                if resp.status_code in [200, 201, 202]:
                    print(f"[OK] OTP Email sent via Brevo API to {to_email}", flush=True)
                    return True
                else:
                    print(f"[WARN] Brevo Email Error ({resp.status_code}): {resp.text}", flush=True)
            except Exception as e:
                print(f"[WARN] Brevo Email Exception: {str(e)}", flush=True)

    # 2. Try SendGrid API
    sendgrid_key = os.getenv("SENDGRID_API_KEY")
    if sendgrid_key:
        clean_sg_key = sendgrid_key.strip().strip("'").strip('"')
        if clean_sg_key:
            try:
                url = "https://api.sendgrid.com/v3/mail/send"
                headers = {
                    "Authorization": f"Bearer {clean_sg_key}",
                    "Content-Type": "application/json"
                }
                sender = os.getenv("SENDER_EMAIL", "nandareddylinkdin@gmail.com")
                payload = {
                    "personalizations": [{"to": [{"email": to_email}]}],
                    "from": {"email": sender, "name": "Scam Shield AI"},
                    "subject": subject,
                    "content": [{"type": "text/html" if html_content else "text/plain", "value": html_content or body}]
                }
                resp = requests.post(url, json=payload, headers=headers, timeout=10)
                if resp.status_code in [200, 201, 202]:
                    print(f"[OK] OTP Email sent via SendGrid API to {to_email}", flush=True)
                    return True
                else:
                    print(f"[WARN] SendGrid Email Error ({resp.status_code}): {resp.text}", flush=True)
            except Exception as e:
                print(f"[WARN] SendGrid Email Exception: {str(e)}", flush=True)

    # 3. Try Resend API
    api_key = os.getenv("RESEND_API_KEY")
    if api_key:
        clean_api_key = api_key.strip().strip("'").strip('"')
        if clean_api_key and not clean_api_key.startswith("e_your_api_key"):
            try:
                resend.api_key = clean_api_key
                payload = {
                    "from": "Scam Shield AI <onboarding@resend.dev>",
                    "to": [to_email],
                    "subject": subject,
                    "text": body
                }
                if html_content:
                    payload["html"] = html_content

                resend.Emails.send(payload)
                print(f"[OK] OTP Email sent via Resend API to {to_email}", flush=True)
                return True
            except Exception as e:
                print(f"[WARN] Resend Email Error: {str(e)}", flush=True)

    # 2. Try SMTP fallback
    smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    sender_email = os.getenv("SENDER_EMAIL") or os.getenv("SMTP_EMAIL")
    sender_password = os.getenv("SENDER_PASSWORD") or os.getenv("SMTP_PASSWORD")

    if sender_email and sender_password:
        # Try SSL 465 first, then TLS 587
        for use_ssl in [True, False]:
            try:
                msg = MIMEMultipart("alternative")
                msg["Subject"] = subject
                msg["From"] = f"Scam Shield AI <{sender_email}>"
                msg["To"] = to_email
                msg.attach(MIMEText(body, "plain"))
                if html_content:
                    msg.attach(MIMEText(html_content, "html"))

                if use_ssl:
                    with smtplib.SMTP_SSL(smtp_server, 465, timeout=5) as server:
                        server.login(sender_email, sender_password)
                        server.sendmail(sender_email, to_email, msg.as_string())
                else:
                    with smtplib.SMTP(smtp_server, smtp_port, timeout=5) as server:
                        server.starttls()
                        server.login(sender_email, sender_password)
                        server.sendmail(sender_email, to_email, msg.as_string())

                print(f"[OK] OTP Email sent via SMTP to {to_email}", flush=True)
                return True
            except Exception as e:
                port_desc = "SMTP_SSL Port 465" if use_ssl else f"SMTP Port {smtp_port}"
                print(f"[WARN] {port_desc} Error: {str(e)}", flush=True)

    print("[WARN] No email credentials or all options failed. Email NOT delivered.", flush=True)
    return False

# ---------------- MOBILE AUTH API ----------------

@app.route('/api/v1/auth/register', methods=['POST'])
def api_register():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection failed"}), 503

    data = request.get_json(silent=True) or {}
    name = data.get('name', '').strip()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')

    if not all([name, email, password]):
        return jsonify({"status": "error", "message": "Name, email, and password are required"}), 400

    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    if cursor.fetchone():
        return jsonify({"status": "error", "message": "Email already registered"}), 409

    otp = str(random.randint(100000, 999999))
    payload = {"name": name, "password": password}
    if not save_db_otp(email, 'registration', otp, payload):
        return jsonify({"status": "error", "message": "Failed to create registration session"}), 500

    html = generate_otp_email_html(otp, action_name="Account Registration")
    sent = send_email(email, "Scam Shield AI - Registration OTP", f"Your OTP is: {otp}", html_content=html)

    if not sent:
        return jsonify({"status": "error", "message": "Unable to send OTP. Please try again later."}), 503

    return jsonify({
        "status": "success",
        "message": "OTP sent to email. Please verify to complete registration.",
        "email": email
    }), 200

@app.route('/api/v1/auth/verify-registration', methods=['POST'])
def api_verify_registration():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection failed"}), 503

    data = request.get_json(silent=True) or {}
    email = data.get('email', '').strip().lower()
    user_otp = data.get('otp', '').strip()

    if not email or not user_otp:
        return jsonify({"status": "error", "message": "Email and OTP are required"}), 400

    success, msg, payload = verify_db_otp(email, 'registration', user_otp)
    if not success or not payload:
        return jsonify({"status": "error", "message": msg}), 400

    name = payload.get('name', '')
    password = payload.get('password', '')

    cursor.execute("SELECT id FROM users WHERE email=%s", (email,))
    existing = cursor.fetchone()
    if existing:
        user_id = existing[0]
    else:
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        try:
            cursor.execute("INSERT INTO users (name, email, password) VALUES (%s, %s, %s)", (name, email, hashed))
            db.commit()
            cursor.execute("SELECT id FROM users WHERE email=%s", (email,))
            row = cursor.fetchone()
            user_id = row[0]
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500

    token = create_token(user_id)
    is_admin = (email == ADMIN_EMAIL)
    return jsonify({
        "status": "success",
        "message": "Account verified and registered successfully!",
        "token": token,
        "user": {
            "id": user_id,
            "name": name,
            "email": email,
            "is_admin": is_admin
        }
    }), 200

@app.route('/api/v1/auth/login', methods=['POST'])
def api_login():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection failed"}), 503

    data = request.get_json(silent=True) or {}
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')

    if not email or not password:
        return jsonify({"status": "error", "message": "Email and password required"}), 400

    cursor.execute("SELECT id, name, email, password FROM users WHERE email=%s", (email,))
    user = cursor.fetchone()

    if not user:
        return jsonify({"status": "error", "message": "Invalid email or password"}), 401

    stored = user[3]
    if isinstance(stored, memoryview):
        stored = stored.tobytes().decode('utf-8')
    if isinstance(stored, str):
        stored = stored.encode('utf-8')

    try:
        if bcrypt.checkpw(password.encode('utf-8'), stored):
            is_admin = (user[2] == ADMIN_EMAIL)
            token = create_token(user[0])
            return jsonify({
                "status": "success",
                "message": "Login successful",
                "token": token,
                "user": {"id": user[0], "name": user[1], "email": user[2], "is_admin": is_admin}
            }), 200
        return jsonify({"status": "error", "message": "Invalid email or password"}), 401
    except Exception as e:
        return jsonify({"status": "error", "message": "Login failed"}), 500

@app.route('/api/v1/auth/logout', methods=['POST'])
@token_required
def api_logout():
    session.clear()
    return jsonify({"status": "success", "message": "Logged out"})

@app.route('/api/v1/auth/me', methods=['GET'])
@token_required
def api_me():
    uid = request.user_id
    cursor.execute("SELECT id, name, email FROM users WHERE id=%s", (uid,))
    user = cursor.fetchone()
    if user:
        return jsonify({
            "status": "success",
            "user": {"id": user[0], "name": user[1], "email": user[2], "is_admin": user[2] == ADMIN_EMAIL}
        })
    return jsonify({"status": "error", "message": "Not authenticated"}), 401

# ---------------- REGISTER ----------------
@app.route('/register', methods=['GET', 'POST'])
# ---------------- REGISTER ----------------
@app.route('/register', methods=['GET', 'POST'])
def register():

    if cursor is None:
        return render_template("register.html", error="Database connection unavailable. Please check system status.")

    if request.method == 'POST':

        name = request.form.get('name', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        confirm = request.form.get('confirm', '')

        if password != confirm:
            return render_template("register.html", error="Passwords do not match. Please ensure both fields are identical.", name=name, email=email)

        cursor.execute(
            "SELECT * FROM users WHERE email=%s",
            (email,)
        )

        existing = cursor.fetchone()

        if existing:
            return render_template("register.html", error="This email address is already registered. Please sign in instead.", name=name, email=email)

        otp = str(random.randint(100000, 999999))
        expiry = time.time() + 600  # 10 minutes TTL

        otp_storage[email] = (otp, name, password, expiry)

        html = generate_otp_email_html(otp, action_name="Account Registration")
        sent = send_email(
            email,
            "UPI Scam Analyzer - Registration OTP",
            f"Your OTP for registration is: {otp}",
            html_content=html
        )
        if not sent:
            print(f"REGISTRATION OTP for {email}: {otp}")

        return render_template(
            "otp.html",
            email=email
        )

    return render_template("register.html")

# ---------------- VERIFY REGISTRATION OTP ----------------
@app.route('/verify_otp', methods=['POST'])
def verify_otp():

    email = request.form.get('email', '')
    user_otp = request.form.get('otp', '')

    if email in otp_storage:

        stored_data = otp_storage[email]
        if len(stored_data) == 4:
            otp, name, password, expiry = stored_data
            if time.time() > expiry:
                otp_storage.pop(email, None)
                return render_template("otp.html", email=email, error="OTP expired. Please register again.")
        else:
            otp, name, password = stored_data

        if user_otp == otp:

            hashed = bcrypt.hashpw(
                password.encode('utf-8'),
                bcrypt.gensalt()
            ).decode('utf-8')

            cursor.execute(
                "INSERT INTO users (name, email, password) VALUES (%s, %s, %s)",
                (name, email, hashed)
            )

            db.commit()

            otp_storage.pop(email, None)

            return render_template("login.html", success="Registration verified successfully! Please sign in with your credentials.", email=email)

    return render_template("otp.html", email=email, error="Invalid 6-digit OTP code. Please check your email and try again.")

# ---------------- VERIFY RESET OTP ----------------
@app.route('/verify_reset_otp', methods=['POST'])
def verify_reset_otp():

    email = request.form.get('email', '')
    otp = request.form.get('otp', '')

    if email in reset_otp_storage:

        stored_data = reset_otp_storage[email]
        if isinstance(stored_data, tuple):
            stored_otp, expiry = stored_data
            if time.time() > expiry:
                reset_otp_storage.pop(email, None)
                return render_template("reset_otp.html", email=email, error="OTP expired. Please request password reset again.")
        else:
            stored_otp = stored_data

        if stored_otp == otp:

            return render_template(
                "reset_password.html",
                email=email
            )

    return render_template("reset_otp.html", email=email, error="Invalid 6-digit OTP code. Please verify the code and try again.")

# ---------------- LOGIN ----------------
@app.route('/login', methods=['GET', 'POST'])
def login():



    if cursor is None:
        return render_template("login.html", error="Database connection unavailable. Please check system status.")

    if request.method == 'POST':

        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')

        cursor.execute(
            "SELECT * FROM users WHERE email=%s",
            (email,)
        )

        user = cursor.fetchone()

        if not user:
            return render_template("login.html", error="Invalid user email or account does not exist.", email=email)

        stored = user[3]

        try:

            # PostgreSQL handling
            if isinstance(stored, memoryview):
                stored = stored.tobytes().decode('utf-8')

            if isinstance(stored, str):
                stored = stored.encode('utf-8')

            if bcrypt.checkpw(
                password.encode('utf-8'),
                stored
            ):
                session.permanent = True
                session['user'] = email

                # Check for mobile parameter from query string or hidden form field
                is_mobile = request.args.get('mobile') == '1' or request.form.get('mobile') == '1'

                # Auto-redirect mobile app users to the mobile dashboard
                if is_mobile:
                    return redirect('/mobile_app')

                return redirect('/dashboard')

            return render_template("login.html", error="Incorrect password. Please verify your password and try again.", email=email)

        except Exception as e:
            print("Login Error:", e)
            return render_template("login.html", error="Password verification format error. Please try again.", email=email)

    return render_template("login.html")

# ---------------- LOGOUT ----------------
@app.route('/logout')
def logout():
    is_mobile = "ScamShieldAndroid" in request.headers.get('User-Agent', '')
    session.clear()
    if is_mobile:
        return redirect('/login?mobile=1')
    return redirect('/login')

# ---------------- FORGOT PASSWORD API ----------------
@app.route('/api/v1/auth/forgot-password', methods=['POST'])
def api_forgot_password():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection failed"}), 500

    data = request.get_json(silent=True) or {}
    email = data.get('email', '').strip().lower()

    if not email:
        return jsonify({"status": "error", "message": "Email is required"}), 400

    cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cursor.fetchone()

    if not user:
        return jsonify({"status": "error", "message": "Email not found"}), 404

    otp = str(random.randint(100000, 999999))
    if not save_db_otp(email, 'password_reset', otp):
        return jsonify({"status": "error", "message": "Failed to create password reset session"}), 500

    html = generate_otp_email_html(otp, action_name="Password Reset")
    sent = send_email(email, "Password Reset OTP", f"Your OTP is: {otp}", html_content=html)

    if not sent:
        return jsonify({"status": "error", "message": "Unable to send OTP. Please try again later."}), 503

    return jsonify({
        "status": "success",
        "message": "Reset OTP sent to your email.",
        "email": email
    }), 200

@app.route('/api/v1/auth/reset-password', methods=['POST'])
def api_reset_password():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection failed"}), 500

    data = request.get_json(silent=True) or {}
    email = data.get('email', '').strip().lower()
    otp = data.get('otp', '').strip()
    new_password = data.get('new_password', '') or data.get('password', '')

    if not all([email, otp, new_password]):
        return jsonify({"status": "error", "message": "Email, OTP, and new password are required"}), 400

    success, msg, _ = verify_db_otp(email, 'password_reset', otp)
    if not success:
        return jsonify({"status": "error", "message": msg}), 400

    hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    try:
        cursor.execute("UPDATE users SET password=%s WHERE email=%s", (hashed, email))
        db.commit()
        return jsonify({"status": "success", "message": "Password updated successfully! You can now login."}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# ---------------- FORGOT PASSWORD ----------------
@app.route('/forgot', methods=['GET', 'POST'])
def forgot():

    if cursor is None:
        return render_template("forgot.html", error="Database connection unavailable. Please try again later.")

    if request.method == 'POST':

        email = request.form.get('email', '').strip().lower()

        cursor.execute(
            "SELECT * FROM users WHERE email=%s",
            (email,)
        )

        user = cursor.fetchone()

        if not user:
            return render_template("forgot.html", error="Email address not found in system records.", email=email)

        otp = str(random.randint(100000, 999999))
        expiry = time.time() + 600  # 10 minutes TTL

        reset_otp_storage[email] = (otp, expiry)

        html = generate_otp_email_html(otp, action_name="Password Reset")
        sent = send_email(
            email,
            "UPI Scam Analyzer - Password Reset OTP",
            f"Your password reset OTP is: {otp}",
            html_content=html
        )

        if not sent:
            print(f"RESET OTP for {email}: {otp}")

        return render_template(
            "reset_otp.html",
            email=email
        )

    return render_template("forgot.html")

# ---------------- UPDATE PASSWORD ----------------
@app.route('/update_password', methods=['POST'])
def update_password():

    if cursor is None:
        return render_template("reset_password.html", error="Database connection unavailable.")

    email = request.form.get('email', '')
    password = request.form.get('password', '')
    confirm = request.form.get('confirm', '')

    if password != confirm:
        return render_template("reset_password.html", email=email, error="Passwords do not match. Please try again.")

    hashed = bcrypt.hashpw(
        password.encode('utf-8'),
        bcrypt.gensalt()
    ).decode('utf-8')

    cursor.execute(
        "UPDATE users SET password=%s WHERE email=%s",
        (hashed, email)
    )

    db.commit()

    reset_otp_storage.pop(email, None)

    return render_template("login.html", success="Password reset successfully! Please sign in with your new password.", email=email)
# ---------------- SCAN HUB ----------------
@app.route('/scan')
def scan_hub():
    if 'user' not in session:
        return redirect('/login')

    # Auto-redirect mobile app users
    user_agent = request.headers.get('User-Agent', '').lower()
    if "scamshieldandroid" in user_agent:
        return redirect('/mobile_app?screen=scan')

    return render_template("scan.html", user=session['user'])

# ---------------- DASHBOARD ----------------
@app.route('/dashboard')
def dashboard():
    if 'user' not in session:
        return redirect('/login')



    total = 0
    safe = 0
    warning = 0
    danger = 0
    recent_scans = []
    is_admin = (session['user'] == ADMIN_EMAIL)
    uid = get_auth_user_id()

    if cursor is not None:
        try:
            if is_admin:
                cursor.execute("SELECT COUNT(*) FROM scans")
                total = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Safe'")
                safe = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Warning'")
                warning = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Dangerous'")
                danger = cursor.fetchone()[0]

                cursor.execute("SELECT type, input_data, score, result, created_at FROM scans ORDER BY id DESC LIMIT 5")
                recent_scans = cursor.fetchall()
            else:
                cursor.execute("SELECT COUNT(*) FROM scans WHERE user_id=%s OR user_id IS NULL", (uid,))
                total = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Safe' AND (user_id=%s OR user_id IS NULL)", (uid,))
                safe = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Warning' AND (user_id=%s OR user_id IS NULL)", (uid,))
                warning = cursor.fetchone()[0]

                cursor.execute("SELECT COUNT(*) FROM scans WHERE result='Dangerous' AND (user_id=%s OR user_id IS NULL)", (uid,))
                danger = cursor.fetchone()[0]

                cursor.execute("SELECT type, input_data, score, result, created_at FROM scans WHERE user_id=%s OR user_id IS NULL ORDER BY id DESC LIMIT 5", (uid,))
                recent_scans = cursor.fetchall()
        except Exception as e:
            print("Dashboard metrics query error:", e)

    security_score = max(70, 100 - (danger * 8) - (warning * 3))
    threat_level = "Low" if danger == 0 else ("Moderate" if danger <= 2 else "High Risk")
    last_scan = recent_scans[0][3] if recent_scans else "Safe"

    return render_template(
        "dashboard.html",
        user=session['user'],
        total=total,
        safe=safe,
        warning=warning,
        danger=danger,
        security_score=security_score,
        threat_level=threat_level,
        last_scan=last_scan,
        recent_scans=recent_scans,
        is_admin=is_admin
    )
# ---------------- ADMIN ----------------
@app.route('/admin', methods=['GET','POST'])
def admin():
    if 'user' not in session:
        return redirect('/login')

    if session['user'] != ADMIN_EMAIL:
        return redirect('/dashboard')

    # Auto-redirect mobile app users
    user_agent = request.headers.get('User-Agent', '').lower()
    if "scamshieldandroid" in user_agent:
        return redirect('/mobile_app?screen=admin')

    if request.method == 'POST':
        data = request.form['data']
        type_ = request.form['type']
        reason = request.form['reason']

        cursor.execute(
            "INSERT INTO blacklist (data,type,reason) VALUES (%s,%s,%s)",
            (data,type_,reason)
        )
        db.commit()

    cursor.execute("SELECT * FROM blacklist ORDER BY id DESC")
    items = cursor.fetchall()

    cursor.execute("SELECT id, type, input_data, reason, status, created_at, proof_data FROM community_reports ORDER BY id DESC")
    reports = cursor.fetchall()

    return render_template("admin.html", items=items, reports=reports, user=session['user'])

@app.route('/admin/approve_report/<int:id>', methods=['POST'])
def approve_report(id):
    if 'user' not in session or session['user'] != ADMIN_EMAIL:
        return redirect('/login')

    cursor.execute("SELECT type, input_data, reason FROM community_reports WHERE id=%s", (id,))
    rep = cursor.fetchone()
    if rep:
        type_, data, reason = rep[0], rep[1], rep[2]
        cursor.execute("INSERT INTO blacklist (data, type, reason) VALUES (%s, %s, %s)", (data, type_, f"Community Approved: {reason}"))
        cursor.execute("UPDATE community_reports SET status='Approved' WHERE id=%s", (id,))
        db.commit()

    return redirect('/admin')

@app.route('/admin/reject_report/<int:id>', methods=['POST'])
def reject_report(id):
    if 'user' not in session or session['user'] != ADMIN_EMAIL:
        return redirect('/login')

    cursor.execute("UPDATE community_reports SET status='Rejected' WHERE id=%s", (id,))
    db.commit()

    return redirect('/admin')

# ---------------- DELETE BLACKLIST ----------------
@app.route('/delete_blacklist/<int:id>', methods=['POST'])
def delete_blacklist(id):
    if 'user' not in session or session['user'] != ADMIN_EMAIL:
        return redirect('/login')

    cursor.execute(
        "DELETE FROM blacklist WHERE id=%s",
        (id,)
    )

    db.commit()

    return redirect('/admin')
# ---------------- HISTORY ----------------
@app.route('/history')
def history():
    if 'user' not in session:
        return redirect('/login')



    scans = []
    is_admin = (session['user'] == ADMIN_EMAIL)
    uid = get_auth_user_id()

    if cursor is not None:
        try:
            if is_admin:
                cursor.execute("""
                    SELECT scans.id, scans.type, scans.input_data, scans.score, scans.result, scans.created_at, COALESCE(users.email, 'Anonymous')
                    FROM scans 
                    LEFT JOIN users ON scans.user_id = users.id
                    ORDER BY scans.id DESC
                """)
            else:
                cursor.execute("""
                    SELECT scans.id, scans.type, scans.input_data, scans.score, scans.result, scans.created_at, COALESCE(users.email, 'Me')
                    FROM scans 
                    LEFT JOIN users ON scans.user_id = users.id
                    WHERE scans.user_id = %s OR (scans.user_id IS NULL AND %s IS NULL)
                    ORDER BY scans.id DESC
                """, (uid, uid))
            scans = cursor.fetchall()
        except Exception as e:
            print("History query error:", e)

    return render_template("history.html", scans=scans, user=session['user'], is_admin=is_admin)

@app.route('/export_data')
def export_data():
    if 'user' not in session:
        return redirect('/login')

    import csv
    import io
    from flask import Response

    is_admin = (session['user'] == ADMIN_EMAIL)
    uid = get_auth_user_id()

    output = io.StringIO()
    writer = csv.writer(output)

    if is_admin:
        writer.writerow(['Scan Ref ID', 'Scanned By User', 'Type', 'Input Data', 'Threat Score', 'Verdict', 'Timestamp'])
        if cursor is not None:
            cursor.execute("""
                SELECT scans.id, COALESCE(users.email, 'Anonymous'), scans.type, scans.input_data, scans.score, scans.result, scans.created_at
                FROM scans
                LEFT JOIN users ON scans.user_id = users.id
                ORDER BY scans.id DESC
            """)
            for row in cursor.fetchall():
                writer.writerow(row)
    else:
        writer.writerow(['Scan Ref ID', 'Type', 'Input Data', 'Threat Score', 'Verdict', 'Timestamp'])
        if cursor is not None:
            cursor.execute("""
                SELECT scans.id, scans.type, scans.input_data, scans.score, scans.result, scans.created_at
                FROM scans
                WHERE scans.user_id = %s OR (scans.user_id IS NULL AND %s IS NULL)
                ORDER BY scans.id DESC
            """, (uid, uid))
            for row in cursor.fetchall():
                writer.writerow(row)

    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": "attachment; filename=scamshield_scan_history.csv"}
    )

# ---------------- OCR & QR PAGES & API ----------------
@app.route('/ocr_qr')
def ocr_qr_page():
    if 'user' not in session:
        return redirect('/login')



    return render_template("ocr_qr.html", user=session['user'])

# QR Code Fraud Scanner Endpoint
@app.route('/scan_qr', methods=['POST'])
@app.route('/api/v1/scan/qr', methods=['POST'])
@token_required
def scan_qr():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection error"}), 500

    raw_payload = ""
    if request.is_json:
        raw_payload = request.json.get('payload', '').strip()
    else:
        raw_payload = request.form.get('payload', '').strip()

    if not raw_payload and 'qr_image' in request.files:
        file = request.files['qr_image']
        file_bytes = file.read()
        decoded = decode_qr_from_image(file_bytes)
        if decoded:
            raw_payload = decoded

    if not raw_payload:
        return jsonify({"status": "error", "message": "No QR payload or valid QR code detected in image"}), 400

    uid = getattr(request, 'user_id', None)
    parsed = parse_qr_payload(raw_payload)
    if parsed["type"] == "UPI_QR":
        vpa = parsed.get("vpa", "")
        res = analyze_upi(vpa, user_id=uid)
        res["qr_payload"] = parsed
        return jsonify(res)
    else:
        res = analyze_url(raw_payload, user_id=uid)
        res["qr_payload"] = parsed
        return jsonify(res)

# OCR Screenshot Scanner Endpoint
@app.route('/scan_ocr', methods=['POST'])
@app.route('/api/v1/scan/image', methods=['POST'])
@token_required
def scan_ocr():
    if cursor is None:
        return jsonify({"status": "error", "message": "Database connection error"}), 500

    file_bytes = None
    if 'screenshot' in request.files:
        file = request.files['screenshot']
        file_bytes = file.read()
    elif 'image' in request.files:
        file = request.files['image']
        file_bytes = file.read()

    if not file_bytes:
        return jsonify({"status": "error", "message": "Please upload a screenshot image file"}), 400

    uid = getattr(request, 'user_id', None)
    extracted_text = ""
    qr_payload = decode_qr_from_image(file_bytes)

    found_upis = re.findall(r'[\w.-]+@[\w.-]+', extracted_text)
    found_urls = re.findall(r'https?://[^\s]+', extracted_text)

    findings = []
    max_score = 0
    primary_result = "Safe"

    if qr_payload:
        parsed_qr = parse_qr_payload(qr_payload)
        if parsed_qr.get("vpa"):
            found_upis.append(parsed_qr["vpa"])
        else:
            found_urls.append(qr_payload)

    for upi_item in found_upis:
        res = analyze_upi(upi_item, user_id=uid)
        findings.append(f"Extracted UPI [{upi_item}]: {res['result']} (Score: {res['score']})")
        if res['score'] > max_score:
            max_score = res['score']
            primary_result = res['result']

    for url_item in found_urls:
        res = analyze_url(url_item, user_id=uid)
        findings.append(f"Extracted URL [{url_item}]: {res['result']} (Score: {res['score']})")
        if res['score'] > max_score:
            max_score = res['score']
            primary_result = res['result']

    if not found_upis and not found_urls:
        findings.append("OCR screenshot analyzed. No suspicious handles or phishing links detected.")

    confidence, advice = get_confidence_and_advice(max_score)

    return jsonify({
        "status": "success",
        "score": max_score,
        "result": primary_result,
        "extracted_upis": found_upis,
        "extracted_urls": found_urls,
        "reason": " | ".join(findings),
        "confidence": confidence,
        "advice": advice
    })

# PDF Security Evidence Report Endpoint
@app.route('/download_pdf_report/<int:scan_id>')
def download_pdf_report(scan_id):
    if 'user' not in session:
        return redirect('/login')

    if cursor is None:
        return "Database unavailable", 500

    cursor.execute("SELECT id, type, input_data, score, result, created_at FROM scans WHERE id=%s", (scan_id,))
    scan = cursor.fetchone()
    if not scan:
        return "Scan record not found", 404

    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib import colors
    import io
    from flask import Response

    pdf_buffer = io.BytesIO()
    doc = SimpleDocTemplate(pdf_buffer, pagesize=letter, rightMargin=36, leftMargin=36, topMargin=36, bottomMargin=36)
    styles = getSampleStyleSheet()

    title_style = ParagraphStyle('TitleStyle', parent=styles['Heading1'], fontName='Helvetica-Bold', fontSize=18, textColor=colors.HexColor('#14532d'), spaceAfter=12)
    heading_style = ParagraphStyle('HeadingStyle', parent=styles['Heading2'], fontName='Helvetica-Bold', fontSize=12, textColor=colors.HexColor('#0f172a'), spaceAfter=6)
    body_style = ParagraphStyle('BodyStyle', parent=styles['Normal'], fontName='Helvetica', fontSize=10, textColor=colors.HexColor('#334155'), leading=14)

    story = []
    story.append(Paragraph("SCAM SHIELD AI - OFFICIAL SECURITY AUDIT REPORT", title_style))
    story.append(Paragraph(f"Report ID: #SSR-{scan[0]} | Generated for: {session['user']} | Date: {scan[5]}", body_style))
    story.append(Spacer(1, 15))

    badge_color = "#14532d" if scan[4] == 'Safe' else ("#d97706" if scan[4] == 'Warning' else "#dc2626")
    badge_html = f"<font color='{badge_color}'><b>{scan[4].upper()}</b></font>"

    table_data = [
        ["Audit Parameter", "Value Detail"],
        ["Scan Reference ID", f"#SSR-{scan[0]}"],
        ["Target Type", str(scan[1])],
        ["Analyzed Input Target", str(scan[2])],
        ["Threat Risk Score", f"{scan[3]} / 25"],
        ["Classification Result", Paragraph(badge_html, body_style)],
        ["Timestamp", str(scan[5])]
    ]

    t = Table(table_data, colWidths=[150, 380])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (1,0), colors.HexColor('#f1f5f9')),
        ('TEXTCOLOR', (0,0), (1,0), colors.HexColor('#0f172a')),
        ('FONTNAME', (0,0), (-1,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 10),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#cbd5e1')),
    ]))
    story.append(t)
    story.append(Spacer(1, 20))

    story.append(Paragraph("Actionable Evidence & Threat Guidance", heading_style))
    advice_text = "Verify recipient identity and double check handle parameters." if scan[4] == 'Safe' else "High risk detected. Do NOT enter UPI PIN, click links, or transfer funds. File a complaint immediately on National Cyber Crime Helpline 1930."
    story.append(Paragraph(advice_text, body_style))
    story.append(Spacer(1, 20))

    story.append(Paragraph("National Cyber Crime Helpline: Call 1930 | Official Reporting Portal: cybercrime.gov.in", ParagraphStyle('Sub', parent=body_style, fontSize=9, textColor=colors.HexColor('#64748b'))))

    doc.build(story)
    pdf_buffer.seek(0)

    return Response(
        pdf_buffer.getvalue(),
        mimetype="application/pdf",
        headers={"Content-Disposition": f"attachment;filename=scam_shield_report_{scan_id}.pdf"}
    )

# ---------------- PAGES ----------------
@app.route('/upi')
def upi():
    if 'user' not in session:
        return redirect('/login')
    return render_template("upi.html", user=session['user'])

@app.route('/url')
def url_page():
    if 'user' not in session:
        return redirect('/login')
    return render_template("url.html", user=session['user'])

@app.route('/sms')
def sms():
    if 'user' not in session:
        return redirect('/login')
    return render_template("sms.html", user=session['user'])

# ---------------- UPI CHECK ----------------
@app.route('/check_upi', methods=['POST'])
@app.route('/api/v1/scan/upi', methods=['POST'])
@token_required
def check_upi():
    data = request.get_json(silent=True) or {}
    upi_val = data.get('upi', '').strip() if request.is_json else request.form.get('upi', '').strip()
    uid = getattr(request, 'user_id', None)
    return jsonify(analyze_upi(upi_val, user_id=uid))

# ---------------- PHONE CHECK ----------------
@app.route('/check_phone', methods=['POST'])
@app.route('/api/v1/scan/phone', methods=['POST'])
@token_required
def check_phone():
    data = request.get_json(silent=True) or {}
    phone_val = data.get('phone', '').strip() if request.is_json else request.form.get('phone', '').strip()
    uid = getattr(request, 'user_id', None)
    return jsonify(analyze_phone(phone_val, user_id=uid))

# ---------------- BROWSER EXTENSION ENDPOINTS ----------------
@app.route('/api/v1/extension/check_url', methods=['POST', 'OPTIONS'])
def extension_check_url():
    if request.method == 'OPTIONS':
        response = jsonify({"status": "ok"})
        response.headers.add("Access-Control-Allow-Origin", "*")
        response.headers.add("Access-Control-Allow-Headers", "Content-Type, Authorization")
        response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
        return response

    data = request.get_json(silent=True) or {}
    url_val = data.get('url', '').strip()
    if not url_val:
        res = jsonify({"status": "error", "message": "No URL provided"})
        res.headers.add("Access-Control-Allow-Origin", "*")
        return res, 400

    uid = get_auth_user_id()
    check_res = analyze_url(url_val, user_id=uid)

    response = jsonify(check_res)
    response.headers.add("Access-Control-Allow-Origin", "*")
    return response

@app.route('/extension')
def extension_page():
    if 'user' not in session:
        return redirect('/login')
    return render_template("extension.html", user=session['user'])

@app.route('/download_extension_zip')
def download_extension_zip():
    if 'user' not in session:
        return redirect('/login')

    import zipfile
    import io
    from flask import Response

    ext_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "browser_extension")
    zip_buffer = io.BytesIO()

    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for root, dirs, files in os.walk(ext_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, ext_dir)
                zip_file.write(file_path, arcname)

    zip_buffer.seek(0)
    return Response(
        zip_buffer.getvalue(),
        mimetype="application/zip",
        headers={"Content-Disposition": "attachment; filename=scamshield-browser-extension.zip"}
    )

# ---------------- MOBILE ANDROID APP ENDPOINTS ----------------
@app.route('/mobile')
@app.route('/mobile_app')
def mobile_app():
    if 'user' not in session:
        return redirect('/login')
    user = session.get('user', 'Guest User')
    return render_template("mobile_app.html", user=user)

# ---------------- URL CHECK ----------------
@app.route('/check_url', methods=['POST'])
@app.route('/api/v1/scan/url', methods=['POST'])
@token_required
def check_url():
    data = request.get_json(silent=True) or {}
    url_val = data.get('url', '').strip() if request.is_json else request.form.get('url', '').strip()
    uid = getattr(request, 'user_id', None)
    return jsonify(analyze_url(url_val, user_id=uid))

# ---------------- SMS CHECK ----------------
@app.route('/check_sms', methods=['POST'])
@app.route('/api/v1/scan/sms', methods=['POST'])
@token_required
def check_sms():
    data = request.get_json(silent=True) or {}
    sms_val = data.get('sms', '').strip() if request.is_json else request.form.get('sms', '').strip()
    uid = getattr(request, 'user_id', None)
    return jsonify(analyze_sms(sms_val, user_id=uid))

# ---------------- ADVANCED ENDPOINTS ----------------

# 1. Community Scam Reporting
@app.route('/report')
def report_page():
    if 'user' not in session:
        return redirect('/login')
    return render_template("report.html", user=session['user'])

@app.route('/report_scam', methods=['POST'])
@app.route('/api/v1/reports', methods=['POST'])
@token_required
def report_scam():
    user_id = getattr(request, 'user_id', None)
    if not user_id:
        return jsonify({"status": "error", "message": "Authentication required"}), 401
    
    if request.is_json:
        req = request.get_json(silent=True) or {}
        data = req.get('data', '').strip()
        type_ = req.get('type', '').upper().strip()
        reason = req.get('reason', 'Reported by user as fraud').strip()
        proof = req.get('proof', '').strip()
    else:
        data = request.form.get('data', '').strip()
        type_ = request.form.get('type', '').upper().strip()
        reason = request.form.get('reason', 'Reported by user as fraud').strip()
        proof = request.form.get('proof', '').strip()

    if type_ in ['WEBSITE', 'LINK']:
        type_ = 'URL'

    if not data or not type_:
        return jsonify({"status": "error", "message": "Missing required fields (data, type)"}), 400

    try:
        cursor.execute(
            "INSERT INTO community_reports (user_id, type, input_data, reason, proof_data) VALUES (%s, %s, %s, %s, %s)",
            (user_id, type_, data, reason, proof)
        )
        db.commit()
        return jsonify({"status": "success", "message": f"{type_} fraud report and proof evidence submitted successfully."})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# 3. Developer REST API Endpoint
@app.route('/api/v1/analyze', methods=['POST'])
@token_required
def api_v1_analyze():
    req = request.get_json(silent=True) or {}
    input_type = req.get('type', '').upper().strip()
    input_data = req.get('data', '').strip()

    if not input_type or not input_data:
        return jsonify({
            "error": "Bad Request. Provide 'type' (UPI|URL|SMS) and 'data' string in JSON body."
        }), 400

    uid = getattr(request, 'user_id', None)
    if input_type == 'UPI':
        return jsonify(analyze_upi(input_data, user_id=uid))
    elif input_type == 'URL':
        return jsonify(analyze_url(input_data, user_id=uid))
    elif input_type == 'SMS':
        return jsonify(analyze_sms(input_data, user_id=uid))
    else:
        return jsonify({"error": "Unsupported type. Valid types are: UPI, URL, SMS."}), 400


# ---------------- MOBILE API ----------------

@app.route('/api/v1/scans/history', methods=['GET'])
@app.route('/api/v1/mobile/history')
@token_required
def api_mobile_history():
    uid = request.user_id
    try:
        cursor.execute("SELECT type, input_data, score, result, created_at FROM scans WHERE user_id=%s ORDER BY id DESC LIMIT 50", (uid,))
        rows = cursor.fetchall()
        scans = [{"type": r[0], "data": r[1], "score": r[2], "result": r[3], "date": str(r[4])} for r in rows]
        return jsonify({"status": "success", "items": scans})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# ---------------- RUN ----------------
if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    host = "0.0.0.0"
    port = int(os.getenv("PORT", 3000))
    print(f"[OK] ScamShield Server running on http://{host}:{port} (Accessible on local Wi-Fi)")
    app.run(host=host, port=port, debug=debug_mode)
