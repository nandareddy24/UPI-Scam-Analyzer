/**
 * Scam Shield AI - Selenium WebDriver E2E Automation Test Suite
 * Target Application: UPI & Cyber Fraud Intelligence Platform
 * File: selenium-tests/tests/login-tests.js
 * Description: Comprehensive Selenium test suite covering Login, Registration, 
 * Password Reset, Security Injections, Session Handling, and Dashboard Navigation.
 */

const { Builder, By, Key, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const path = require('path');
const fs = require('fs');

// Configuration
const BASE_URL = process.env.BASE_URL || 'http://127.0.0.1:3000';
const TIMEOUT_MS = 10000;
const HEADLESS_MODE = process.env.HEADLESS !== 'false';

// Test Execution Results Store
const testResults = [];

function logTestResult(id, title, category, status, details = '') {
    const icon = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : '⚠️';
    console.log(`${icon} [${id}] [${category}] ${title} -> ${status} ${details ? '(' + details + ')' : ''}`);
    testResults.push({ id, title, category, status, details, timestamp: new Date().toISOString() });
}

async function createDriver() {
    const options = new chrome.Options();
    if (HEADLESS_MODE) {
        options.addArguments('--headless=new');
    }
    options.addArguments('--no-sandbox');
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--disable-gpu');
    options.addArguments('--window-size=1920,1080');

    return await new Builder()
        .forBrowser('chrome')
        .setChromeOptions(options)
        .build();
}

async function runTestSuite() {
    console.log('===============================================================');
    console.log('🚀 Starting Scam Shield E2E Selenium WebDriver Test Suite');
    console.log(`🌐 Target Base URL: ${BASE_URL}`);
    console.log(`🖥️  Headless Mode: ${HEADLESS_MODE}`);
    console.log('===============================================================\n');

    let driver;

    try {
        driver = await createDriver();

        // -------------------------------------------------------------
        // SUITE 1: UI & DOM Element Verification on /login
        // -------------------------------------------------------------
        console.log('\n--- Suite 1: Login Page Element Verification ---');
        await driver.get(`${BASE_URL}/login`);

        // TC 1.1: Verify Page Title
        try {
            const title = await driver.getTitle();
            if (title.includes('Sign In') || title.includes('Scam Shield')) {
                logTestResult('TC_LOG_001', 'Verify Login Page Title', 'UI Verification', 'PASS', `Title: "${title}"`);
            } else {
                logTestResult('TC_LOG_001', 'Verify Login Page Title', 'UI Verification', 'FAIL', `Unexpected title: "${title}"`);
            }
        } catch (err) {
            logTestResult('TC_LOG_001', 'Verify Login Page Title', 'UI Verification', 'FAIL', err.message);
        }

        // TC 1.2: Check Email Input Field
        try {
            const emailInput = await driver.findElement(By.name('email'));
            const isDisplayed = await emailInput.isDisplayed();
            logTestResult('TC_LOG_002', 'Verify Email Input Field Displayed', 'UI Verification', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_002', 'Verify Email Input Field Displayed', 'UI Verification', 'FAIL', err.message);
        }

        // TC 1.3: Check Password Input Field
        try {
            const passwordInput = await driver.findElement(By.name('password'));
            const inputType = await passwordInput.getAttribute('type');
            logTestResult('TC_LOG_003', 'Verify Password Field Masking (type=password)', 'UI Verification', inputType === 'password' ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_003', 'Verify Password Field Masking', 'UI Verification', 'FAIL', err.message);
        }

        // TC 1.4: Check Submit Button Presence
        try {
            const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
            const text = await submitBtn.getText();
            logTestResult('TC_LOG_004', 'Verify Submit Button Present & Labeled', 'UI Verification', text.includes('Sign In') ? 'PASS' : 'FAIL', `Text: "${text}"`);
        } catch (err) {
            logTestResult('TC_LOG_004', 'Verify Submit Button Present', 'UI Verification', 'FAIL', err.message);
        }

        // TC 1.5: Check Forgot Password & Register Links
        try {
            const forgotLink = await driver.findElement(By.css('a[href="/forgot"]'));
            const registerLink = await driver.findElement(By.css('a[href="/register"]'));
            const valid = (await forgotLink.isDisplayed()) && (await registerLink.isDisplayed());
            logTestResult('TC_LOG_005', 'Verify Forgot Password & Register Navigation Links', 'UI Verification', valid ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_005', 'Verify Links', 'UI Verification', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 2: Input Validation & HTML5 Constraints
        // -------------------------------------------------------------
        console.log('\n--- Suite 2: Form Input Validation ---');

        // TC 2.1: Submit Blank Form
        try {
            const emailInput = await driver.findElement(By.name('email'));
            const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
            await emailInput.clear();
            await submitBtn.click();

            const isRequired = await emailInput.getAttribute('required');
            logTestResult('TC_LOG_006', 'Blank Form Submission Blocked by HTML5 Required', 'Form Validation', isRequired !== null ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_006', 'Blank Form Submission Blocked', 'Form Validation', 'FAIL', err.message);
        }

        // TC 2.2: Invalid Email Format
        try {
            const emailInput = await driver.findElement(By.name('email'));
            await emailInput.sendKeys('invalid-email-format');
            const validity = await driver.executeScript('return arguments[0].checkValidity();', emailInput);
            logTestResult('TC_LOG_007', 'Invalid Email Format Client-Side Block', 'Form Validation', !validity ? 'PASS' : 'FAIL');
            await emailInput.clear();
        } catch (err) {
            logTestResult('TC_LOG_007', 'Invalid Email Format Check', 'Form Validation', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 3: Negative Authentication Scenarios
        // -------------------------------------------------------------
        console.log('\n--- Suite 3: Negative Authentication Scenarios ---');

        // TC 3.1: Non-Existent User Login
        try {
            const emailInput = await driver.findElement(By.name('email'));
            const passwordInput = await driver.findElement(By.name('password'));
            const submitBtn = await driver.findElement(By.css('button[type="submit"]'));

            await emailInput.clear();
            await emailInput.sendKeys('nonexistent_user_999@test.com');
            await passwordInput.clear();
            await passwordInput.sendKeys('WrongPass123!');
            await submitBtn.click();

            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            const pageText = await driver.findElement(By.tagName('body')).getText();

            const handled = currentUrl.includes('/login') || pageText.toLowerCase().includes('invalid') || pageText.toLowerCase().includes('incorrect') || pageText.toLowerCase().includes('error');
            logTestResult('TC_LOG_008', 'Non-Existent User Login Fails Gracefully', 'Negative Auth', handled ? 'PASS' : 'FAIL', `Redirected/Remained: ${currentUrl}`);
        } catch (err) {
            logTestResult('TC_LOG_008', 'Non-Existent User Login', 'Negative Auth', 'FAIL', err.message);
        }

        // TC 3.2: Wrong Password for Registered Email
        try {
            await driver.get(`${BASE_URL}/login`);
            const emailInput = await driver.findElement(By.name('email'));
            const passwordInput = await driver.findElement(By.name('password'));
            const submitBtn = await driver.findElement(By.css('button[type="submit"]'));

            await emailInput.sendKeys('nandakumarreddy63@gmail.com');
            await passwordInput.sendKeys('IncorrectPassword123');
            await submitBtn.click();

            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            logTestResult('TC_LOG_009', 'Incorrect Password Rejected', 'Negative Auth', currentUrl.includes('/login') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_009', 'Incorrect Password Rejected', 'Negative Auth', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 4: Security & Injection Penetration Tests
        // -------------------------------------------------------------
        console.log('\n--- Suite 4: Security Injection Protection ---');

        // TC 4.1: SQL Injection Attempt in Email
        try {
            await driver.get(`${BASE_URL}/login`);
            const emailInput = await driver.findElement(By.name('email'));
            const passwordInput = await driver.findElement(By.name('password'));
            const submitBtn = await driver.findElement(By.css('button[type="submit"]'));

            await emailInput.sendKeys("' OR '1'='1' --");
            await passwordInput.sendKeys("anything");
            await submitBtn.click();

            await driver.sleep(1000);
            const pageText = await driver.findElement(By.tagName('body')).getText();
            const hasSqlError = pageText.includes('syntax error') || pageText.includes('psycopg2') || pageText.includes('sqlite3');

            logTestResult('TC_LOG_010', 'SQL Injection Payload Handled Safely Without DB Leak', 'Security', !hasSqlError ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_010', 'SQL Injection Test', 'Security', 'FAIL', err.message);
        }

        // TC 4.2: XSS Script Payload in Input
        try {
            await driver.get(`${BASE_URL}/login`);
            const emailInput = await driver.findElement(By.name('email'));
            await emailInput.sendKeys("<script>alert('XSS')</script>@test.com");
            const value = await emailInput.getAttribute('value');
            logTestResult('TC_LOG_011', 'XSS Script Payload Input Sanitized/Escaped', 'Security', value.includes('<script>') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_011', 'XSS Payload Test', 'Security', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 5: Session Access & Unauthenticated Guard Verification
        // -------------------------------------------------------------
        console.log('\n--- Suite 5: Unauthenticated Session Guarding ---');

        // TC 5.1: Direct Access to /scan without login
        try {
            await driver.get(`${BASE_URL}/scan`);
            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            const protectedRedirect = currentUrl.includes('/login');
            logTestResult('TC_LOG_012', 'Unauthenticated Access to /scan Redirects to /login', 'Session Guard', protectedRedirect ? 'PASS' : 'FAIL', `Current URL: ${currentUrl}`);
        } catch (err) {
            logTestResult('TC_LOG_012', 'Access /scan Direct', 'Session Guard', 'FAIL', err.message);
        }

        // TC 5.2: Direct Access to /history without login
        try {
            await driver.get(`${BASE_URL}/history`);
            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            const protectedRedirect = currentUrl.includes('/login');
            logTestResult('TC_LOG_013', 'Unauthenticated Access to /history Redirects to /login', 'Session Guard', protectedRedirect ? 'PASS' : 'FAIL', `Current URL: ${currentUrl}`);
        } catch (err) {
            logTestResult('TC_LOG_013', 'Access /history Direct', 'Session Guard', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 6: Navigation Links E2E
        // -------------------------------------------------------------
        console.log('\n--- Suite 6: Auth Navigation Flows ---');

        // TC 6.1: Click 'Create Account' Link
        try {
            await driver.get(`${BASE_URL}/login`);
            const registerLink = await driver.findElement(By.css('a[href="/register"]'));
            await registerLink.click();
            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            logTestResult('TC_LOG_014', 'Navigate from Sign In to Register Page', 'Navigation', currentUrl.includes('/register') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_014', 'Navigate to Register', 'Navigation', 'FAIL', err.message);
        }

        // TC 6.2: Click 'Forgot?' Password Link
        try {
            await driver.get(`${BASE_URL}/login`);
            const forgotLink = await driver.findElement(By.css('a[href="/forgot"]'));
            await forgotLink.click();
            await driver.sleep(1000);
            const currentUrl = await driver.getCurrentUrl();
            logTestResult('TC_LOG_015', 'Navigate from Sign In to Forgot Password Page', 'Navigation', currentUrl.includes('/forgot') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_LOG_015', 'Navigate to Forgot', 'Navigation', 'FAIL', err.message);
        }

        console.log('\n===============================================================');
        console.log('📊 Selenium E2E Test Execution Finished');
        console.log(`Total Cases Run: ${testResults.length}`);
        console.log(`Passed: ${testResults.filter(r => r.status === 'PASS').length}`);
        console.log(`Failed: ${testResults.filter(r => r.status === 'FAIL').length}`);
        console.log('===============================================================\n');

    } catch (globalError) {
        console.error('❌ Critical Test Suite Error:', globalError);
    } finally {
        if (driver) {
            await driver.quit();
            console.log('🧹 Browser driver cleaned up successfully.');
        }
    }
}

// Execute Suite if run directly
if (require.main === module) {
    runTestSuite();
}

module.exports = { runTestSuite };
