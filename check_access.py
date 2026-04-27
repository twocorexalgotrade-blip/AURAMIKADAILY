import os
path = "/Users/smitbhoir/.gemini/antigravity/brain/118d2959-2ede-4fe5-9a36-acac78796cde/uploaded_media_1770564760559.png"
exists = os.path.exists(path)
print(f"File exists: {exists}")
if exists:
    try:
        with open(path, 'rb') as f:
            print("Successfully opened file")
    except Exception as e:
        print(f"Failed to open file: {e}")
