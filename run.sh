#!/bin/bash

# Start Ollama
ollama serve &

# Wait for Ollama to be ready
sleep 2

# Pull Llama3:8b model
ollama pull llama3:8b

# Start Gunicorn for Flask app
poetry run gunicorn --bind 0.0.0.0:8000 app:app