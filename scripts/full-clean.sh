#!/bin/bash

echo "🧹 Stopping all Docker containers related to summary project..."
docker ps -a --format '{{.ID}} {{.Names}}' | grep summary | awk '{print $1}' | xargs -r docker rm -f

echo "🧼 Removing all Docker volumes for summary project..."
docker volume ls --format '{{.Name}}' | grep summary | xargs -r docker volume rm

echo "🗑️ Pruning all dangling containers, images, networks, and volumes..."
docker system prune -a --volumes -f

echo "✅ Clean complete. You can now rebuild and restart with:"
echo "   make build-dev && make up"
