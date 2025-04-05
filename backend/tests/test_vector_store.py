from app import vector_store

def test_vector_storage_and_search():
    summary = "Test summary for FAISS storage."
    vector = [0.1] * 384
    vector_store.store_vector(vector, summary)
    results = vector_store.search_vector(vector)
    assert summary in results
