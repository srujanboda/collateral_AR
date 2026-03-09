from api.user_service import create_user
import os
import django
from dotenv import load_dotenv

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

def seed():
    print("Seeding database...")
    
    # Create default admin user
    username = "administrator@perfios.com"
    password = "Admin@123"
    name = "Administrator"
    organization = "Perfios"
    customer = "Internal"
    
    user, error = create_user(username, password, name, organization, customer, role="Admin")
    
    if error:
        print(f"Error: {error}")
    else:
        print(f"Created user: {username}")
        print(f"Password: {password}")
    
    print("Seeding complete!")

if __name__ == "__main__":
    seed()
