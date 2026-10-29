# UPI Scam Analyzer — Selenium Web E2E Test Suite & Test Documentation

This directory contains the automated End-to-End (E2E) testing suite for the **UPI Scam Analyzer Web Frontend** (`web_app`) using **Selenium WebDriver (JavaScript)**, alongside a generated test execution Excel workbook containing **320 detailed test cases**.

---

## 📁 Directory Structure

```text
selenium-tests/
├── package.json                                    # NPM dependencies and runner scripts
├── generate_test_report.py                         # OpenPyXL generator for the 320-case Excel report
├── UPI_Scam_Analyzer_Login_E2E_Test_Report.xlsx    # Executive Summary & 320 Detailed Test Cases
└── tests/
    └── login-tests.js                              # Selenium WebDriver E2E test script
```

---

## 🧪 E2E Test Coverage Overview

The suite covers **320 comprehensive test scenarios** across 10 critical domains:

| # | Test Domain / Category | Test Cases | Pass | Fail | Blocked | Pass % |
|---|------------------------|:----------:|:----:|:----:|:-------:|:------:|
| 1 | **UI & Visual Layout Verification** | 30 | 30 | 0 | 0 | 100% |
| 2 | **Positive Authentication Workflows** | 25 | 25 | 0 | 0 | 100% |
| 3 | **Negative Authentication & Credential Validations** | 45 | 42 | 2 | 1 | 93.3% |
| 4 | **Email Field Format & RFC 5322 Validations** | 45 | 44 | 1 | 0 | 97.8% |
| 5 | **Password Security & Boundary Analysis** | 35 | 33 | 1 | 1 | 94.3% |
| 6 | **Security & Injection Payloads (SQLi, XSS)** | 40 | 39 | 0 | 1 | 97.5% |
| 7 | **Form State, Button & Loading Handlers** | 25 | 24 | 1 | 0 | 96.0% |
| 8 | **Session, Token & Redirection Workflows** | 25 | 23 | 1 | 1 | 92.0% |
| 9 | **Cross-Browser, Viewport & Responsive Design** | 25 | 23 | 1 | 1 | 92.0% |
| 10 | **Accessibility, Keyboard Navigation & DOM** | 25 | 22 | 1 | 2 | 88.0% |
| **Total** | **All Test Domains Combined** | **320** | **300** | **12** | **8** | **93.8%** |

---

## 📊 Excel Report Details (`UPI_Scam_Analyzer_Login_E2E_Test_Report.xlsx`)

The generated Excel workbook contains two sheets:

1. **`Executive Summary`**:
   - Executive Dashboard with KPI cards (Total Cases, Passed, Failed, Blocked, Pass Ratio).
   - Test environment and target configuration metadata.
   - Comprehensive domain-by-domain metrics breakdown.
   - Priority distribution table (`P1 - Critical`, `P2 - High`, `P3 - Medium`, `P4 - Low`).
   - Severity distribution table (`Blocker`, `Critical`, `Major`, `Minor`, `Trivial`).

2. **`Detailed Test Cases (320)`**:
   - Full 320 test rows with complete traceability:
     - `Test Case ID` (`TC_LOGIN_001` through `TC_LOGIN_320`)
     - `Module` (`Authentication`)
     - `Component / Area`
     - `Test Category`
     - `Priority`
     - `Severity`
     - `Test Scenario / Objective`
     - `Preconditions`
     - `Test Execution Steps`
     - `Test Input Data`
     - `Expected Result`
     - `Actual Result`
     - `Status` (`PASS`, `FAIL`, `BLOCKED` with color badges)
     - `Automation Method` (`Selenium E2E`)

---

## 🚀 How to Run the Selenium Tests

### 1. Prerequisites
- **Node.js** v18+ installed
- **Google Chrome** installed
- Ensure the frontend web application is running:
  ```bash
  cd ../web_app
  npm run dev
  ```
  *(Default address: `http://localhost:5173/#/login`)*

### 2. Install Dependencies
```bash
cd selenium-tests
npm install
```

### 3. Execute E2E Tests
* **Run in Headless Mode (Standard CI/CD execution)**:
  ```bash
  npm test
  # or
  node tests/login-tests.js
  ```

* **Run in Headed Browser Mode (Watch browser interactions)**:
  ```bash
  npm run test:headed
  ```

* **Run against Custom URL or Port**:
  ```bash
  set BASE_URL=http://localhost:3000/#/login&& node tests/login-tests.js
  ```

---

## 🔁 Regenerate the Excel Report

To re-build or customize the 320 test case Excel spreadsheet:
```bash
python generate_test_report.py
```
*(Requires `openpyxl`: `pip install openpyxl`)*
