import os
import requests

PDF_FOLDER = './sample_data'
UPLOAD_ENDPOINT = 'http://localhost:8000/upload'

for filename in os.listdir(PDF_FOLDER):
    if filename.endswith('.pdf'):
        filepath = os.path.join(PDF_FOLDER, filename)
        print(f'Uploading {filename}...')
        with open(filepath, 'rb') as f:
            files = {'file': (filename, f, 'application/pdf')}
            response = requests.post(UPLOAD_ENDPOINT, files=files)
            if response.status_code == 200:
                print('Uploaded and summarized:', response.json()['summary'][:100], '...')
            else:
                print('Failed to upload:', response.status_code)
