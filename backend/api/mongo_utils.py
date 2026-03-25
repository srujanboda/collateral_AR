from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

def get_db_handle():
    mongo_uri = os.getenv('MONGODB_URI', 'mongodb://localhost:27017/')
    db_name = os.getenv('MONGODB_NAME', 'colletral_ar')
    
    print(f"Connecting to MongoDB with URI starting: {mongo_uri[:15]}...")
    print(f"Using Database: {db_name}")
    client = MongoClient(mongo_uri)
    db = client[db_name]
    return db
