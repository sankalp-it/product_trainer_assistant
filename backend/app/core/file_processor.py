import pdfplumber
from tempfile import NamedTemporaryFile
from fastapi import UploadFile

def extract_text(file: UploadFile) -> str:
    with NamedTemporaryFile(delete=False) as tmp:
        tmp.write(file.file.read())
        tmp_path = tmp.name

    with pdfplumber.open(tmp_path) as pdf:
        text = "\n".join([page.extract_text() or "" for page in pdf.pages])
    return text
