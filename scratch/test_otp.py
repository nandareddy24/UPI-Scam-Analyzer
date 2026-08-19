import os
import json
import time

# Test database connection and OTP verification logic locally
os.environ["REQUIRE_POSTGRES"] = "false"

from app import db, cursor, save_db_otp, verify_db_otp, api_register

print("--- TESTING DATABASE-BACKED OTP FLOW ---")
print(f"Database Type: {db.db_type}")

email = "test_user_otp@example.com"
otp = "123456"
payload = {"name": "Test User", "password": "password123"}

# Test 1: Save DB OTP
saved = save_db_otp(email, "registration", otp, payload)
print(f"Save OTP Result: {saved}")
assert saved == True, "save_db_otp failed"

# Test 2: Verify Invalid OTP
success, msg, data = verify_db_otp(email, "registration", "999999")
print(f"Verify Wrong OTP: success={success}, msg='{msg}'")
assert success == False, "Wrong OTP should fail"

# Test 3: Verify Correct OTP
success, msg, data = verify_db_otp(email, "registration", "123456")
print(f"Verify Correct OTP: success={success}, msg='{msg}', payload={data}")
assert success == True, "Correct OTP should succeed"
assert data["name"] == "Test User", "Payload name mismatch"

# Test 4: Re-using used OTP should fail
success, msg, data = verify_db_otp(email, "registration", "123456")
print(f"Verify Re-used OTP: success={success}, msg='{msg}'")
assert success == False, "Re-used OTP should fail"

print("\nAll DB-backed OTP tests passed successfully!")
