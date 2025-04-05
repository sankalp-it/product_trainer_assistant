import time
import chromadb
from chromadb.config import Settings
from app.config import CHROMA_HOST, CHROMA_PORT
import logging

logger = logging.getLogger(__name__)
client = None
MAX_RETRIES = 5

for attempt in range(MAX_RETRIES):
    try:
        client = chromadb.HttpClient(host=CHROMA_HOST, port=CHROMA_PORT)
        break
    except Exception as e:
        logger.warning(f"ChromaDB connection failed (attempt {attempt + 1}): {e}")
        time.sleep(2)
else:
    raise ConnectionError("Failed to connect to ChromaDB after multiple attempts")

collection = client.get_or_create_collection(name="training_summaries")

def store_vector(vector: list[float], summary: str) -> None:
    collection.add(
        documents=[summary],
        embeddings=[vector],
        ids=[str(len(collection.peek()['ids']) if collection.peek() else 0)]
    )

def search_vector(query_vector: list[float], top_k: int = 3) -> list[str]:
    results = collection.query(query_embeddings=[query_vector], n_results=top_k)
    return results['documents'][0] if results['documents'] else []
