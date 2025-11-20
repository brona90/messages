import os
import shutil
from bs4 import BeautifulSoup

# --- CONFIGURATION ---
html_file = r"/Users/888973/Library/CloudStorage/OneDrive-Cognizant/Desktop/predating/steph_messages.html"   # path to your HTML file
destination_folder = r"/Users/888973/Library/CloudStorage/OneDrive-Cognizant/Desktop/predating/images"  # where to copy images
updated_html_file = r"/Users/888973/Library/CloudStorage/OneDrive-Cognizant/Desktop/predating/updated.html"    # output HTML file

# --- SCRIPT ---
os.makedirs(destination_folder, exist_ok=True)

# Read HTML file
with open(html_file, "r", encoding="utf-8") as f:
    soup = BeautifulSoup(f, "html.parser")

def process_link(link_value, attr_name, tag):
    if not link_value:
        return
    file_path = os.path.abspath(link_value)
    if os.path.exists(file_path):
        try:
            # Copy file to destination
            shutil.copy(file_path, destination_folder)
            filename = os.path.basename(file_path)
            new_path = os.path.join(destination_folder, filename)
            # Update HTML tag attribute
            tag[attr_name] = new_path
            print(f"Copied and updated: {file_path} -> {new_path}")
        except Exception as e:
            print(f"Error copying {file_path}: {e}")
    else:
        print(f"File not found: {file_path}")

# Update <img src="...">
for img in soup.find_all("img"):
    process_link(img.get("src"), "src", img)

# Update <a href="..."> if they point to images
for a in soup.find_all("a"):
    href = a.get("href")
    if href and href.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
        process_link(href, "href", a)

# Write updated HTML
with open(updated_html_file, "w", encoding="utf-8") as f:
    f.write(str(soup))

print("HTML updated and saved to:", updated_html_file)

 