from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
import os
import fitz  # PyMuPDF
import chromadb
from sentence_transformers import SentenceTransformer

router = APIRouter()

model = SentenceTransformer("all-MiniLM-L6-v2")

chroma_host = os.environ.get("CHROMA_HOST", "localhost")
chroma_port = int(os.environ.get("CHROMA_PORT", 8000))

chroma_client = chromadb.HttpClient(
    host=chroma_host, 
    port=chroma_port)
# chroma_client = chromadb.HttpClient(host="chroma", port=8000)
collection = chroma_client.get_or_create_collection(name="uploaded_docs")

def extract_text_from_pdf(content: bytes) -> str:
    text = ""
    with fitz.open(stream=content, filetype="pdf") as doc:
        for page in doc:
            text += page.get_text()
    return text.strip()

@router.post("/upload", tags=["Upload"])
async def upload_file(file: UploadFile = File(...)):
    content = await file.read()
    text = extract_text_from_pdf(content)
    chunks = [text[i:i+500] for i in range(0, len(text), 500)]

    ids = []
    documents = []

    for i, chunk in enumerate(chunks):
        doc_id = f"{file.filename}_{i}"
        ids.append(doc_id)
        documents.append(chunk)

    embeddings = model.encode(documents).tolist()
    collection.add(documents=documents, embeddings=embeddings, ids=ids)

    return JSONResponse(content={"message": f"Uploaded {file.filename} with {len(chunks)} chunks"})
