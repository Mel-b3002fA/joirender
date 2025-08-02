# Use a slim Python base image
FROM python:3.10-slim

# Debug: Confirm dockerfile is being used
RUN echo "Starting dockerfile build for joisquashed..."

# Install system dependencies for Ollama
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama with retry logic
RUN for i in 1 2 3; do curl -fsSL https://ollama.com/install.sh | sh && break || sleep 5; done

# Set working directory
WORKDIR /app

# Install Poetry with retry logic
RUN for i in 1 2 3; do pip install --no-cache-dir poetry==2.1.3 && break || sleep 5; done

# Copy Poetry files and install dependencies
COPY pyproject.toml poetry.lock* ./
RUN poetry config virtualenvs.create false && poetry install --only main --no-root --no-interaction --no-ansi

# Debug: List files in build context
RUN echo "Listing files in build context..." && \
    ls -la

# Debug: Check for .dockerignore
RUN echo "Checking for .dockerignore..." && \
    [ -f .dockerignore ] && cat .dockerignore || echo "No .dockerignore found"

# Copy run.sh explicitly and debug
COPY run.sh /app/run.sh
RUN echo "Checking run.sh after copy..." && \
    ls -l /app/run.sh || { echo "ERROR: run.sh not found at /app/run.sh"; exit 1; } && \
    cat /app/run.sh && \
    chmod +x /app/run.sh && \
    echo "run.sh permissions set"

# Copy remaining application files
COPY . .

# Verify run.sh after full copy
RUN echo "Verifying run.sh after COPY . . ..." && \
    ls -l /app/run.sh || { echo "ERROR: run.sh missing after COPY . ."; exit 1; } && \
    cat /app/run.sh

# Expose ports (8000 for Gunicorn, 11434 for Ollama)
EXPOSE 8000 11434

# Start Ollama and Gunicorn via run.sh
CMD ["/app/run.sh"]
