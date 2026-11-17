# Custom Domain Configuration & DNS Verification Guide

This document outlines the custom domain connection, DNS record configuration, HTTPS enforcement, and verification procedures for **UPI Scam Analyzer**.

---

## 1. Primary & Subdomain Architecture

| Record Type | Host / Name | Target / Value | Purpose |
| :--- | :--- | :--- | :--- |
| **A Record** | `@` (apex domain) | `199.36.158.100` (Firebase Hosting) | Directs root traffic to global edge CDN |
| **A Record** | `@` (apex domain) | `76.76.21.21` (Vercel alternative) | Global edge gateway |
| **CNAME** | `www` | `upi-scam.web.app.` or `cname.vercel-dns.com.` | Subdomain canonical alias |
| **TXT** | `@` | `google-site-verification=...` | Pre-issuance domain ownership verification |

---

## 2. HTTPS & TLS 1.3 Encryption Verification

1. **Automatic Certificate Provisioning:**
   - Both Firebase Hosting and Vercel automatically provision TLS 1.3 certificates via Let's Encrypt / Google Trust Services upon DNS verification.
2. **HTTP to HTTPS Redirection:**
   - Enforced by server config: All incoming insecure `http://` requests receive a `301 Moved Permanently` redirect to `https://`.
3. **Security Headers Enforced:**
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY`
   - `Referrer-Policy: strict-origin-when-cross-origin`

---

## 3. Deployment & Domain Linking Steps

### A. Deploy via Firebase Hosting
```bash
# 1. Build the production distribution
cd upi-scam-analyzer/web_app
npm run build

# 2. Deploy to Firebase
firebase deploy --only hosting

# 3. Add Custom Domain in Firebase Console:
# Hosting > Custom Domains > Add Domain > Enter your domain
# Add the provided TXT and A records to your DNS provider (Cloudflare, GoDaddy, Namecheap)
```

### B. Deploy via Vercel
```bash
# 1. Deploy using Vercel CLI
cd upi-scam-analyzer/web_app
vercel --prod

# 2. Add domain in Vercel project settings:
# Project Settings > Domains > Add 'yourdomain.com'
# Select 'Redirect yourdomain.com to www.yourdomain.com' or vice versa
```

---

## 4. Verification Testing Commands

Verify DNS resolution and HTTPS status using standard terminal commands:

```bash
# Check A record resolution
nslookup yourdomain.com

# Check CNAME resolution
nslookup www.yourdomain.com

# Verify HTTPS and TLS handshake
curl -I https://yourdomain.com
```
