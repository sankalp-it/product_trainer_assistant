#!/bin/bash
set -e

echo "🧹 Cleaning up Docker containers, volumes, and images..."
./scripts/full-clean.sh

echo "📦 Pulling Ollama model (mistral)..."
ollama pull mistral || echo "⚠️ Ollama not installed or mistral already pulled."

echo "🔧 Building Docker images..."
docker-compose build

echo "🚀 Starting the app..."
docker-compose up -d

echo "✅ All services are up and running:"
echo "   ➤ Frontend: http://localhost:3000"
echo "   ➤ Backend Docs: http://localhost:8000/docs"
echo "   ➤ Chroma Health: http://localhost:8001/api/v1/heartbeat"
