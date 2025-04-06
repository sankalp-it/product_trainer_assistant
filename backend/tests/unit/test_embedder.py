from app.core import embedder

def test_embed_text():
    text = "Test input for embedding."
    embedding = embedder.embed_text(text)
    assert isinstance(embedding, list)
    assert len(embedding) > 0
