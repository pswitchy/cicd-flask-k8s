from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    """The main endpoint, returns a welcome message."""
    return jsonify({"message": "Hello, DevOps World!", "status": "ok"})

@app.route('/health')
def health_check():
    """A health check endpoint for Kubernetes probes."""
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Run on 0.0.0.0 to be accessible within the Docker container
    app.run(host='0.0.0.0', port=5000)