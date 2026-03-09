from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

def get_db_handle():
    # Detect environment variables more aggressively
    # Check for MONGODB_URI, MONGO_URI, MONGO_URL, DATABASE_URL
    mongo_uri = (
        os.environ.get('MONGODB_URI') or 
        os.environ.get('MONGO_URI') or 
        os.environ.get('MONGO_URL') or 
        os.environ.get('DATABASE_URL')
    )
    
    db_name = os.environ.get('MONGODB_NAME', "colletral_ar")
    
    if not mongo_uri:
        # Diagnostic: what keys DO we have?
        keys = list(os.environ.keys())
        # Filter out anything super sensitive just in case, but keep names
        safe_keys = [k for k in keys if "PASS" not in k and "SECRET" not in k]
        error_msg = f"MISSING DATABASE URI. Available env keys: {', '.join(safe_keys)}"
        # For the 500 details, we throw an exception with this info
        raise Exception(error_msg)
    
    print(f"Connecting to MongoDB with URI starting: {mongo_uri[:15]}...")
    client = MongoClient(mongo_uri)
    db = client[db_name]
    return db
