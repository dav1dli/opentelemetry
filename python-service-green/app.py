import os
import datetime
from flask import Flask, request, jsonify
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

uri = os.getenv("DB_URI", "mongodb://localhost")
# It's good practice to set a serverSelectionTimeoutMS for health checks
client = MongoClient(uri, serverSelectionTimeoutMS=2000)
db = client['voting']
votes = db['votes']

@app.route("/health", methods=['GET'])
def health():
    timestamp = datetime.datetime.utcnow().isoformat()
    try:
        # The 'ping' command is the standard way to check liveness in MongoDB
        client.admin.command('ping')
        
        # Success log
        print(f"[{timestamp}] HEALTHCHECK: MongoDB connection is healthy.")
        
        return jsonify({
            "status": "UP",
            "database": "connected",
            "timestamp": timestamp
        }), 200
    except (ConnectionFailure, OperationFailure) as e:
        # Error log
        print(f"[{timestamp}] HEALTHCHECK_FAILURE: Database is unreachable.")
        print(f"[{timestamp}] ERROR_DETAILS: {str(e)}")
        
        return jsonify({
            "status": "DOWN",
            "database": "disconnected",
            "error": str(e),
            "timestamp": timestamp
        }), 503

@app.route("/", methods=['GET'])
def home():
    try:
        choice = request.args.get('choice', default=None, type=str)

        if choice == 'clear':
            votes.delete_many({})
        elif choice:
            votes.insert_one({'choice': choice})

        spaces_count = votes.count_documents({'choice': 'spaces'})
        tabs_count = votes.count_documents({'choice': 'tabs'})

        return jsonify({"spaces": spaces_count, "tabs": tabs_count})
    except Exception as e:
        print(f"Database error: {str(e)}")
        return jsonify({"error": "Database operation failed"}), 500

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5001))
    # Note: debug=True should be False in production (ACA environment)
    app.run(debug=False, host='0.0.0.0', port=port)
