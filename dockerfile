
# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -f https://storage.googleapis.com/jax-releases/jax_releases.html

# Use the official Ollama image as the base

FROM ollama/ollama:latest

# Set the working directory
WORKDIR /app

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Ensure the script is executable
RUN chmod +x /entrypoint.sh

# Expose the default Ollama port
EXPOSE 11434

# Use the entrypoint script to start the container
ENTRYPOINT ["/entrypoint.sh"]