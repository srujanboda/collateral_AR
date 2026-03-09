from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

def get_db_handle():
    # Try multiple common environment variable names
    mongo_uri = os.getenv('MONGODB_URI') or os.getenv('MONGO_URL') or os.getenv('DATABASE_URL')
    db_name = os.getenv('MONGODB_NAME', "colletral_ar")
    
    if not mongo_uri:
        # If still missing in cloud, we have a configuration problem
        print("WARNING: MONGODB_URI not found in environment. Falling back to localhost.")
        mongo_uri = "mongodb://localhost:27017/"
    else:
        # Mask the URI for security in logs but show the start
        masked = mongo_uri[:15] + "..."
        print(f"Connecting to MongoDB using URI: {masked}")

    client = MongoClient(mongo_uri)
    db = client[db_name]
    return db
