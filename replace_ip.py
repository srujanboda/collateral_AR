import os
import re

# ==========================================
# ONLY CHANGE THIS IP ADDRESS
# ==========================================
NEW_IP = "192.168.1.37"
# ==========================================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Pattern to find old local IPs (e.g., 10.x.x.x, 192.168.x.x)
# This will match most local network IP patterns
IP_PATTERN = re.compile(r'10\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+')

EXCLUDE_DIRS = ['node_modules', '.git', '__pycache__', '.dart_tool', 'build', '.venv', 'env', 'staticfiles']
EXCLUDE_FILES = ['replace_ip.py', 'sync_ip.py', 'package-lock.json']

def update_ips():
    print(f"--- Starting Global IP Update to: {NEW_IP} ---")
    
    count = 0
    for root, dirs, files in os.walk(BASE_DIR):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        
        for file in files:
            if file in EXCLUDE_FILES:
                continue
                
            path = os.path.join(root, file)
            
            # Only check relevant file types
            if not any(file.endswith(ext) for ext in ['.ts', '.tsx', '.dart', '.env', '.py', '.js']):
                continue
                
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if IP_PATTERN.search(content):
                    # Check if it actually needs changing (avoid unnecessary writes)
                    new_content = IP_PATTERN.sub(NEW_IP, content)
                    if new_content != content:
                        print(f"Updating: {path.replace(BASE_DIR, '')}")
                        with open(path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        count += 1
            except Exception as e:
                # print(f"Could not process {path}: {e}")
                pass

    print(f"\n--- Update Finished! ---")
    print(f"Total files updated: {count}")
    print(f"Make sure to restart your servers and the Flutter app.")

if __name__ == "__main__":
    update_ips()
