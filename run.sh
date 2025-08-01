#!/bin/bash

# Enable verbose output
set -x

# Start Ollama in the background
ollama serve &

# Wait for Ollama to be ready
timeout 60 bash -c 'until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 2
done' || { echo "ERROR: Ollama failed to start within 60 seconds"; exit 1; }

# Check if llama3:8b model exists, pull if not
if ! ollama list | grep -q "llama3:8b"; then
    echo "Pulling llama3:8b model..."
    ollama pull llama3:8b || { echo "ERROR: Failed to pull llama3:8b model"; exit 1; }
else
    echo "llama3:8b model already exists, skipping pull"
fi

# Verify Ollama API
echo "Ollama API tags response:"
curl -s http://localhost:11434/api/tags || { echo "ERROR: Ollama API not responding"; exit 1; }

# Start Gunicorn with gthread workers and increased timeout
poetry run gunicorn --bind 0.0.0.0:8000 --timeout 120 --log-level debug --worker-class gthread app:app
