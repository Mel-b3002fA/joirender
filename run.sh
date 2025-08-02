#!/bin/bash

# Enable verbose output
set -x

# === Configuration ===
# Default to "phi3:mini" if not provided via environment
PHI_MODEL=${PHI_MODEL:-"phi3:mini"}
OLLAMA_LOG=/app/ollama.log

# Create or touch log file
touch "$OLLAMA_LOG"

# Start Ollama in the background and log output
ollama serve >> "$OLLAMA_LOG" 2>&1 &

# Wait up to 120s for Ollama to be ready
timeout 120 bash -c 'until curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "Waiting for Ollama to start..."
    cat '"$OLLAMA_LOG"'
    sleep 2
done' || { echo "ERROR: Ollama failed to start within 120 seconds"; cat "$OLLAMA_LOG"; exit 1; }

# Pull specified model if not present
if ! ollama list | grep -q "$PHI_MODEL"; then
    echo "Pulling model: $PHI_MODEL..."
    ollama pull "$PHI_MODEL" >> "$OLLAMA_LOG" 2>&1 || { echo "ERROR: Failed to pull $PHI_MODEL model"; cat "$OLLAMA_LOG"; exit 1; }
    echo "Model pull completed. Listing models:"
    ollama list
else
    echo "$PHI_MODEL model already exists, skipping pull"
fi

# Check Ollama API
echo "Ollama API tags response:"
curl -s http://localhost:11434/api/tags || { echo "ERROR: Ollama API not responding"; cat "$OLLAMA_LOG"; exit 1; }

# Start Gunicorn
poetry run gunicorn --bind 0.0.0.0:8000 --timeout 120 --log-level debug --worker-class gthread app:app
