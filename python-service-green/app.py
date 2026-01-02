import os
from flask import Flask, request, jsonify
from pymongo import MongoClient
from dotenv import load_dotenv

# Load variables from .env file into the environment
load_dotenv()

app = Flask(__name__)

# 1. Look for 'DB_URI' in the environment
# 2. Fall back to 'mongodb://localhost' if not found
uri = os.getenv("DB_URI", "mongodb://localhost")

client = MongoClient(uri)
db = client['voting']
votes = db['votes']

print(f"Connected to DB at: {uri}")

@app.route("/", methods=['GET'])
def home():
    choice = request.args.get('choice', default=None, type=str)

    if choice == 'clear':
        votes.delete_many({})
    elif choice:
        votes.insert_one({'choice': choice})

    spaces_count = votes.count_documents({'choice': 'spaces'})
    tabs_count = votes.count_documents({'choice': 'tabs'})

    return jsonify({"spaces": spaces_count, "tabs": tabs_count})

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5001))
    app.run(debug=True, host='0.0.0.0', port=port)
