from flask import Flask, request, jsonify, render_template
import ollama
import os
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Initialize Flask with explicit template and static folders
app = Flask(__name__, template_folder="templates", static_folder="static")

# Set the base URL for Ollama (remove /api/chat)
ollama_url = os.environ.get('OLLAMA_URL', 'http://localhost:11434').rstrip('/api/chat')
logging.info(f"Using Ollama URL: {ollama_url}")

# Initialize Ollama client
client = ollama.Client(host=ollama_url)

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
        logging.error("Invalid request: message field missing")
        return jsonify({'reply': 'Invalid message'}), 400

    user_message = data['message']
    logging.info(f"User said: {user_message}")

    # Log to file only in non-production environments
    if os.getenv('ENV') != 'production':
        try:
            with open('env.log', 'a') as f:
                f.write(f"User said: {user_message}\n")
        except Exception as e:
            logging.error(f"Failed to write to log file: {e}")

    # Append user message to conversation
    conversation.append({'role': 'user', 'content': user_message})

    try:
        # Send the conversation history to Ollama using the client
        response = client.chat(
            model='llama3:8b',  # Use correct model name
            messages=conversation
        )

        # Check if the response has the expected structure
        if 'message' in response and 'content' in response['message']:
            reply = response['message']['content']
            logging.info(f"Joi replied: {reply}")

            # Log AI reply to file only in non-production environments
            if os.getenv('ENV') != 'production':
                try:
                    with open('env.log', 'a') as f:
                        f.write(f"Joi replied: {reply}\n")
                except Exception as e:
                    logging.error(f"Failed to write to log file: {e}")

            # Append AI reply to conversation
            conversation.append({'role': 'assistant', 'content': reply})

            return jsonify({'reply': reply}), 200

        else:
            logging.error(f"Unexpected response format: {response}")
            return jsonify({'reply': "Sorry, something went wrong with the model's response."}), 500

    except Exception as e:
        logging.error(f"Error from Ollama: {str(e)}", exc_info=True)
        return jsonify({
            'reply': "Sorry, something went wrong connecting to the model.",
            'error': str(e)
        }), 500

@app.route('/test-ollama', methods=['GET'])
def test_ollama():
    try:
        response = client.list()
        logging.info(f"Ollama models: {response}")
        return jsonify(response), 200
    except Exception as e:
        logging.error(f"Ollama test error: {str(e)}", exc_info=True)
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)
