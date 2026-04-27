import shutil
import os

src = "/Users/smitbhoir/.gemini/antigravity/brain/118d2959-2ede-4fe5-9a36-acac78796cde/uploaded_media_1770564760559.png"
dst = "assets/ring_user.png"

try:
    shutil.copy(src, dst)
    print(f"Successfully copied {src} to {dst}")
except Exception as e:
    print(f"Error copying file: {e}")
