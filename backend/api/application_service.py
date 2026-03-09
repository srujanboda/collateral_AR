from .mongo_utils import get_db_handle
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
def get_applicant_collection():
    from .mongo_utils import get_db_handle
    db = get_db_handle()
    return db["applicants"]

import os
import shutil
import random
import string
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile

def broadcast_application_update(message):
    try:
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'applicants',
            {
                'type': 'applicant_update',
                'message': message
            }
        )
    except Exception as e:
        print(f"Failed to broadcast update: {e}")

def generate_unique_perfios_id():
    while True:
        # Simple generation: PERF- followed by 4 random digits
        pid = "PERF-" + "".join(random.choices(string.digits, k=4))
        if not get_applicant_collection().find_one({"perfios_id": pid}):
            return pid

def generate_applicant_id():
    # Generate random applicant ID (not unique, just a reference)
    # Format: APP-XXXXX (5 random digits)
    return "APP-" + "".join(random.choices(string.digits, k=5))

#---------------------applicant create----------------------#
def create_application(data):
    # data: {name, email, phone_number}
    perfios_id = generate_unique_perfios_id()
    applicant_id = generate_applicant_id()
    
    new_app = {
        "name": data.get("name"),
        "email": data.get("email"),
        "email_status": "Pending",
        "phone_number": data.get("phone_number"),
        "address": data.get("address"),
        "pincode": data.get("pincode"),
        "city": data.get("city"),
        "state": data.get("state"),
        "district": data.get("district"),
        "country": data.get("country"),
        "applicant_id": applicant_id,
        "perfios_id": perfios_id,
        "status": "Pending",
    }
    
    get_applicant_collection().insert_one(new_app.copy())
    broadcast_application_update({"action": "create", "perfios_id": perfios_id})
    return new_app

#---------------------applicant list----------------------#
def list_applications():
    applicants = list(get_applicant_collection().find({}, {"_id": 0}))
    return applicants

#---------------------applicant update----------------------#
def update_application(perfios_id, updates):
    # updates: dict of fields to change
    result = get_applicant_collection().update_one({"perfios_id": perfios_id}, {"$set": updates})
    if result.modified_count > 0:
        broadcast_application_update({"action": "update", "perfios_id": perfios_id, "updates": updates})
    return result.modified_count > 0

#---------------------applicant get by id----------------------#
def get_application_by_id(perfios_id):
    applicant = get_applicant_collection().find_one({"perfios_id": perfios_id}, {"_id": 0})
    return applicant

#---------------------cascade delete----------------------#
def cascade_delete_application(perfios_id):
    applicant = get_applicant_collection().find_one({"perfios_id": perfios_id})
    if not applicant:
        return False, "Application not found", 0
    
    # Delete all uploaded files from disk
    deleted_files_count = 0
    for doc in applicant.get('documents', []):
        for file_path in doc.get('files', []):
            if default_storage.exists(file_path):
                default_storage.delete(file_path)
                deleted_files_count += 1
                print(f"[CASCADE DELETE] Deleted file: {file_path}")
    
    # Delete the entire applicant folder
    applicant_folder = os.path.join(default_storage.location, 'documents', perfios_id)
    if os.path.exists(applicant_folder):
        shutil.rmtree(applicant_folder)
        print(f"[CASCADE DELETE] Deleted folder: {applicant_folder}")
    
    # Delete from MongoDB
    result = get_applicant_collection().delete_one({"perfios_id": perfios_id})
    if result.deleted_count > 0:
        return True, "Application and all files deleted successfully", deleted_files_count
    
    return False, "Failed to delete application from database", deleted_files_count

#--------------------Document uploading logic---------------------------#
def handle_document_upload(perfios_id, step_id, files):
    existing_applicant = get_applicant_collection().find_one({"perfios_id": perfios_id})
    if not existing_applicant:
        return None, "Applicant not found"
    
    # Find old files for this specific step
    old_file_paths = []
    for doc in existing_applicant.get('documents', []):
        if doc.get('step_id') == str(step_id):
            old_file_paths = doc.get('files', [])
            break
    
    # Save new files to disk
    new_file_paths = []
    for file in files:
        file_path = f"documents/{perfios_id}/{step_id}/{file.name}"
        actual_path = default_storage.save(file_path, ContentFile(file.read()))
        new_file_paths.append(actual_path)

    # Find orphaned files (old files NOT in new files)
    orphaned_files = set(old_file_paths) - set(new_file_paths)
    
    # Delete orphaned files from disk
    deleted_count = 0
    for orphaned_path in orphaned_files:
        if default_storage.exists(orphaned_path):
            default_storage.delete(orphaned_path)
            deleted_count += 1
            print(f"[CLEANUP] Deleted orphaned file: {orphaned_path}")
    
    # Update MongoDB - Replace or Add
    if old_file_paths:
        get_applicant_collection().update_one(
            {"perfios_id": perfios_id, "documents.step_id": str(step_id)},
            {
                "$set": {
                    "status": "In Progress",
                    "documents.$.files": new_file_paths
                }
            }
        )
        action = "updated"
    else:
        get_applicant_collection().update_one(
            {"perfios_id": perfios_id},
            {
                "$set": {"status": "In Progress"},
                "$push": {
                    "documents": {
                        "step_id": str(step_id),
                        "files": new_file_paths
                    }
                }
            }
        )
        action = "created"
    
    broadcast_application_update({"action": "document_upload", "perfios_id": perfios_id, "step_id": step_id})

    return {
        'message': f'Files {action} successfully',
        'status': 'In Progress',
        'file_paths': new_file_paths,
        'deleted_files': deleted_count
    }, None

#--------------------Journey Completion---------------------------#
def complete_application(perfios_id):
    result = get_applicant_collection().update_one(
        {"perfios_id": perfios_id},
        {"$set": {"status": "Success"}}
    )
    
    if result.modified_count > 0:
        broadcast_application_update({"action": "complete", "perfios_id": perfios_id})
        return True, "Journey completed successfully, status updated to Success"
    
    # Check if it was already success
    app = get_applicant_collection().find_one({"perfios_id": perfios_id})
    if app and app.get('status') == 'Success':
        return True, "Status already Success"
        
    return False, "Applicant not found"

#--------------------Field Media Upload (Flutter App)---------------------------#
def handle_media_upload(files, perfios_id=None, email=None, submission_address=None, latitude=None, longitude=None):
    # Look up the applicant by perfios_id or email
    if perfios_id:
        existing_applicant = get_applicant_collection().find_one({"perfios_id": perfios_id})
    elif email:
        existing_applicant = get_applicant_collection().find_one({"email": email})
    else:
        return None, "perfios_id or email is required"

    if not existing_applicant:
        return None, "Applicant not found"

    # Use the applicant's actual perfios_id for storage
    applicant_pid = existing_applicant["perfios_id"]

    saved_paths = []
    for file in files:
        # Sanitize filename
        safe_name = file.name.replace(" ", "_")
        file_path = f"field_media/{applicant_pid}/{safe_name}"
        actual_path = default_storage.save(file_path, ContentFile(file.read()))
        saved_paths.append(actual_path)

    # Update verification_location and append to field_media array in MongoDB
    update_data = {
        "$push": {"field_media": {"$each": saved_paths}}
    }
    
    if submission_address or latitude or longitude:
        update_data["$set"] = {
            "verification_location": {
                "address": submission_address,
                "latitude": latitude,
                "longitude": longitude
            }
        }

    get_applicant_collection().update_one(
        {"perfios_id": applicant_pid},
        update_data
    )

    broadcast_application_update({"action": "media_upload", "perfios_id": applicant_pid})

    return {
        "message": "Media uploaded successfully",
        "files": saved_paths,
        "count": len(saved_paths)
    }, None
