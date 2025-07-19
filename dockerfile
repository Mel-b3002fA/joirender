# Use a Python base image with root access
FROM python:3.10-slim

# Install curl and Ollama as root
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://ollama.com/install.sh | sh && \
    ollama pull llama3:8b

# Set working directory
WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy Poetry files and install dependencies
COPY pyproject.toml poetry.lock* ./
RUN poetry config virtualenvs.create false && poetry install --no-root

# Copy application files
COPY . .

# Copy and make run.sh executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose ports (8000 for Gunicorn, 11434 for Ollama)
EXPOSE 8000 11434

# Start Ollama and Gunicorn via run.sh
CMD ["/app/run.sh"]