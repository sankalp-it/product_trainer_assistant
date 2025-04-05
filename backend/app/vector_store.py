import chromadb
from chromadb.config import Settings

client = chromadb.Client(Settings(chroma_db_impl='duckdb+parquet', persist_directory='./chroma_store'))

collection = client.get_or_create_collection(name="training_summaries")

def store_vector(vector, summary):
    collection.add(
        documents=[summary],
        embeddings=[vector],
        ids=[str(len(collection.peek()['ids']) if collection.peek() else 0)]
    )

def search_vector(query_vector, top_k=3):
    results = collection.query(query_embeddings=[query_vector], n_results=top_k)
    return results['documents'][0] if results['documents'] else []
