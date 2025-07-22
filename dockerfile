# Use a slim Python base image
FROM python:3.10-slim

# Install system dependencies for Ollama
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry==2.1.3

# Copy Poetry files and install dependencies
COPY pyproject.toml poetry.lock* ./
RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction --no-ansi

# Copy application files
COPY . .

# Copy and make run.sh executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose ports (8000 for Gunicorn, 11434 for Ollama)
EXPOSE 8000 11434

# Start Ollama and Gunicorn via run.sh
CMD ["/run.sh"]