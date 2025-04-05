from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse
import chromadb
from sentence_transformers import SentenceTransformer

router = APIRouter()

model = SentenceTransformer("all-MiniLM-L6-v2")
chroma_client = chromadb.HttpClient(host="chroma", port=8000)
collection = chroma_client.get_or_create_collection(name="uploaded_docs")

@router.get("/search", tags=["Search"])
def search_docs(query: str = Query(...)):
    query_vector = model.encode([query])[0].tolist()
    results = collection.query(query_embeddings=[query_vector], n_results=5)
    docs = results.get("documents", [[]])[0]
    scores = results.get("distances", [[]])[0]
    scored_results = [{"text": doc, "score": round(1 - score, 4)} for doc, score in zip(docs, scores)]
    return JSONResponse(content={"query": query, "results": scored_results})
