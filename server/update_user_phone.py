#!/usr/bin/env python3
"""
Utility script to update user phone numbers for WhatsApp integration.
"""
import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Add the app directory to path
sys.path.insert(0, os.path.dirname(__file__))

from app.models.user import User
from app.database import Base

# Load environment variables
load_dotenv()

# Create database engine
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def list_users():
    """List all users in the database"""
    db = SessionLocal()
    try:
        users = db.query(User).all()
        print("\n📋 Users in database:")
        print("-" * 80)
        for user in users:
            print(f"ID: {user.id} | Name: {user.name} | Email: {user.email} | Phone: {user.phone_number}")
        print("-" * 80)
        print(f"Total users: {len(users)}\n")
    finally:
        db.close()

def update_phone_number(user_id: int, phone_number: str):
    """Update phone number for a user"""
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        
        if not user:
            print(f"❌ User with ID {user_id} not found!")
            return False
        
        old_phone = user.phone_number
        user.phone_number = phone_number
        db.commit()
        
        print(f"✅ Updated user {user.name} (ID: {user_id})")
        print(f"   Old phone: {old_phone}")
        print(f"   New phone: {phone_number}")
        return True
    except Exception as e:
        db.rollback()
        print(f"❌ Error updating phone number: {e}")
        return False
    finally:
        db.close()

def main():
    print("\n🔧 Kronyx User Phone Number Manager\n")
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  List users:        python update_user_phone.py list")
        print("  Update phone:      python update_user_phone.py <user_id> <phone_number>")
        print("\nExample:")
        print("  python update_user_phone.py 1 +919482698406")
        print("  (Use international format with + prefix)")
        return
    
    command = sys.argv[1]
    
    if command.lower() == "list":
        list_users()
    elif len(sys.argv) == 3:
        try:
            user_id = int(sys.argv[1])
            phone_number = sys.argv[2]
            
            # Validate phone format
            if not phone_number.startswith('+'):
                print("⚠️  Warning: Phone number should start with + (international format)")
                print("   Example: +919482698406 for India")
                confirm = input("   Continue anyway? (y/n): ")
                if confirm.lower() != 'y':
                    return
            
            list_users()
            update_phone_number(user_id, phone_number)
            print("\n📱 User can now send WhatsApp messages to track expenses!")
            
        except ValueError:
            print("❌ User ID must be a number!")
    else:
        print("❌ Invalid arguments. Use 'list' or provide user_id and phone_number")

if __name__ == "__main__":
    main()
