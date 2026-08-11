// ScamShield Content Script - Real-Time In-Page Threat Overlay
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "SHOW_THREAT_WARNING") {
        injectThreatOverlay(request.threatData);
    }
});

function injectThreatOverlay(threatData) {
    if (document.getElementById("scamshield-overlay-frame")) return;

    const overlay = document.createElement("div");
    overlay.id = "scamshield-overlay-frame";
    overlay.style.cssText = `
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        background-color: rgba(15, 23, 42, 0.95) !important;
        backdrop-filter: blur(8px) !important;
        z-index: 2147483647 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
        color: #ffffff !important;
        padding: 20px !important;
        box-sizing: border-box !important;
    `;

    const score = threatData.score || 10;
    const reason = threatData.reason || "Phishing or malicious website detected in ScamShield global threat registry.";
    const advice = threatData.advice || "Do NOT enter banking credentials, UPI PINs, or sensitive information on this portal.";

    overlay.innerHTML = `
        <div style="
            background: #ffffff;
            color: #0f172a;
            max-width: 600px;
            width: 100%;
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            border-left: 8px solid #dc2626;
            text-align: left;
            box-sizing: border-box;
        ">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="width: 48px; height: 48px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: bold;">
                        ⚠️
                    </div>
                    <div>
                        <span style="background: #fee2e2; color: #991b1b; padding: 4px 10px; border-radius: 9999px; font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em;">
                            CRITICAL SECURITY WARNING
                        </span>
                        <h2 style="font-size: 22px; font-weight: 800; margin: 4px 0 0 0; color: #0f172a;">Malicious Website Blocked</h2>
                    </div>
                </div>
                <div style="text-align: right;">
                    <span style="font-size: 10px; font-weight: 800; color: #64748b; text-transform: uppercase;">Threat Score</span>
                    <div style="font-size: 24px; font-weight: 900; color: #dc2626;">${score} <span style="font-size: 12px; font-weight: 400; color: #94a3b8;">/ 25</span></div>
                </div>
            </div>

            <p style="font-size: 13px; color: #475569; line-height: 1.6; margin-bottom: 20px;">
                ScamShield Real-Time Browser Guard has intercepted this connection because it exhibits signs of financial fraud, credential phishing, or blacklisted malware.
            </p>

            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; padding: 14px; margin-bottom: 16px;">
                <div style="font-size: 11px; font-weight: 700; color: #475569; text-transform: uppercase; margin-bottom: 4px;">Detection Reason</div>
                <div style="font-size: 12px; font-weight: 600; color: #1e293b;">${reason}</div>
            </div>

            <div style="background: #fef2f2; border: 1px solid #fecaca; border-radius: 14px; padding: 14px; margin-bottom: 24px;">
                <div style="font-size: 11px; font-weight: 700; color: #991b1b; text-transform: uppercase; margin-bottom: 4px;">Recommended Action</div>
                <div style="font-size: 12px; font-weight: 600; color: #7f1d1d;">💡 ${advice}</div>
            </div>

            <div style="display: flex; flex-direction: column; gap: 10px;">
                <button id="scamshield-btn-safe" style="
                    background: #14532d;
                    color: #ffffff;
                    border: none;
                    padding: 14px 20px;
                    border-radius: 14px;
                    font-size: 13px;
                    font-weight: 700;
                    cursor: pointer;
                    width: 100%;
                    box-shadow: 0 4px 12px rgba(20, 83, 45, 0.3);
                ">
                    🛡️ Go Back to Safety (Recommended)
                </button>

                <div style="display: flex; gap: 10px;">
                    <button id="scamshield-btn-details" style="
                        background: #f1f5f9;
                        color: #0f172a;
                        border: 1px solid #cbd5e1;
                        padding: 10px 14px;
                        border-radius: 12px;
                        font-size: 11px;
                        font-weight: 600;
                        cursor: pointer;
                        flex: 1;
                    ">
                        🔍 View Threat Details
                    </button>

                    <button id="scamshield-btn-ignore" style="
                        background: transparent;
                        color: #94a3b8;
                        border: 1px solid #e2e8f0;
                        padding: 10px 14px;
                        border-radius: 12px;
                        font-size: 11px;
                        font-weight: 600;
                        cursor: pointer;
                        flex: 1;
                    ">
                        Proceed Anyway (Not Recommended)
                    </button>
                </div>
            </div>
        </div>
    `;

    document.body.appendChild(overlay);

    document.getElementById("scamshield-btn-safe").addEventListener("click", () => {
        if (window.history.length > 1) {
            window.history.back();
        } else {
            window.location.href = "https://google.com";
        }
    });

    document.getElementById("scamshield-btn-details").addEventListener("click", () => {
        window.open("http://127.0.0.1:3000/history", "_blank");
    });

    document.getElementById("scamshield-btn-ignore").addEventListener("click", () => {
        overlay.remove();
    });
}
