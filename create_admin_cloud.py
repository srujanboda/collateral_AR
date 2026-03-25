from pymongo import MongoClient
import hashlib
from datetime import datetime
import dns.resolver

# --- CONFIGURATION ---
# Paste your MongoDB URI here (the one with %40 for the password)
MONGO_URI = "mongodb+srv://backend:xocCvwzsoVhUQ5Si@cluster0.hdigfky.mongodb.net/journey_prod?appName=Cluster0"
DB_NAME = "journey_prod"

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def create_admin():
    print(f"Connecting to MongoDB Atlas...")
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db["users"]

    username = "srujanboda14@gmail.com"
    password = "AdminPassword123"
    
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
