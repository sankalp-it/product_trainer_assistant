from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import health, upload, search, summarize

app = FastAPI(title="AI Summary Assistant", description="Docs for PDF upload, search and summarization API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(upload.router)
app.include_router(search.router)
app.include_router(summarize.router)
