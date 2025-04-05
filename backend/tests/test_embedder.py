from app import embedder

def test_embed_text():
    text = "This is a test summary."
    embedding = embedder.embed_text(text)
    assert isinstance(embedding, list)
    assert len(embedding) > 0
