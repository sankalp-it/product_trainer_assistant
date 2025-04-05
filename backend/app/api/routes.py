from fastapi import APIRouter, UploadFile, File, Form
from app.core import summarizer, embedder, vector_store, file_processor
from fastapi.responses import JSONResponse

router = APIRouter(tags=["AI Summary API"])

@router.get("/health", tags=["Health"])
def health_check():
    return JSONResponse(content={"status": "ok"}, status_code=200)

@router.post("/upload", summary="Upload a PDF and generate a summary")
async def upload_file(file: UploadFile = File(...)):
    text = file_processor.extract_text(file)
    summary = summarizer.generate_summary(text)
    embedding = embedder.embed_text(summary)
    vector_store.store_vector(embedding, summary)
    return {"summary": summary}

@router.post("/search", summary="Semantic search across training summaries")
async def search(query: str = Form(...)):
    query_vector = embedder.embed_text(query)
    results = vector_store.search_vector(query_vector)
    return {"results": results}
