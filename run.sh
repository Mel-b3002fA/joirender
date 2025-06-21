
# lsof -ti:8000 | xargs kill -9 2>/dev/null


# python server.py


PORT=8000


if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
else
    echo "Virtual environment already activated: $VIRTUAL_ENV"
fi


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

echo "Starting Flask server..."
python server.py