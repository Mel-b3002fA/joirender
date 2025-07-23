#!/bin/bash

# Start Ollama in the background
ollama serve &

# Wait for Ollama to be ready
sleep 5

# Pull Llama3:8b model if not already pulled
ollama pull llama3:8b

# Start Gunicorn for Flask app
poetry run gunicorn --bind 0.0.0.0:8000 app:app