import requests
import os
import json

BASE_URL = os.getenv("BASE_URL", "https://upi-scam-analyzer.onrender.com")
TEST_EMAIL = os.getenv("TEST_EMAIL")
TEST_PASSWORD = os.getenv("TEST_PASSWORD")

def test_health():
    print(f"Testing Health: {BASE_URL}/api/v1/health")
    try:
        r = requests.get(f"{BASE_URL}/api/v1/health")
        print(f"Status: {r.status_code}")
        print(f"Body: {r.text}")
    except Exception as e:
        print(f"Error: {e}")

def test_login():
    if not TEST_EMAIL or not TEST_PASSWORD:
        print("Skipping login test: TEST_EMAIL or TEST_PASSWORD not set")
        return

    print(f"Testing Login: {BASE_URL}/api/v1/auth/login")
    payload = {"email": TEST_EMAIL, "password": TEST_PASSWORD}
    try:
        r = requests.post(f"{BASE_URL}/api/v1/auth/login", json=payload)
        print(f"Status: {r.status_code}")
        if r.status_code == 200:
            print("Login Successful")
            # print(f"Token: {r.json().get('token')}") # Avoid printing token
        else:
            print(f"Login Failed: {r.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_health()
    print("-" * 20)
    test_login()
