/**
 * ==============================================================================================
 * UPI Scam Analyzer — Web Frontend End-to-End (E2E) Selenium Automation Suite
 * File: login-tests.js
 * Description: Comprehensive E2E test suite for the Web Frontend Login & Authentication module.
 * Target URL: http://localhost:5173/#/login (React + Vite + HashRouter)
 * Framework: Selenium WebDriver (Chrome)
 * ==============================================================================================
 */

const { Builder, By, until, Key } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const path = require('path');
const fs = require('fs');

// Configuration
const BASE_URL = process.env.BASE_URL || 'http://localhost:5173/#/login';
const TIMEOUT_MS = 10000;
const HEADLESS = process.env.HEADLESS !== 'false'; // Default to headless unless HEADLESS=false

// Test Results Collector for Reporting
const testResults = [];
let passCount = 0;
let failCount = 0;
let startTime = Date.now();

/**
 * Custom Assertion & Reporting Helper
 */
async function it(testId, description, testFn) {
  const start = Date.now();
  try {
    await testFn();
    const duration = Date.now() - start;
    passCount++;
    testResults.push({
      id: testId,
      description,
      status: 'PASS',
      duration: `${duration}ms`,
      error: null,
    });
    console.log(`  \x1b[32m✔ [PASS]\x1b[0m ${testId}: ${description} (${duration}ms)`);
  } catch (err) {
    const duration = Date.now() - start;
    failCount++;
    testResults.push({
      id: testId,
      description,
      status: 'FAIL',
      duration: `${duration}ms`,
      error: err.message,
    });
    console.log(`  \x1b[31m✖ [FAIL]\x1b[0m ${testId}: ${description} (${duration}ms)`);
    console.log(`    \x1b[33mError: ${err.message}\x1b[0m`);
  }
}

function describe(suiteName) {
  console.log(`\n\x1b[36m=======================================================`);
  console.log(` SUITE: ${suiteName}`);
  console.log(`=======================================================\x1b[0m`);
}

/**
 * Driver Factory
 */
async function createDriver() {
  const options = new chrome.Options();
  if (HEADLESS) {
    options.addArguments('--headless=new');
  }
  options.addArguments(
    '--no-sandbox',
    '--disable-dev-shm-usage',
    '--disable-gpu',
    '--window-size=1280,800',
    '--ignore-certificate-errors',
    '--disable-extensions'
  );

  const driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  await driver.manage().setTimeouts({ implicit: 3000, pageLoad: 15000 });
  return driver;
}

/**
 * Page Object Model (POM) Helpers for Login Page
 */
class LoginPage {
  constructor(driver) {
    this.driver = driver;
  }

  async navigate() {
    await this.driver.get(BASE_URL);
    await this.driver.wait(until.elementLocated(By.css('h1')), TIMEOUT_MS);
  }

  async getTitleText() {
    return await this.driver.findElement(By.css('h1')).getText();
  }

  async getSubtitleText() {
    return await this.driver.findElement(By.xpath("//p[contains(text(),'UPI & Cyber Fraud')]")).getText();
  }

  async getCardHeader() {
    return await this.driver.findElement(By.css('h2')).getText();
  }

  async getEmailInput() {
    return await this.driver.findElement(By.css('input[type="email"]'));
  }

  async getPasswordInput() {
    return await this.driver.findElement(By.css('input[type="password"]'));
  }

  async getSubmitButton() {
    return await this.driver.findElement(By.css('button[type="submit"]'));
  }

  async getCreateAccountLink() {
    return await this.driver.findElement(By.xpath("//a[contains(@href, 'signup') or contains(text(), 'Create Account')]"));
  }

  async getErrorBanner() {
    try {
      const banner = await this.driver.wait(
        until.elementLocated(By.css('.bg-red-50, .border-red-200')),
        3000
      );
      return banner;
    } catch (e) {
      return null;
    }
  }

  async getErrorMessage() {
    const banner = await this.getErrorBanner();
    if (!banner) return null;
    return await banner.getText();
  }

  async login(email, password) {
    const emailInput = await this.getEmailInput();
    const passInput = await this.getPasswordInput();
    const submitBtn = await this.getSubmitButton();

    await emailInput.clear();
    if (email) await emailInput.sendKeys(email);

    await passInput.clear();
    if (password) await passInput.sendKeys(password);

    await submitBtn.click();
  }
}

/**
 * ==============================================================================================
 * MAIN E2E TEST RUNNER
 * ==============================================================================================
 */
async function runLoginE2eTests() {
  console.log(`\n\x1b[35m================================================================`);
  console.log(`   UPI Scam Analyzer — Selenium Web Frontend E2E Test Suite     `);
  console.log(`   Target: ${BASE_URL}`);
  console.log(`   Headless Mode: ${HEADLESS}`);
  console.log(`================================================================\x1b[0m\n`);

  let driver;
  try {
    driver = await createDriver();
    const page = new LoginPage(driver);

    // ------------------------------------------------------------------------------------------
    // SUITE 1: Page Load & UI Elements Verification
    // ------------------------------------------------------------------------------------------
    describe('1. UI & Elements Layout Verification');

    await it('TC_UI_001', 'Verify login page loads successfully', async () => {
      await page.navigate();
      const currentUrl = await driver.getCurrentUrl();
      if (!currentUrl.includes('/#/login') && !currentUrl.includes('localhost')) {
        throw new Error(`Expected login URL, got: ${currentUrl}`);
      }
    });

    await it('TC_UI_002', 'Verify header brand text "Scam Shield" is displayed', async () => {
      const text = await page.getTitleText();
      if (!text.includes('Scam Shield')) {
        throw new Error(`Expected brand 'Scam Shield', found: '${text}'`);
      }
    });

    await it('TC_UI_003', 'Verify platform subtitle is displayed correctly', async () => {
      const sub = await page.getSubtitleText();
      if (!sub.includes('UPI & Cyber Fraud Intelligence Platform')) {
        throw new Error(`Subtitle mismatch: '${sub}'`);
      }
    });

    await it('TC_UI_004', 'Verify card header "Sign In to Account" exists', async () => {
      const header = await page.getCardHeader();
      if (!header.includes('Sign In to Account')) {
        throw new Error(`Card header mismatch: '${header}'`);
      }
    });

    await it('TC_UI_005', 'Verify Email Address label exists', async () => {
      const label = await driver.findElement(By.xpath("//label[contains(text(),'Email Address')]"));
      if (!(await label.isDisplayed())) throw new Error('Email label is not displayed');
    });

    await it('TC_UI_006', 'Verify Email input placeholder is "name@example.com"', async () => {
      const emailInput = await page.getEmailInput();
      const ph = await emailInput.getAttribute('placeholder');
      if (ph !== 'name@example.com') throw new Error(`Placeholder mismatch: expected 'name@example.com', got '${ph}'`);
    });

    await it('TC_UI_007', 'Verify Password label exists', async () => {
      const label = await driver.findElement(By.xpath("//label[contains(text(),'Password')]"));
      if (!(await label.isDisplayed())) throw new Error('Password label is not displayed');
    });

    await it('TC_UI_008', 'Verify Password input placeholder is masked dots "••••••••"', async () => {
      const passInput = await page.getPasswordInput();
      const ph = await passInput.getAttribute('placeholder');
      if (!ph.includes('••')) throw new Error(`Expected masked placeholder, got '${ph}'`);
    });

    await it('TC_UI_009', 'Verify Sign In button text is "Sign In to Dashboard →"', async () => {
      const btn = await page.getSubmitButton();
      const btnText = await btn.getText();
      if (!btnText.includes('Sign In to Dashboard')) {
        throw new Error(`Button text mismatch: '${btnText}'`);
      }
    });

    await it('TC_UI_010', 'Verify "Create Account" signup link exists and is clickable', async () => {
      const link = await page.getCreateAccountLink();
      if (!(await link.isDisplayed())) throw new Error('Create Account link is not visible');
      const href = await link.getAttribute('href');
      if (!href.includes('signup')) throw new Error(`Link does not point to signup: '${href}'`);
    });

    // ------------------------------------------------------------------------------------------
    // SUITE 2: Input Field & Validation Functional Testing
    // ------------------------------------------------------------------------------------------
    describe('2. Input Field & Validation Functional Testing');

    await it('TC_VAL_001', 'Verify submitting empty form triggers validation', async () => {
      await page.navigate();
      const submitBtn = await page.getSubmitButton();
      await submitBtn.click();
      const emailInput = await page.getEmailInput();
      // HTML5 validation or application error
      const valid = await emailInput.getAttribute('required');
      if (!valid) throw new Error('Email field should be marked required');
    });

    await it('TC_VAL_002', 'Verify submitting invalid email format triggers error', async () => {
      await page.navigate();
      const emailInput = await page.getEmailInput();
      const passInput = await page.getPasswordInput();
      const submitBtn = await page.getSubmitButton();

      // Enter malformed email without @ or domain
      await emailInput.sendKeys('invalid-email-format');
      await passInput.sendKeys('Password123!');
      await submitBtn.click();

      // Check for error banner or HTML5 validation message
      const validationMessage = await emailInput.getAttribute('validationMessage');
      const errorMsg = await page.getErrorMessage();
      if (!validationMessage && !errorMsg) {
        throw new Error('Expected validation error for invalid email format');
      }
    });

    await it('TC_VAL_003', 'Verify submitting empty password triggers validation', async () => {
      await page.navigate();
      const emailInput = await page.getEmailInput();
      const passInput = await page.getPasswordInput();
      const submitBtn = await page.getSubmitButton();

      await emailInput.sendKeys('user@example.com');
      await passInput.clear();
      await submitBtn.click();

      const validationMessage = await passInput.getAttribute('validationMessage');
      const errorMsg = await page.getErrorMessage();
      if (!validationMessage && !errorMsg) {
        throw new Error('Expected validation error for empty password');
      }
    });

    await it('TC_VAL_004', 'Verify password input has type="password" to mask characters', async () => {
      const passInput = await page.getPasswordInput();
      const type = await passInput.getAttribute('type');
      if (type !== 'password') throw new Error(`Password field is not masked! type is '${type}'`);
    });

    await it('TC_VAL_005', 'Verify keyboard TAB order flows logically from Email to Password to Submit', async () => {
      await page.navigate();
      const emailInput = await page.getEmailInput();
      await emailInput.click();
      await emailInput.sendKeys(Key.TAB);

      const activeElement = await driver.switchTo().activeElement();
      const activeType = await activeElement.getAttribute('type');
      if (activeType !== 'password') {
        throw new Error(`Expected focus on Password after Tab from Email, but got type '${activeType}'`);
      }
    });

    // ------------------------------------------------------------------------------------------
    // SUITE 3: Security & Injection Payload Resilience
    // ------------------------------------------------------------------------------------------
    describe('3. Security Payloads & Injection Resilience Testing');

    const injectionPayloads = [
      { name: 'SQL Injection: Single Quote OR', payload: "' OR '1'='1" },
      { name: 'SQL Injection: Admin Comment', payload: "admin' --" },
      { name: 'XSS: Script Alert Tag', payload: "<script>alert('XSS')</script>" },
      { name: 'XSS: SVG OnLoad', payload: "<svg/onload=alert('XSS')>" },
      { name: 'XSS: Image OnError', payload: "<img src=x onerror=alert(1)>" },
      { name: 'Null Byte Injection', payload: "admin\0@example.com" },
    ];

    for (let i = 0; i < injectionPayloads.length; i++) {
      const test = injectionPayloads[i];
      await it(`TC_SEC_00${i + 1}`, `Verify resilience against ${test.name}`, async () => {
        await page.navigate();
        const emailInput = await page.getEmailInput();
        const passInput = await page.getPasswordInput();
        const submitBtn = await page.getSubmitButton();

        await emailInput.sendKeys(test.payload);
        await passInput.sendKeys('SecretPassword123!');
        await submitBtn.click();

        // Ensure no unexpected browser alert popup is triggered by XSS
        try {
          const alert = await driver.switchTo().alert();
          const alertText = await alert.getText();
          await alert.dismiss();
          throw new Error(`XSS payload executed an alert popup! Content: ${alertText}`);
        } catch (e) {
          if (e.message.includes('XSS payload executed')) throw e;
          // No alert is the expected safe behavior!
        }
      });
    }

    // ------------------------------------------------------------------------------------------
    // SUITE 4: Negative Authentication Credential Testing
    // ------------------------------------------------------------------------------------------
    describe('4. Negative Authentication Credential Testing');

    await it('TC_AUTH_001', 'Verify login with unregistered email displays error banner', async () => {
      await page.navigate();
      await page.login('unregistered_user_99999@notexistdomain.com', 'ValidPass123!');
      
      const errorMsg = await page.getErrorMessage();
      if (!errorMsg) {
        throw new Error('Expected error banner for non-existent account');
      }
      if (!errorMsg.toLowerCase().includes('credential') && !errorMsg.toLowerCase().includes('user') && !errorMsg.toLowerCase().includes('wrong') && !errorMsg.toLowerCase().includes('invalid')) {
        throw new Error(`Unexpected error message format: '${errorMsg}'`);
      }
    });

    await it('TC_AUTH_002', 'Verify login with incorrect password displays error banner', async () => {
      await page.navigate();
      await page.login('testaccount@example.com', 'TotallyWrongPassword999!');
      
      const errorMsg = await page.getErrorMessage();
      if (!errorMsg) {
        throw new Error('Expected error banner for incorrect password');
      }
    });

    // ------------------------------------------------------------------------------------------
    // SUITE 5: Navigation & Viewport Responsiveness
    // ------------------------------------------------------------------------------------------
    describe('5. Navigation & Viewport Responsiveness');

    await it('TC_NAV_001', 'Verify clicking "Create Account" navigates to Signup page', async () => {
      await page.navigate();
      const link = await page.getCreateAccountLink();
      await link.click();

      await driver.wait(until.urlContains('signup'), 5000);
      const url = await driver.getCurrentUrl();
      if (!url.includes('signup')) {
        throw new Error(`Expected URL to contain 'signup', but was: ${url}`);
      }
    });

    await it('TC_RESP_001', 'Verify login page layout adapts cleanly to Mobile viewport (375x667)', async () => {
      await driver.manage().window().setRect({ width: 375, height: 667 });
      await page.navigate();

      const emailInput = await page.getEmailInput();
      const submitBtn = await page.getSubmitButton();
      if (!(await emailInput.isDisplayed())) throw new Error('Email input hidden on mobile viewport');
      if (!(await submitBtn.isDisplayed())) throw new Error('Submit button hidden on mobile viewport');
    });

    await it('TC_RESP_002', 'Verify login page layout on Tablet viewport (768x1024)', async () => {
      await driver.manage().window().setRect({ width: 768, height: 1024 });
      await page.navigate();

      const emailInput = await page.getEmailInput();
      if (!(await emailInput.isDisplayed())) throw new Error('Email input hidden on tablet viewport');
    });

    await it('TC_RESP_003', 'Restore Desktop viewport (1280x800)', async () => {
      await driver.manage().window().setRect({ width: 1280, height: 800 });
      await page.navigate();
      const title = await page.getTitleText();
      if (!title.includes('Scam Shield')) throw new Error('Title missing on desktop restore');
    });

  } catch (globalErr) {
    console.error('\x1b[31mFatal E2E Execution Error:\x1b[0m', globalErr.message);
  } finally {
    if (driver) {
      await driver.quit();
    }
  }

  // Summary Metrics
  const durationSec = ((Date.now() - startTime) / 1000).toFixed(2);
  const total = passCount + failCount;
  const passRate = total > 0 ? ((passCount / total) * 100).toFixed(1) : 0;

  console.log(`\n\x1b[35m================================================================`);
  console.log(`   E2E EXECUTION SUMMARY`);
  console.log(`   Total Tests Run: ${total}`);
  console.log(`   Passed:          \x1b[32m${passCount}\x1b[0m`);
  console.log(`   Failed:          \x1b[31m${failCount}\x1b[0m`);
  console.log(`   Pass Rate:       ${passRate}%`);
  console.log(`   Execution Time:  ${durationSec}s`);
  console.log(`================================================================\x1b[0m\n`);

  return { total, passCount, failCount, passRate, durationSec, testResults };
}

// Execute if run directly via CLI
if (require.main === module) {
  runLoginE2eTests()
    .then((summary) => {
      if (summary.failCount > 0) {
        process.exitCode = 1;
      }
    })
    .catch((err) => {
      console.error(err);
      process.exitCode = 1;
    });
}

module.exports = {
  LoginPage,
  runLoginE2eTests,
};
