from pymongo import MongoClient
import hashlib
from datetime import datetime
import dns.resolver
import os
from dotenv import load_dotenv

# Load environment variables from backend/.env file
load_dotenv(os.path.join(os.path.dirname(__file__), 'backend', '.env'))

# --- CONFIGURATION ---
MONGO_URI = os.getenv('MONGODB_URI')
DB_NAME = os.getenv('MONGODB_NAME', 'colletral_ar')

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def create_admin():
    print(f"Connecting to MongoDB Atlas...")
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db["users"]

    username = "admin@perfios.com"
    password = "Perfios@123"
    
    # Check if user already exists
    if collection.find_one({"username": username}):
        print(f"Error: User {username} already exists!")
        return

    new_user = {
        "username": username,
        "password": hash_password(password),
        "name": "Srujan",
        "organization": "AdminOrg",
        "customer": "MainCustomer",
        "role": "Admin",
        "status": "Active",
        "created": datetime.now().strftime("%b %d, %Y")
    }

    collection.insert_one(new_user)
    print(f"Successfully created Admin user!")
    print(f"Username: {username}")
    print(f"Password: {password}")
    print(f"You can now log in at your Vercel Admin Portal.")

if __name__ == "__main__":
    create_admin()
