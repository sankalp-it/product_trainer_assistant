from fastapi import APIRouter
from fastapi.responses import JSONResponse
from app.vector_store import get_chroma_client

router = APIRouter()

@router.get("/health", tags=["Health"])
def health_check():
    try:
        client = get_chroma_client()
        _ = client.list_collections()
        return JSONResponse(content={"status": "ok"}, status_code=200)
    except Exception as e:
        return JSONResponse(content={"status": "error", "details": str(e)}, status_code=503)
