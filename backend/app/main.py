from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from app import summarizer, embedder, vector_store, file_processor

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    text = file_processor.extract_text(file)
    summary = summarizer.generate_summary(text)
    embedding = embedder.embed_text(summary)
    vector_store.store_vector(embedding, summary)
    return {"summary": summary}

@app.post("/search")
async def search(query: str = Form(...)):
    query_vector = embedder.embed_text(query)
    results = vector_store.search_vector(query_vector)
    return {"results": results}
