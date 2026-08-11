const API_ENDPOINT = "http://127.0.0.1:3000/api/v1/extension/check_url";
const safeCache = new Set();
const threatCache = new Map();

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === 'loading' && tab.url) {
        inspectUrl(tabId, tab.url);
    }
});

chrome.tabs.onActivated.addListener((activeInfo) => {
    chrome.tabs.get(activeInfo.tabId, (tab) => {
        if (tab && tab.url) {
            inspectUrl(tab.id, tab.url);
        }
    });
});

async function inspectUrl(tabId, url) {
    if (!url || url.startsWith("chrome://") || url.startsWith("edge://") || url.startsWith("about:") || url.includes("127.0.0.1:3000")) {
        return;
    }

    try {
        const domain = new URL(url).hostname;
        if (safeCache.has(domain)) {
            updateExtensionBadge(tabId, "SAFE");
            return;
        }

        if (threatCache.has(domain)) {
            const cachedThreat = threatCache.get(domain);
            triggerWarning(tabId, cachedThreat);
            return;
        }

        const response = await fetch(API_ENDPOINT, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ url: url })
        });

        if (!response.ok) return;

        const data = await response.json();
        
        if (data.result === 'Dangerous' || data.score >= 5) {
            threatCache.set(domain, data);
            triggerWarning(tabId, data);
        } else if (data.result === 'Warning') {
            updateExtensionBadge(tabId, "WARN");
        } else {
            safeCache.add(domain);
            updateExtensionBadge(tabId, "SAFE");
        }

    } catch (e) {
        console.log("ScamShield Extension Error:", e);
    }
}

function triggerWarning(tabId, data) {
    updateExtensionBadge(tabId, "DANGER");
    chrome.tabs.sendMessage(tabId, {
        action: "SHOW_THREAT_WARNING",
        threatData: data
    }).catch(() => {
        // Content script might not be loaded yet; retry after brief delay
        setTimeout(() => {
            chrome.tabs.sendMessage(tabId, {
                action: "SHOW_THREAT_WARNING",
                threatData: data
            }).catch(() => {});
        }, 500);
    });
}

function updateExtensionBadge(tabId, status) {
    if (status === "DANGER") {
        chrome.action.setBadgeBackgroundColor({ tabId: tabId, color: "#DC2626" });
        chrome.action.setBadgeText({ tabId: tabId, text: "!" });
    } else if (status === "WARN") {
        chrome.action.setBadgeBackgroundColor({ tabId: tabId, color: "#D97706" });
        chrome.action.setBadgeText({ tabId: tabId, text: "?" });
    } else {
        chrome.action.setBadgeBackgroundColor({ tabId: tabId, color: "#059669" });
        chrome.action.setBadgeText({ tabId: tabId, text: "✓" });
    }
}

// Handle messages from content.js or popup.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "GET_CURRENT_THREAT") {
        const domain = request.domain;
        sendResponse(threatCache.get(domain) || null);
    }
});
