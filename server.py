from flask import Flask, request, jsonify, render_template
import ollama
import os

# Initialize Flask with explicit template and static folders
app = Flask(__name__, template_folder="templates", static_folder="static")

# Set the base URL for Ollama
# Note: For Vercel, this cannot be localhost. Host Ollama externally or use a cloud-based AI API.
# Replace with the external Ollama URL or alternative API endpoint (e.g., xAI Grok API).
ollama_url = os.environ.get('OLLAMA_URL', 'http://localhost:11434/api/chat')

# Configure Ollama client with the custom URL
ollama.Client(host=ollama_url)

conversation = []

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat')
def chat():
    return render_template('chat.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/tutorial')
def tutorial():
    return render_template('tutorial.html')

@app.route('/chat', methods=['POST'])
def process_chat():
    data = request.get_json()

    # Validate input
    if not data or 'message' not in data:
        return jsonify({'reply': 'Invalid message'}), 400

    user_message = data['message']
    print(f"User said: {user_message}")

    # Append user message to conversation
    conversation.append({'role': 'user', 'content': user_message})

    try:
        # Send the conversation history (including user input) to Ollama
        response = ollama.chat(
            model='llama3',
            messages=conversation
        )

        # Check if the response has the expected structure
        if 'message' in response and 'content' in response['message']:
            reply = response['message']['content']
            print(f"Joi replied: {reply}")
            
            # Append AI reply to conversation
            conversation.append({'role': 'assistant', 'content': reply})

            return jsonify({'reply': reply})

        else:
            print("Error: Unexpected response format")
            return jsonify({'reply': "Sorry, something went wrong with the model's response."}), 500

    except Exception as e:
        # Catch errors and return a fallback response
        print("Error from Ollama:", e)
        return jsonify({'reply': "Sorry, something went wrong connecting to the model."}), 500

if __name__ == '__main__':
    # Bind to 0.0.0.0 and use PORT from environment for Vercel compatibility
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)