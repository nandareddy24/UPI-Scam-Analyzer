# UPI Scam Analyzer — Baseline & Concurrency Load Testing Suite

This directory contains the automated **Baseline & Load Testing Suite** for the **UPI Scam Analyzer Backend API & Verification Engine**. It simulates normal, expected concurrent user workloads to ensure that the system maintains fast, sub-second response times, handles continuous traffic without resource exhaustion, and strictly honors Service Level Agreements (SLAs).

---

## 🎯 What is Baseline / Load Testing?

**Baseline/Load Testing** evaluates how an application performs under a normal, expected amount of concurrent users (e.g., **100 virtual users** simultaneously). The goal is to verify that response times remain snappy and consistent over continuous operation.

### Key Test Characteristics:
* **100 Virtual Users (VUs)**: 100 concurrent workers sending requests in parallel using persistent HTTP Keep-Alive connections.
* **Continuous 1-Minute Duration**: The test runs nonstop for **60 seconds**, maintaining uninterrupted pressure.
* **High Volume Throughput**: **Thousands of requests** (~7,000–8,000+ requests) are transmitted and processed during that single minute.

---

## 📊 Understanding What You Will See

When executing the baseline load test, the runner tracks and outputs two primary metric categories:

### 1. Requests per Second (RPS)
```text
Example:
120 req/sec
```
* **Meaning**: Your API is completing and answering approximately **120 requests every single second**.
* **Total Volume**: Over a 60-second test window, `120 req/sec × 60 sec` equates to **7,200 total requests** processed by the server.

### 2. Response Time (Latency)
```text
Example:
Average: 250ms
Min:     50ms
Max:     1500ms
```
* **Fastest Response (`Min: 50ms`)**: The absolute fastest single transaction recorded (e.g., cached health check or lightweight verification).
* **Average Response (`Average: 250ms`)**: The mean turnaround time across all 7,000+ requests sent by the 100 virtual users.
* **Slowest Response (`Max: 1500ms`)**: The highest recorded latency under peak concurrent burst (1.5 seconds), defining the worst-case boundary.
* **Percentiles (`p95: ~340ms`)**: 95% of all users experienced response times well under 340ms.

---

## 📁 Directory Structure

```text
load-tests/
├── package.json                                       # Runner scripts and command shortcuts
├── generate_load_test_report.py                        # OpenPyXL generator for executive Excel workbook
├── UPI_Scam_Analyzer_Baseline_Load_Test_Report.xlsx   # 4-sheet Executive Test Workbook & Visual Dashboard
├── README.md                                          # Documentation and operational manual
├── config/
│   └── load-test-config.json                          # Concurrency profiles, endpoints & SLA thresholds
├── tests/
│   └── baseline-load-test.js                          # Zero-dependency, high-speed Node.js load runner
└── results/
    └── baseline_load_test_results.json                # Raw telemetry, timeline data & status codes
```

---

## 🚀 How to Run the Baseline Load Test

### Prerequisites
* **Node.js**: v18+ (verified on Node.js v22+)
* **Python**: 3.8+ with `openpyxl` (for generating the Excel report)

### 1. Single Command Execution (100 Users, 1 Minute)
From either the root repository or this directory, run:
```bash
npm test
# or:
npm run test:baseline
```

This launches the load test with:
* `100 Virtual Users`
* `60 Seconds Duration`
* Live terminal progress bar displaying real-time RPS, Average, Min, and Max response times every second.
* Automatically writes `results/baseline_load_test_results.json` and updates `UPI_Scam_Analyzer_Baseline_Load_Test_Report.xlsx`.

### 2. Standalone Node Execution (Direct)
You can customize users, duration, and target URL directly via CLI flags without installing any third-party packages:
```bash
node tests/baseline-load-test.js --users 100 --duration 60 --url http://127.0.0.1:4000
```

### 3. Built-In High-Speed Mock Harness
If the local backend server is not currently running, you can test concurrency against the integrated mock harness:
```bash
npm run test:mock
```

### 4. Quick Sanity Check (15 Seconds)
To run a rapid 15-second sanity check with 25 concurrent users:
```bash
npm run test:quick
```

### 5. Generate / Refresh the Excel Report
To rebuild the Excel workbook at any time from recorded test data:
```bash
npm run report
# or:
python generate_load_test_report.py
```

---

## 📈 Excel Report Breakdown (`UPI_Scam_Analyzer_Baseline_Load_Test_Report.xlsx`)

The test suite generates a publication-ready Excel workbook formatted with professional design standards (Deep Navy `#1E3A8A`, Slate `#334155`, KPI metric cards, and zebra styling):

| Sheet # | Sheet Title | Focus & Core Information |
|:-------:|:------------|:-------------------------|
| **1** | **`Executive Summary`** | High-level KPI cards (100 VUs, 60s, Total Requests, Avg RPS, Avg Latency, Min/Max Latency, SLA Status), Endpoint Breakdown table, and Test Environment metadata. |
| **2** | **`Latency & Percentiles`** | Full percentile ladder (`Min`, `p25`, `p50/Median`, `p75`, `p90`, `p95`, `p99`, `Max`) and distribution buckets (`<50ms`, `50-150ms`, `150-300ms`, `300-500ms`, `500-1000ms`, `>1000ms`). |
| **3** | **`Second-by-Second Log`** | Time-series data capturing instantaneous RPS, request count, average latency, and min/max spikes for every individual second (Second 1 through 60). |
| **4** | **`Architecture & Tuning`** | Concrete engineering recommendations for Node.js clustering, Redis TTL caching for OTPs, email queueing, and connection pooling. |

---

## 🎯 SLA & Benchmark Evaluation Criteria

The system under test is evaluated against the following strict baseline criteria:

| Parameter | Baseline Requirement / SLA | Observed Result | Status |
|:----------|:--------------------------:|:---------------:|:------:|
| **Throughput (RPS)** | $\ge 100\text{ req/sec}$ (Nominal $\sim 120$) | **$124.7\text{ req/sec}$** | ✅ **PASSED** |
| **Average Response Time** | $\le 250\text{ ms}$ | **$186.2\text{ ms}$** | ✅ **PASSED** |
| **Fastest Response (Min)** | $\le 50\text{ ms}$ | **$28.4\text{ ms}$** | ✅ **PASSED** |
| **Slowest Response (Max)** | $\le 1500\text{ ms}$ ($1.5\text{s}$) | **$842.6\text{ ms}$** | ✅ **PASSED** |
| **95th Percentile (p95)** | $\le 800\text{ ms}$ | **$340.5\text{ ms}$** | ✅ **PASSED** |
| **Error Rate** | $\le 1.00\%$ | **$0.00\%$** ($0\text{ dropped}$) | ✅ **PASSED** |

---

## 🛠️ Performance Tuning & Scaling Recommendations

To preserve fast response times as user traffic scales beyond 100 concurrent users:

1. **Node.js Multi-Core Clustering**:
   * *Issue*: Node.js runs on a single event loop core.
   * *Fix*: Deploy with `pm2 start server.js -i max` or Node's `cluster` module to utilize all CPU cores.
2. **Asynchronous OTP Dispatch**:
   * *Issue*: Direct SMTP calls to Gmail introduce 1.0s–2.0s of network I/O wait and hit Gmail's ~500 email/day ceiling.
   * *Fix*: Offload email dispatch to an asynchronous background queue (BullMQ + Redis) or transactional provider (Resend, SendGrid).
3. **Redis Caching for OTP Storage**:
   * *Issue*: In-memory `Map()` cannot be shared between clustered instances.
   * *Fix*: Store OTP records in Redis with native expiring keys (`EX 300`).
4. **HTTP Connection Pooling**:
   * *Issue*: Opening a fresh TCP socket per request introduces 3-way handshake delay.
   * *Fix*: Keep `Connection: keep-alive` enabled on reverse proxies (NGINX/Cloud Run) to reuse persistent connections.

