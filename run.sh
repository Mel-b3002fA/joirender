#!/bin/bash
PORT=$PORT



# Start Ollama server in the background
echo "Starting Ollama server..."
ollama pull llama3:8b
ollama serve &
# Record the process ID
OLLAMA_PID=$!
# Wait for Ollama to start
sleep 5

# Check if Ollama is running
if ! ps -p $OLLAMA_PID > /dev/null; then
    echo "Error: Ollama server failed to start. Exiting."
    exit 1
else
    echo "Ollama server started with PID $OLLAMA_PID"
fi

# Check for processes on port $PORT
echo "Checking for processes on port $PORT..."
PIDS=$(lsof -ti :$PORT)
if [ -n "$PIDS" ]; then
    echo "Found processes on port $PORT: $PIDS"
    echo "Terminating processes..."
    echo "$PIDS" | xargs kill -9
else
    echo "No processes found on port $PORT"
fi

if lsof -i :$PORT > /dev/null; then
    echo "Error: Port $PORT is still in use. Exiting."
    exit 1
else
    echo "Port $PORT is free."
fi

# Start Gunicorn server
echo "Starting Gunicorn server..."
gunicorn --bind 0.0.0.0:$PORT app:app