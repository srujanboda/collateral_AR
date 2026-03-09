from pymongo import MongoClient
import hashlib
from datetime import datetime

# --- CONFIGURATION ---
# Paste your MongoDB URI here (the one with %40 for the password)
MONGO_URI = "mongodb+srv://Srujan:Srujan%401403@cluster1.zpdjouh.mongodb.net/?appName=Cluster1"
DB_NAME = "colletral_ar"

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
