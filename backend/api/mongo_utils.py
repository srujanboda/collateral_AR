from pymongo import MongoClient
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

def get_db_handle():
    mongo_uri = os.getenv('MONGODB_URI', "mongodb://localhost:27017/")
    db_name = os.getenv('MONGODB_NAME', "colletral_ar")
    client = MongoClient(mongo_uri)
    db = client[db_name]
    return db
