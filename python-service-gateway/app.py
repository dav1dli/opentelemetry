import os
import logging
from itertools import cycle
from flask import Flask, request, jsonify
import requests
from dotenv import load_dotenv

# Load variables from .env file into the environment
# This will not override existing system environment variables
load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# --- Configuration ---
# 1. Read Upstream URLs (supports comma-separated list)
UPSTREAM_CONFIG = os.getenv("UPSTREAM_SERVICES", "http://localhost:3010,http://localhost:3020")
UPSTREAM_URLS = [url.strip() for url in UPSTREAM_CONFIG.split(",") if url.strip()]

if not UPSTREAM_URLS:
    logger.error("No upstream services configured! Gateway will fail.")
    service_pool = None
else:
    # Use cycle for Round Robin load balancing
    service_pool = cycle(UPSTREAM_URLS)

@app.route('/health')
def health():
    return jsonify(status="healthy"), 200

@app.route('/')
def index():
    if not service_pool:
        return jsonify(error="Gateway misconfigured: No upstreams"), 500

    choice = request.args.get('choice', '')

    # Get the next available service in the rotation (Round Robin)
    target_base_url = next(service_pool)
    target_url = f"{target_base_url}?choice={choice}"

    try:
        logger.info(f"Routing request to: {target_url}")
        # Added a timeout to prevent the gateway from hanging indefinitely
        response = requests.get(target_url, timeout=5.0)

        # Forward the exact JSON and status code from the upstream
        return jsonify(response.json()), response.status_code

    except requests.exceptions.RequestException as e:
        logger.error(f"Connection failed to {target_base_url}: {str(e)}")
        return jsonify(error="Gateway timeout or connection error"), 504

if __name__ == '__main__':
    # Read port from .env or environment, default to 5000
    PORT = int(os.getenv("PORT", 5000))
    app.run(host='0.0.0.0', port=PORT)