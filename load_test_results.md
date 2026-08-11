# 🚀 Scam Shield AI — Baseline / Load Testing Results

**Test Date:** August 11, 2026  
**Test Configuration:**  
- **Virtual Users:** 100 concurrent users  
- **Duration:** 1 minute (61.61s actual)  
- **Target Host:** `http://127.0.0.1:5000`  

---

## 📊 High-Level Metrics Summary

| Metric | Result Value | Description / Meaning |
|---|---|---|
| **Requests Per Second (RPS)** | **`62.57 req/sec`** | Average throughput handled continuously per second |
| **Total Requests Sent** | `3,855` | Total HTTP requests executed during the 1-minute test |
| **Successful Requests** | `3,855` (100.00%) | HTTP 200/2xx successful responses |
| **Failed Requests** | `0` (0.00%) | Timeouts, socket errors, or non-2xx status codes |
| **Average Response Time** | **`1529.53 ms`** | Mean response time across all endpoints |
| **Minimum Response Time** | `41.48 ms` | Fastest single request response time |
| **Median (P50) Response Time** | `1254.86 ms` | 50% of requests were faster than this |
| **P90 Response Time** | `2485.89 ms` | 90% of requests were faster than this |
| **P95 Response Time** | `2742.86 ms` | 95% of requests were faster than this |
| **P99 Response Time** | `3865.99 ms` | 99% of requests were faster than this |
| **Maximum Response Time** | `5094.88 ms` | Slowest single request response time |

---

## 📌 Endpoint Performance Breakdown

| Endpoint Path | Total Requests | Avg Latency | Min Latency | Max Latency | Performance Grade |
|---|---|---|---|---|---|
| `/check_url` | 460 | 1372.19 ms | 77.85 ms | 2759.62 ms | 🔴 Slow |
| `/check_sms` | 469 | 1409.68 ms | 235.65 ms | 2766.26 ms | 🔴 Slow |
| `/api/v1/chat` | 503 | 1375.09 ms | 344.46 ms | 2742.86 ms | 🔴 Slow |
| `/check_upi` | 480 | 1344.81 ms | 41.48 ms | 2826.01 ms | 🔴 Slow |
| `/mobile_app` | 525 | 1362.82 ms | 134.04 ms | 2825.28 ms | 🔴 Slow |
| `/check_phone` | 469 | 1391.23 ms | 50.46 ms | 2785.49 ms | 🔴 Slow |
| `/scan` | 451 | 2720.17 ms | 432.54 ms | 5094.88 ms | 🔴 Slow |
| `/login` | 498 | 1349.47 ms | 353.87 ms | 2731.33 ms | 🔴 Slow |


---

## 💡 System Health & Observations

1. **Throughput Capability:** The Flask backend successfully sustained **`62.57 requests per second`** with **100 concurrent virtual users**.
2. **Latency Analysis:** The average response time was **`1529.53 ms`** with a minimum of **`41.48 ms`** and maximum of **`5094.88 ms`**.
3. **Stability:** Handled 3,855 total requests over 1 minute under expected peak concurrent user load.
