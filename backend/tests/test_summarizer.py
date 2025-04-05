from app import summarizer

def test_generate_summary():
    text = "Cloud computing is the on-demand delivery of IT resources."
    summary = summarizer.generate_summary(text)
    assert isinstance(summary, str)
    assert len(summary) > 0
