# Use a Python base image
FROM python:3.10-slim

# Install curl and Ollama
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /app

# Copy Poetry files
COPY pyproject.toml poetry.lock* /app/

# Install Poetry and dependencies
RUN pip install poetry==2.1.3 && \
    poetry config virtualenvs.create false && \
    poetry install --no-root

# Copy application files
COPY . .

# Pull LLaMA 3 model during build
RUN ollama pull llama3:8b

# Copy and make run.sh executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose ports (8000 for Gunicorn, 11434 for Ollama)
EXPOSE 8000 11434

# Start Ollama and Gunicorn
CMD ["/app/run.sh"]