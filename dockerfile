# Use a Python base image with Ollama
FROM python:3.10-slim

# Install Ollama
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -f https://storage.googleapis.com/jax-releases/jax_releases.html

# Copy application files
COPY . .

# Copy and make entrypoint.sh executable (for Ollama)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy and make run.sh executable (for Flask/Gunicorn)
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose ports (8000 for Gunicorn, 11434 for Ollama)
EXPOSE 8000 11434

# Start both Ollama and Gunicorn
CMD ["/bin/bash", "-c", "/entrypoint.sh & /app/run.sh"]