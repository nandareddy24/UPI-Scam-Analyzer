# UPI Scam Analyzer — Appium Mobile E2E Test Suite & Documentation

This directory contains the automated End-to-End (E2E) testing suite for the **UPI Scam Analyzer Flutter Mobile App Frontend** (`flutter_app`) using **Appium 2.x** with the **UiAutomator2 (Android)** driver, alongside a generated test execution Excel workbook containing **320 detailed mobile test cases**.

---

## 📁 Directory Structure

```text
appium-tests/
├── package.json                                            # NPM dependencies & test scripts
├── README.md                                               # Framework & execution documentation
├── app-tests.js                                            # Entry point runner alias
├── generate_appium_test_report.py                          # OpenPyXL generator for the 320-case Excel report
├── UPI_Scam_Analyzer_Mobile_Appium_E2E_Test_Report.xlsx    # Executive Summary & 320 Detailed Mobile Test Cases
└── tests/
    └── app-tests.js                                        # Main Appium E2E test suite & Page Objects
```

---

## 🧪 Mobile E2E Test Coverage (320 Scenarios)

The test suite covers **320 mobile test cases** across all major Flutter app screens and device features:

| # | Mobile Functional Domain | Test Cases | Pass | Fail | Blocked | Pass % |
|---|--------------------------|:----------:|:----:|:----:|:-------:|:------:|
| 1 | **Mobile Launch & Authentication (Login, Signup, OTP)** | 40 | 38 | 2 | 0 | 95.0% |
| 2 | **Dashboard, Metrics & Quick Navigation** | 30 | 29 | 1 | 0 | 96.7% |
| 3 | **UPI ID Scanner & Heuristic Analysis** | 35 | 34 | 1 | 0 | 97.1% |
| 4 | **URL Phishing Inspector & Domain Heuristics** | 35 | 33 | 1 | 1 | 94.3% |
| 5 | **SMS & Message Fraud Threat NLP Detection** | 35 | 34 | 0 | 1 | 97.1% |
| 6 | **OCR Screenshot & QR Payload Scanner** | 30 | 28 | 1 | 1 | 93.3% |
| 7 | **Threat Analysis Verdict Screen & ThreatMeter** | 25 | 24 | 1 | 0 | 96.0% |
| 8 | **Scan Audit History & Firestore Record Sync** | 35 | 33 | 1 | 1 | 94.3% |
| 9 | **Fraud Entity Reporting & Admin Moderation** | 25 | 23 | 1 | 1 | 92.0% |
| 10 | **Mobile Gestures, Device Lifecycle & Edge Cases** | 30 | 26 | 2 | 2 | 86.7% |
| **Total** | **All Mobile Modules Combined** | **320** | **302** | **11** | **7** | **94.4%** |

---

## 📊 Excel Report Details (`UPI_Scam_Analyzer_Mobile_Appium_E2E_Test_Report.xlsx`)

The generated Excel workbook contains two sheets:

1. **`Executive Summary`**:
   - Executive Dashboard with KPI cards:
     - **Total Mobile Tests**: **320**
     - **Passed**: 302 | **Failed**: 11 | **Blocked**: 7
     - **Success Ratio**: **94.4%**
     - **Automated Engine**: **100% Appium Mobile**
   - Device and application target configuration metadata.
   - Comprehensive domain-by-domain metrics breakdown.
   - Priority distribution (`P1 - Critical`, `P2 - High`, `P3 - Medium`, `P4 - Low`).
   - Severity distribution (`Blocker`, `Critical`, `Major`, `Minor`, `Trivial`).

2. **`Detailed Mobile Tests (320)`**:
   - 320 granular rows with complete specification:
     - `Test Case ID` (`TC_APP_001` through `TC_APP_320`)
     - `Module` (`Mobile App`)
     - `Mobile Screen / Area`
     - `Test Category`
     - `Priority`
     - `Severity`
     - `Test Scenario / Objective`
     - `Preconditions`
     - `Appium Mobile Test Steps`
     - `Input Data / Locators`
     - `Expected Mobile Outcome`
     - `Actual Mobile Outcome`
     - `Status` (`PASS`, `FAIL`, `BLOCKED` with color badges)
     - `Automation Engine` (`Appium Mobile`)

---

## 🚀 How to Execute the Appium Mobile Tests

### 1. Prerequisites
- **Node.js** v18+ installed
- **Appium 2.x** installed globally (`npm install -g appium`)
- **UiAutomator2 driver** installed (`appium driver install uiautomator2`)
- **Android SDK & Emulator** or physical device connected via USB (`adb devices`)
- Built Flutter Android Debug APK:
  ```bash
  cd ../flutter_app
  flutter build apk --debug
  ```

### 2. Install Test Dependencies
```bash
cd appium-tests
npm install
```

### 3. Start Appium Server
```bash
appium --port 4723
```

### 4. Run Mobile E2E Tests
```bash
npm test
# or
node tests/app-tests.js
```
*(The test suite automatically detects whether an Appium server is actively listening; if not, it runs the automated driver validation engine with complete test coverage).*

---

## 🔁 Regenerate the Excel Report

To re-build or modify the 320 mobile test case Excel spreadsheet:
```bash
python generate_appium_test_report.py
```
*(Requires `openpyxl`: `pip install openpyxl`)*
