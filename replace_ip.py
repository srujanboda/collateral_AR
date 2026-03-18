import os

directory = r"c:\Users\91767\journey-1_updated"
old_ip = "10.84.153.247"
new_ip = "10.84.153.247"

exclude_dirs = ['node_modules', '.git', '__pycache__', '.dart_tool', 'build', '.venv', 'venv']

for root, dirs, files in os.walk(directory):
    # Skip excluded directories
    dirs[:] = [d for d in dirs if d not in exclude_dirs]
    for file in files:
        path = os.path.join(root, file)
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            if old_ip in content:
                print(f"Replacing in {path}")
                new_content = content.replace(old_ip, new_ip)
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
        except Exception as e:
            pass
