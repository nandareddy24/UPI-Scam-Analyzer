import os
import sqlite3

def init_database():
    """
    Standalone script to initialize the database (PostgreSQL or SQLite fallback).
    Creates required tables and inserts initial default blacklist data.
    """
    db_host = os.getenv("DB_HOST")
    db_name = os.getenv("DB_NAME")
    
    conn = None
    db_type = None

    # Try PostgreSQL first if environment variables exist
    if db_host and db_name:
        try:
            import psycopg2
            conn = psycopg2.connect(
                host=db_host,
                port=os.getenv("DB_PORT", "5432"),
                database=db_name,
                user=os.getenv("DB_USER"),
                password=os.getenv("DB_PASSWORD")
            )
            db_type = "postgres"
            print("[OK] Connected to PostgreSQL Database")
        except Exception as e:
            print("[WARN] PostgreSQL connection failed:", str(e))
            print("[WARN] Falling back to SQLite...")

    # SQLite Fallback
    if not conn:
        db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "database.db")
        conn = sqlite3.connect(db_path)
        db_type = "sqlite"
        print(f"[OK] Connected to SQLite Database ({db_path})")

    cursor = conn.cursor()
    pk_type = "INTEGER PRIMARY KEY AUTOINCREMENT" if db_type == "sqlite" else "SERIAL PRIMARY KEY"

    # Create Users table
    cursor.execute(f"""
    CREATE TABLE IF NOT EXISTS users (
        id {pk_type},
        name VARCHAR(255),
        email VARCHAR(255) UNIQUE,
        password TEXT
    )
    """)

    # Create Blacklist table
    cursor.execute(f"""
    CREATE TABLE IF NOT EXISTS blacklist (
        id {pk_type},
        data TEXT,
        type VARCHAR(50),
        reason TEXT
    )
    """)

    # Create Scans table
    cursor.execute(f"""
    CREATE TABLE IF NOT EXISTS scans (
        id {pk_type},
        user_id INTEGER,
        type VARCHAR(50),
        input_data TEXT,
        score INTEGER,
        result VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # Create Community Reports table
    cursor.execute(f"""
    CREATE TABLE IF NOT EXISTS community_reports (
        id {pk_type},
        user_id INTEGER,
        type VARCHAR(50),
        input_data TEXT,
        reason TEXT,
        status VARCHAR(50) DEFAULT 'Pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    conn.commit()
    print("[OK] All database tables created/verified.")

    # Check if blacklist has initial items, seed default items if empty
    param_placeholder = "?" if db_type == "sqlite" else "%s"
    cursor.execute("SELECT COUNT(*) FROM blacklist")
    count = cursor.fetchone()[0]

    if count == 0:
        default_blacklist = [
            ("scam-lottery-win.com", "URL", "Phishing domain impersonating lottery winner"),
            ("fake-bank-login.net", "URL", "Credential harvesting bank login clone"),
            ("scamuser@ybl", "UPI", "Reported fraudulent UPI ID"),
            ("pay-cash-reward@paytm", "UPI", "Fake cashback UPI handle"),
            ("Claim your free Rs 5000 reward now at http://bit.ly/scam123", "SMS", "Phishing SMS claiming fake rewards")
        ]

        query = f"INSERT INTO blacklist (data, type, reason) VALUES ({param_placeholder}, {param_placeholder}, {param_placeholder})"
        cursor.executemany(query, default_blacklist)
        conn.commit()
        print(f"[OK] Inserted {len(default_blacklist)} default items into blacklist table.")
    else:
        print(f"[INFO] Blacklist already contains {count} items.")

    conn.close()
    print("[SUCCESS] Database setup completed successfully!")

if __name__ == "__main__":
    init_database()
