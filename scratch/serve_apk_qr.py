import os
import sys
import http.server
import socketserver
import threading

# Try importing qrcode, install if needed or use pyqrcode/PIL
try:
    import qrcode
except ImportError:
    os.system(f"{sys.executable} -m pip install qrcode pillow")
    import qrcode

local_ip = "192.168.31.243"
port = 8080
download_url = f"http://{local_ip}:{port}/app-release.apk"

# 1. Generate QR code image
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(download_url)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
artifact_dir = r"C:\Users\DELL\.gemini\antigravity-ide\brain\0ba94b82-650f-49d1-a9fa-48aa5a4d9256"
qr_path = os.path.join(artifact_dir, "apk_qr.png")
img.save(qr_path)
print(f"[OK] QR Code saved to {qr_path}")
print(f"[OK] Download URL: {download_url}")

# 2. Serve APK on local HTTP server
apk_dir = r"C:\Users\DELL\Documents\UPI-Scam-Analyzer\flutter_app\build\app\outputs\flutter-apk"
os.chdir(apk_dir)

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

Handler = QuietHandler
httpd = socketserver.TCPServer(("0.0.0.0", port), Handler)
print(f"[OK] HTTP Server running on http://0.0.0.0:{port}...")
httpd.serve_forever()
