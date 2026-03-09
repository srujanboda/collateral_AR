from .mongo_utils import get_db_handle
import hashlib
import random
import string
from datetime import datetime

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def get_user_collection():
    db = get_db_handle()
    return db["users"]

def generate_random_password(length=10):
    # Ensure at least one uppercase and one digit to pass validation
    uppercase = random.choice(string.ascii_uppercase)
    digit = random.choice(string.digits)
    others = "".join(random.choices(string.ascii_letters + string.digits, k=length-2))
    password = uppercase + digit + others
    # Shuffle for randomness
    pw_list = list(password)
    random.shuffle(pw_list)
    return "".join(pw_list)

def create_user(username, password, name, organization, customer, role="Admin"):
    collection = get_user_collection()
    # Check if user already exists
    if collection.find_one({"username": username}):
        return None, "User already exists"
    
    new_user = {
        "username": username,
        "password": hash_password(password),
        "name": name,
        "organization": organization,
        "customer": customer,
        "role": role,
        "status": "Active",
        "created": datetime.now().strftime("%b %d, %Y")
    }
    collection.insert_one(new_user)
    return new_user, None

def update_password(username, new_password):
    collection = get_user_collection()
    result = collection.update_one(
        {"username": username},
        {"$set": {"password": hash_password(new_password)}}
    )
    return result.modified_count > 0

def update_user(username, data):
    collection = get_user_collection()
    # Prevent password update via this method
    if "password" in data:
        del data["password"]
    result = collection.update_one({"username": username}, {"$set": data})
    return result.modified_count > 0

def authenticate_user(username, password):
    collection = get_user_collection()
    user = collection.find_one({"username": username})
    if user and user["password"] == hash_password(password):
        return user
    return None

def list_users():
    collection = get_user_collection()
    return list(collection.find({}, {"_id": 0, "password": 0}))

def delete_user(username):
    collection = get_user_collection()
    result = collection.delete_one({"username": username})
    return result.deleted_count > 0
