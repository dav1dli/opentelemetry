import os
import time
import logging
import threading
from itertools import cycle
from flask import Flask, request, jsonify
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# --- Logging Configuration ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s'
)
logger = logging.getLogger("gateway")

app = Flask(__name__)

# --- Configuration & State ---
UPSTREAM_CONFIG = os.getenv("UPSTREAM_SERVICES", "http://node-service-blue,http://python-service-green")
UPSTREAM_URLS = [url.strip() for url in UPSTREAM_CONFIG.split(",") if url.strip()]

# Thread-safe storage for healthy upstreams
# We start with all of them and let the thread prune them
healthy_upstreams = list(UPSTREAM_URLS)
lock = threading.Lock()

def get_service_pool():
    """Returns a cycle iterator of currently healthy upstreams."""
    with lock:
        if not healthy_upstreams:
            return None
        return cycle(list(healthy_upstreams))

# --- Background Health Checker ---
def monitor_upstreams(interval=10):
    """Periodically pings /health on all configured upstreams."""
    global healthy_upstreams
    logger.info(f"Starting health monitor for: {UPSTREAM_URLS}")
    
    while True:
        current_healthy = []
        for url in UPSTREAM_URLS:
            try:
                # Use a short timeout for the check itself
                check_url = f"{url.rstrip('/')}/health"
                response = requests.get(check_url, timeout=3.0)
                
                if response.status_code == 200:
                    current_healthy.append(url)
                    logger.debug(f"Upstream {url} is healthy.")
                else:
                    logger.warning(f"Upstream {url} reported status {response.status_code}")
            except requests.exceptions.RequestException as e:
                logger.error(f"Upstream {url} is UNREACHABLE: {str(e)}")

        with lock:
            healthy_upstreams = current_healthy
        
        time.sleep(interval)

# Start the background thread
monitor_thread = threading.Thread(target=monitor_upstreams, daemon=True)
monitor_thread.start()

# --- Routes ---

@app.route('/health')
def health():
    """
    Gateway health reflects the state of its upstreams.
    Returns 503 if no backends are available to serve requests.
    """
    with lock:
        active_count = len(healthy_upstreams)
        status = "healthy" if active_count > 0 else "unhealthy"
        
    payload = {
        "status": status,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "upstreams": {
            "configured": UPSTREAM_URLS,
            "active_count": active_count,
            "healthy_list": healthy_upstreams
        }
    }
    
    return jsonify(payload), 200 if status == "healthy" else 503

@app.route('/')
def index():
    pool = get_service_pool()
    
    if not pool:
        logger.critical("Request failed: No healthy upstreams available!")
        return jsonify(error="All backend services are currently unavailable"), 503

    choice = request.args.get('choice', '')
    
    # Pick the next healthy service
    target_base_url = next(pool)
    target_url = f"{target_base_url.rstrip('/')}/?choice={choice}"

    try:
        logger.info(f"Routing to {target_base_url}")
        # 5 second timeout for the actual data request
        response = requests.get(target_url, timeout=5.0)
        
        # Forward successful response
        return jsonify(response.json()), response.status_code

    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to communicate with {target_base_url}: {str(e)}")
        return jsonify(error="Upstream communication error"), 502

if __name__ == '__main__':
    PORT = int(os.getenv("PORT", 5000))
    # debug=False is important when using background threads to avoid double-starts
    app.run(host='0.0.0.0', port=PORT, debug=False)