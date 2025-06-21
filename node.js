// server.js
const express = require('express');
const { spawn } = require('child_process');
const http = require('http');
const path = require('path');

const app = express();
const port = 3000;

// Serve static files (including chat.html)
app.use(express.static(path.join(__dirname)));

// Middleware to parse JSON requests
app.use(express.json());

// Function to check if Ollama is running
function checkOllamaStatus() {
    return new Promise((resolve) => {
        const req = http.get('http://localhost:11434', (res) => {
            resolve(res.statusCode === 200);
        });
        req.on('error', () => resolve(false));
        req.end();
    });
}

// Function to start Ollama server
function startOllama() {
    return new Promise((resolve, reject) => {
        const ollamaProcess = spawn('ollama', ['serve'], { stdio: 'inherit' });

        ollamaProcess.on('error', (err) => {
            reject(new Error(`Failed to start Ollama: ${err.message}`));
        });

        // Wait a few seconds to check if Ollama started successfully
        setTimeout(async () => {
            const isRunning = await checkOllamaStatus();
            if (isRunning) {
                resolve('Ollama server started successfully');
            } else {
                reject(new Error('Ollama server failed to start'));
            }
        }, 3000); // Adjust delay if needed
    });
}

// Endpoint to ensure Ollama is running
app.get('/start-ollama', async (req, res) => {
    try {
        const isRunning = await checkOllamaStatus();
        if (isRunning) {
            return res.json({ status: 'running' });
        }

        await startOllama();
        res.json({ status: 'started' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});