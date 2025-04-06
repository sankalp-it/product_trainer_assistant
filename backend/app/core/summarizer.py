import subprocess

def generate_summary(text: str) -> str:
    prompt = f"Summarize this:\n{text}"
    result = subprocess.run(["ollama", "run", "mistral"], input=prompt.encode(), stdout=subprocess.PIPE)
    return result.stdout.decode().strip()
