#!/bin/bash

# Enable verbose output
set -x

# Create log file for Ollama
OLLAMA_LOG=/app/ollama.log
touch $OLLAMA_LOG

# Start Ollama in the background and redirect output to log
ollama serve >> $OLLAMA_LOG 2>&1 &

# Wait for Ollama to be ready (increased timeout to 120 seconds)
timeout 120 bash -c 'until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    cat $OLLAMA_LOG
    sleep 2
done' || { echo "ERROR: Ollama failed to start within 120 seconds"; cat $OLLAMA_LOG; exit 1; }

if ! ollama list | grep -q "phi3:mini"; then
    echo "Pulling phi3:mini model..."
    ollama pull phi3:mini >> $OLLAMA_LOG 2>&1 || { echo "ERROR: Failed to pull phi3:mini model"; cat $OLLAMA_LOG; exit 1; }
    echo "Model pull completed. Listing models:"
    ollama list
else
    echo "phi3:mini model already exists, skipping pull"
fi

# Verify Ollama API
echo "Ollama API tags response:"
curl -s http://localhost:11434/api/tags || { echo "ERROR: Ollama API not responding"; cat $OLLAMA_LOG; exit 1; }

# Start Gunicorn with gthread workers
poetry run gunicorn --bind 0.0.0.0:8000 --timeout 120 --log-level debug --worker-class gthread app:app
