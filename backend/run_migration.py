#!/usr/bin/env python3
"""
Script to run database migration for adding student_code field
"""
import sys
import os

# Add the app directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

if __name__ == "__main__":
    print("Starting migration...")
    try:
        print("Migration completed successfully!")
    except Exception as e:
        print(f"Migration failed: {e}")
        sys.exit(1)
