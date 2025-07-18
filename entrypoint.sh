#!/bin/bash
# Start Ollama in the background
ollama serve &
# Record the process ID
pid=$!
# Wait for Ollama to start
sleep 5
# Pull the LLaMA 3 model
echo "Pulling LLaMA 3 model..."
ollama pull llama3
echo "LLaMA 3 model pulled successfully!"
# Wait for the Ollama process to finish
wait $pid