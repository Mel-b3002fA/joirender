import os
from flask import Flask, request, jsonify, render_template
import ollama

# Log OLLAMA_HOST to env.log
with open("/Users/melaniiaboblieva/joi.updated/joisquashed/env.log", "a") as f:
    f.write(f"OLLAMA_HOST: {os.getenv('OLLAMA_HOST')}\n")

# Initialize Flask with explicit template and static folders
app = Flask(__name__, template_folder="templates", static_folder="static")

# Set the base URL for Ollama
ollama_url = os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
ollama_client = ollama.Client(host=ollama_url)

conversation = []

@app.route('/')
def index():
    print("Accessing / endpoint")
    try:
        return render_template('index.html')
    except Exception as e:
        print(f"Error rendering index.html: {str(e)}")
        return jsonify({'error': f"Failed to render index.html: {str(e)}"}), 500

@app.route('/chat', methods=['GET'])
def chat_page():
    print("Accessing /chat GET endpoint")
    try:
        return render_template('chat.html')
    except Exception as e:
        print(f"Error rendering chat.html: {str(e)}")
        return jsonify({'error': f"Failed to render chat.html: {str(e)}"}), 500

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/tutorial')
def tutorial():
    return render_template('tutorial.html')

@app.route('/static/<path:path>')
def serve_static(path):
    return app.send_static_file(path)

@app.route('/chat', methods=['POST'])
def process_chat():
    print("Accessing /chat POST endpoint")
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({'reply': 'Invalid message'}), 400

    user_message = data['message']
    print(f"User said: {user_message}")

    conversation.append({'role': 'user', 'content': user_message})

    try:
        response = ollama_client.chat(
            model='llama3',
            messages=conversation
        )
        if 'message' in response and 'content' in response['message']:
            reply = response['message']['content']
            print(f"Joi replied: {reply}")
            conversation.append({'role': 'assistant', 'content': reply})
            return jsonify({'reply': reply})
        else:
            print("Error: Unexpected response format")
            return jsonify ({'reply': "Sorry, something went wrong with the 
model's response."}), 500
    except Exception as e:
        print(f"Error from Ollama: {str(e)}")
        return jsonify({'reply': f"Sorry, something went wrong connecting to the 
model: {str(e)}"}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8002))
    # app.run(host='0.0.0.0', port=port, debug=True)  # Disabled for production
