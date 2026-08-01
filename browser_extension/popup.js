document.addEventListener('DOMContentLoaded', () => {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0] && tabs[0].url) {
            const url = tabs[0].url;
            document.getElementById('currentUrlDisplay').textContent = url;

            fetch('http://127.0.0.1:5000/api/v1/extension/check_url', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: url })
            })
            .then(r => r.json())
            .then(data => {
                const verdict = document.getElementById('verdictStatus');
                if (data.result === 'Dangerous' || data.score >= 5) {
                    verdict.style.color = '#dc2626';
                    verdict.textContent = '🚨 DANGEROUS / PHISHING SITE';
                } else if (data.result === 'Warning') {
                    verdict.style.color = '#d97706';
                    verdict.textContent = '⚠️ SUSPICIOUS WARNING';
                } else {
                    verdict.style.color = '#047857';
                    verdict.textContent = '✅ VERIFIED SAFE CONNECTION';
                }
            })
            .catch(() => {
                document.getElementById('verdictStatus').textContent = '⚡ Shield Active (Offline API)';
            });
        }
    });

    document.getElementById('quickCheckBtn').addEventListener('click', () => {
        const val = document.getElementById('quickInput').value.trim();
        const resDiv = document.getElementById('quickResult');
        if (!val) return;

        resDiv.textContent = "Inspecting threat...";
        fetch('http://127.0.0.1:5000/check_url', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url: val })
        })
        .then(r => r.json())
        .then(data => {
            resDiv.innerHTML = `Result: <b>${data.result}</b> (Score: ${data.score}/25)`;
        })
        .catch(() => {
            resDiv.textContent = "Error checking URL.";
        });
    });
});
