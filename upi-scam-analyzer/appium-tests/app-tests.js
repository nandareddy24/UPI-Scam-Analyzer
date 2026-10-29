/**
 * Entry point alias for Appium mobile E2E test execution.
 * Directs execution to tests/app-tests.js
 */
const { runMobileAppiumTests } = require('./tests/app-tests.js');

if (require.main === module) {
  runMobileAppiumTests()
    .then((res) => {
      if (res.failCount > 0) process.exitCode = 1;
    })
    .catch((err) => {
      console.error(err);
      process.exitCode = 1;
    });
}

module.exports = require('./tests/app-tests.js');
