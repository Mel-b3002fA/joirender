#!/bin/bash

# Start Ollama in the background
ollama serve &

# Wait for Ollama to be ready
until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 2
done

# Check if llama3:8b model exists, pull if not
if ! ollama list | grep -q "llama3:8b"; then
    echo "Pulling llama3:8b model..."
    ollama pull llama3:8b
else
    echo "llama3:8b model already exists, skipping pull"
fi

# Start Gunicorn for Flask app
poetry run gunicorn --bind 0.0.0.0:8000 app:app