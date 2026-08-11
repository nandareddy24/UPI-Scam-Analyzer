/**
 * Scam Shield AI - Appium Mobile E2E Test Suite Entry Point
 * File: appium-tests/appium-tests.js
 */

const { runAppiumTestSuite } = require('./tests/mobile-app-tests');

if (require.main === module) {
    runAppiumTestSuite();
}

module.exports = { runAppiumTestSuite };
