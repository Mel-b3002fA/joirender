#!/bin/bash

# Diagnostic script to investigate why run.sh fails in Render deployment

echo "=== Diagnostic Script for run.sh Failure ==="

# Step 1: Verify run.sh in repository
echo "Checking for run.sh in repository root..."
if [ -f "run.sh" ]; then
    echo "Found run.sh"
    ls -l run.sh
else
    echo "ERROR: run.sh not found in repository root"
    exit 1
fi

# Step 2: Check .gitignore for exclusions
echo "Checking .gitignore for run.sh exclusions..."
if [ -f ".gitignore" ]; then
    if grep -E "run.sh|\*.sh" .gitignore; then
        echo "WARNING: .gitignore excludes run.sh or *.sh"
    else
        echo "No run.sh or *.sh exclusions in .gitignore"
    fi
else
    echo "No .gitignore file found"
fi

# Step 3: Verify run.sh in git tracked files
echo "Checking if run.sh is tracked by git..."
if git ls-files | grep -q "run.sh"; then
    echo "run.sh is tracked by git"
else
    echo "ERROR: run.sh is not tracked by git"
    exit 1
fi

# Step 4: Check Dockerfile for run.sh copy
echo "Checking Dockerfile for run.sh copy..."
if [ -f "Dockerfile" ]; then
    if grep -q "COPY run.sh /app/run.sh" Dockerfile; then
        echo "Dockerfile includes COPY run.sh /app/run.sh"
    else
        echo "WARNING: Dockerfile does not include COPY run.sh /app/run.sh"
    fi
    if grep -q "CMD \[\"/app/run.sh\"\]" Dockerfile; then
        echo "Dockerfile includes CMD [\"/app/run.sh\"]"
    else
        echo "WARNING: Dockerfile does not include CMD [\"/app/run.sh\"]"
    fi
else
    echo "ERROR: Dockerfile not found"
    exit 1
fi

# Step 5: Suggest manual Docker inspection
echo "=== Manual Docker Inspection (if Docker is installed) ==="
echo "Docker is not installed locally, so container inspection is skipped."
echo "To verify /app/run.sh in the container:"
echo "1. Install Docker: https://docs.docker.com/get-docker/"
echo "2. Run the following commands:"
echo "   docker build -t my-app ."
echo "   docker run -it my-app /bin/bash"
echo "   ls /app  # Should show run.sh"
echo "If run.sh is missing, the COPY step in the Dockerfile is failing."

echo "=== Diagnostic Complete ==="
echo "If issues persist, ensure run.sh is committed and the Dockerfile is correct."
echo "Push changes and redeploy on Render."