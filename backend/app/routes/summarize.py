from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse

router = APIRouter()

@router.get("/summarize", tags=["Summarize"])
def summarize(query: str = Query(...)):
    # Dummy summary
    return JSONResponse(content={"summary": f"Summary for: {query}"})
