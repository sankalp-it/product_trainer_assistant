import chromadb
import time
import os

def get_chroma_client(retries=30, delay=5):
    host = os.getenv("CHROMA_HOST", "chroma")
    port = int(os.getenv("CHROMA_PORT", 8000))
    print(f"[DEBUG] Connecting to Chroma at {host}:{port}")

    for attempt in range(retries):
        try:
            print(f"[DEBUG] Attempt {attempt + 1}...")
            client = chromadb.HttpClient(host=host, port=port)
            print("[DEBUG] Successfully connected to Chroma")
            return client
        except Exception as e:
            print(f"Retry {attempt + 1}/{retries} failed: {e}")
            time.sleep(delay)
    raise ConnectionError("Failed to connect to ChromaDB after multiple attempts")

def get_collection(name="training_summaries"):
    client = get_chroma_client()
    return client.get_or_create_collection(name=name)

def store_vector(vector, summary):
    collection = get_collection()
    current_ids = collection.peek().get('ids', []) if collection.peek() else []
    next_id = str(len(current_ids))
    collection.add(
        documents=[summary],
        embeddings=[vector],
        ids=[next_id]
    )

def search_vector(query_vector, top_k=3):
    collection = get_collection()
    results = collection.query(query_embeddings=[query_vector], n_results=top_k)
    return results['documents'][0] if results['documents'] else []
