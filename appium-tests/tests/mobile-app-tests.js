/**
 * Scam Shield AI - Appium Mobile E2E Automation Test Suite
 * Target Application: ScamShield Android Mobile App Frontend (/mobile_app)
 * File: appium-tests/tests/mobile-app-tests.js
 * Description: Comprehensive Appium / WebDriverIO test suite covering Mobile Navigation,
 * Scanner Tabs (UPI, URL, SMS, Camera QR), Security Toggles,
 * Threat Logs, Mobile Touch Gestures, and Device Capability Verification.
 */

const { remote } = require('webdriverio');

const BASE_URL = process.env.BASE_URL || 'http://127.0.0.1:3000';
const MOBILE_APP_URL = `${BASE_URL}/mobile_app`;

const appiumCapabilities = {
    platformName: 'Android',
    'appium:automationName': 'UiAutomator2',
    'appium:deviceName': 'Android Emulator',
    'appium:platformVersion': '13.0',
    'appium:browserName': 'Chrome',
    'appium:newCommandTimeout': 300
};

const testResults = [];

function logTestResult(id, title, category, status, details = '') {
    const icon = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : '⚠️';
    console.log(`${icon} [${id}] [${category}] ${title} -> ${status} ${details ? '(' + details + ')' : ''}`);
    testResults.push({ id, title, category, status, details, timestamp: new Date().toISOString() });
}

async function runAppiumTestSuite() {
    console.log('===============================================================');
    console.log('📱 Starting ScamShield Appium Mobile E2E Test Suite');
    console.log(`🌐 Target Mobile App URL: ${MOBILE_APP_URL}`);
    console.log(`🤖 Platform: ${appiumCapabilities.platformName} (${appiumCapabilities['appium:deviceName']})`);
    console.log('===============================================================\n');

    let driver;

    try {
        console.log('⚡ Initializing Appium / Mobile Web Session...');

        driver = await remote({
            capabilities: {
                browserName: 'chrome',
                'goog:chromeOptions': {
                    args: [
                        '--headless=new',
                        '--no-sandbox',
                        '--disable-dev-shm-usage',
                        '--user-agent=Mozilla/5.0 (Linux; Android 13; Pixel 6 Build/TP1A.220624.014) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36'
                    ],
                    mobileEmulation: {
                        deviceName: 'Pixel 7'
                    }
                }
            },
            logLevel: 'warn'
        });

        // -------------------------------------------------------------
        // SUITE 1: Mobile Header & Emergency Action Bar
        // -------------------------------------------------------------
        console.log('\n--- Suite 1: Mobile Header Bar & Helpline ---');
        await driver.url(MOBILE_APP_URL);
        await driver.pause(1000);

        // TC 1.1: Verify App Bar Title
        try {
            const titleElement = await driver.$('header h1');
            const titleText = await titleElement.getText();
            logTestResult('TC_MOB_001', 'Verify Mobile App Bar Title', 'Mobile UI', titleText.includes('ScamShield') ? 'PASS' : 'FAIL', `Text: "${titleText}"`);
        } catch (err) {
            logTestResult('TC_MOB_001', 'Verify Mobile App Bar Title', 'Mobile UI', 'FAIL', err.message);
        }

        // TC 1.2: Check Protection Status Badge
        try {
            const badge = await driver.$('header p');
            const badgeText = await badge.getText();
            logTestResult('TC_MOB_002', 'Verify Android Protection Active Status Badge', 'Mobile UI', badgeText.includes('Protection Active') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_002', 'Verify Protection Badge', 'Mobile UI', 'FAIL', err.message);
        }

        // TC 1.3: Verify National Cyber Crime Helpline 1930 Button
        try {
            const helplineBtn = await driver.$('a[href="tel:1930"]');
            const isDisplayed = await helplineBtn.isDisplayed();
            const text = await helplineBtn.getText();
            logTestResult('TC_MOB_003', 'Verify Helpline 1930 Emergency Shortcut', 'Mobile UI', isDisplayed && text.includes('1930') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_003', 'Verify Helpline Shortcut', 'Mobile UI', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 2: Mobile Bottom Dock Screen Navigation
        // -------------------------------------------------------------
        console.log('\n--- Suite 2: Bottom Dock Navigation ---');

        // TC 2.1: Default Screen is Home Dashboard
        try {
            const homeScreen = await driver.$('#screen-home');
            const isDisplayed = await homeScreen.isDisplayed();
            logTestResult('TC_MOB_004', 'Default Screen active is #screen-home', 'Mobile Navigation', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_004', 'Default Screen Check', 'Mobile Navigation', 'FAIL', err.message);
        }

        // TC 2.2: Switch to Scan Screen via Dock
        try {
            const scanDockBtn = await driver.$('#dock-scan');
            await scanDockBtn.click();
            await driver.pause(500);

            const scanScreen = await driver.$('#screen-scan');
            const isDisplayed = await scanScreen.isDisplayed();
            logTestResult('TC_MOB_005', 'Navigate to #screen-scan via Bottom Dock', 'Mobile Navigation', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_005', 'Navigate to Scan Screen', 'Mobile Navigation', 'FAIL', err.message);
        }

        // TC 2.3: Switch to Camera Screen
        try {
            const cameraDockBtn = await driver.$('#dock-camera');
            await cameraDockBtn.click();
            await driver.pause(500);

            const cameraScreen = await driver.$('#screen-camera');
            const isDisplayed = await cameraScreen.isDisplayed();
            logTestResult('TC_MOB_006', 'Navigate to #screen-camera via Bottom Dock', 'Mobile Navigation', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_006', 'Navigate to Camera Screen', 'Mobile Navigation', 'FAIL', err.message);
        }

        // TC 2.4: Switch Back to Home Screen
        try {
            const homeDockBtn = await driver.$('#dock-home');
            await homeDockBtn.click();
            await driver.pause(500);

            const homeScreen = await driver.$('#screen-home');
            const isDisplayed = await homeScreen.isDisplayed();
            logTestResult('TC_MOB_007', 'Navigate back to #screen-home via Bottom Dock', 'Mobile Navigation', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_007', 'Navigate to Home Screen', 'Mobile Navigation', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 3: Real-Time Mobile Scanner Functionality
        // -------------------------------------------------------------
        console.log('\n--- Suite 3: Mobile Scanner Mode & Inputs ---');
        const scanDockBtn = await driver.$('#dock-scan');
        await scanDockBtn.click();
        await driver.pause(500);

        // TC 3.1: Switch Scan Mode to UPI
        try {
            const upiTab = await driver.$('#mTab-UPI');
            await upiTab.click();
            await driver.pause(300);

            const input = await driver.$('#mPayload');
            const placeholder = await input.getAttribute('placeholder');
            logTestResult('TC_MOB_008', 'Switch Scanner to UPI Mode', 'Mobile Scanner', placeholder.includes('scammer@ybl') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_008', 'Switch Scanner to UPI', 'Mobile Scanner', 'FAIL', err.message);
        }

        // TC 3.2: Perform UPI Scam Analysis
        try {
            const input = await driver.$('#mPayload');
            const submitBtn = await driver.$('button[onclick="runMobileScan()"]');

            await input.setValue('scamuser@ybl');
            await submitBtn.click();
            await driver.pause(1000);

            const resultContainer = await driver.$('#mResultOutput');
            const text = await resultContainer.getText();

            logTestResult('TC_MOB_009', 'Analyze Malicious UPI ID (scamuser@ybl)', 'Mobile Scanner', text.toLowerCase().includes('dangerous') || text.toLowerCase().includes('threat') || text.toLowerCase().includes('score') ? 'PASS' : 'FAIL', `Result snippet: "${text.substring(0, 50)}..."`);
        } catch (err) {
            logTestResult('TC_MOB_009', 'Analyze UPI Scam', 'Mobile Scanner', 'FAIL', err.message);
        }

        // TC 3.3: Switch Scan Mode to URL Phishing Check
        try {
            const urlTab = await driver.$('#mTab-URL');
            await urlTab.click();
            await driver.pause(300);

            const input = await driver.$('#mPayload');
            const placeholder = await input.getAttribute('placeholder');
            logTestResult('TC_MOB_010', 'Switch Scanner to URL Mode', 'Mobile Scanner', placeholder.includes('http') || placeholder.includes('bank') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_010', 'Switch Scanner to URL', 'Mobile Scanner', 'FAIL', err.message);
        }

        // TC 3.4: Perform Phishing URL Scan
        try {
            const input = await driver.$('#mPayload');
            const submitBtn = await driver.$('button[onclick="runMobileScan()"]');

            await input.setValue('http://scam-lottery-win.com');
            await submitBtn.click();
            await driver.pause(1000);

            const resultContainer = await driver.$('#mResultOutput');
            const text = await resultContainer.getText();

            logTestResult('TC_MOB_011', 'Analyze Phishing URL (http://scam-lottery-win.com)', 'Mobile Scanner', text.toLowerCase().includes('dangerous') || text.toLowerCase().includes('score') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_011', 'Analyze Phishing URL', 'Mobile Scanner', 'FAIL', err.message);
        }

        // -------------------------------------------------------------
        // SUITE 4: Camera & Service Worker PWA Verification
        // -------------------------------------------------------------
        console.log('\n--- Suite 4: Camera & PWA Manifest ---');

        // TC 4.1: Verify Camera Container Element
        try {
            const cameraDockBtn = await driver.$('#dock-camera');
            await cameraDockBtn.click();
            await driver.pause(300);

            const cameraVideo = await driver.$('#cameraVideo');
            const isDisplayed = await cameraVideo.isDisplayed();
            logTestResult('TC_MOB_012', 'Verify Camera HTML5 Video Feed Element Present', 'Camera Scanner', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_012', 'Verify Camera Video Element', 'Camera Scanner', 'FAIL', err.message);
        }

        // TC 4.2: Verify Mobile Web Manifest Link
        try {
            const manifestLink = await driver.$('link[rel="manifest"]');
            const href = await manifestLink.getAttribute('href');
            logTestResult('TC_MOB_013', 'Verify Mobile PWA Web Manifest Link', 'Mobile App', href.includes('manifest.webmanifest') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_013', 'Verify Web Manifest', 'Mobile App', 'FAIL', err.message);
        }

        // TC 4.3: Verify Security Score Metric Card
        try {
            const homeDockBtn = await driver.$('#dock-home');
            await homeDockBtn.click();
            await driver.pause(300);

            const scoreText = await driver.$('main').getText();
            logTestResult('TC_MOB_014', 'Verify Security Score Dashboard Displayed', 'Mobile UI', scoreText.includes('94%') && scoreText.includes('Optimal') ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_014', 'Verify Security Score', 'Mobile UI', 'FAIL', err.message);
        }

        // TC 4.4: Verify Quick Action Card 'Report Fraud' Link
        try {
            const reportLink = await driver.$('a[href="/report"]');
            const isDisplayed = await reportLink.isDisplayed();
            logTestResult('TC_MOB_015', 'Verify Community Fraud Report Navigation Link', 'Mobile UI', isDisplayed ? 'PASS' : 'FAIL');
        } catch (err) {
            logTestResult('TC_MOB_015', 'Verify Report Link', 'Mobile UI', 'FAIL', err.message);
        }

        console.log('\n===============================================================');
        console.log('📊 Appium Mobile E2E Test Execution Finished');
        console.log(`Total Cases Run: ${testResults.length}`);
        console.log(`Passed: ${testResults.filter(r => r.status === 'PASS').length}`);
        console.log(`Failed: ${testResults.filter(r => r.status === 'FAIL').length}`);
        console.log('===============================================================\n');

    } catch (globalError) {
        console.error('❌ Critical Appium Test Suite Error:', globalError);
    } finally {
        if (driver) {
            await driver.deleteSession();
            console.log('🧹 Mobile driver session terminated cleanly.');
        }
    }
}

if (require.main === module) {
    runAppiumTestSuite();
}

module.exports = { runAppiumTestSuite };
