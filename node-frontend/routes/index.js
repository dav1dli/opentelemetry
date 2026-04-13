const express = require("express");
const router = express.Router();
const axios = require("axios");

// Ensure the URL is trimmed. In ACA, this will be http://python-service-gateway
const GATEWAY_URL = (process.env.GATEWAY_URL || "http://127.0.0.1:5000").replace(/\/$/, "");

// Configure a reusable axios instance with a timeout
const gatewayClient = axios.create({
  baseURL: GATEWAY_URL,
  timeout: 5000, // 5 seconds
});

module.exports = () => {
  // --- Health Endpoint ---
  router.get("/health", async (req, res) => {
    const timestamp = new Date().toISOString();
    try {
      // Check if Gateway is reachable
      await gatewayClient.get("/health");
      
      console.log(`[${timestamp}] FRONTEND_HEALTH: Gateway reachable.`);
      return res.status(200).json({
        status: "UP",
        gateway: "reachable",
        timestamp
      });
    } catch (err) {
      console.error(`[${timestamp}] FRONTEND_HEALTH_FAILURE: Gateway unreachable at ${GATEWAY_URL}. Error: ${err.message}`);
      return res.status(503).json({
        status: "DEGRADED",
        gateway: "unreachable",
        error: err.message,
        timestamp
      });
    }
  });

  // --- Main Route ---
  router.get("/", async (req, res, next) => {
    const { choice } = req.query;

    // 1. Validation
    if (choice && !["spaces", "tabs", "clear"].includes(choice)) {
      return res.status(400).send("Invalid choice");
    }

    try {
      // 2. Fetch data from Gateway
      console.log(`[${new Date().toISOString()}] Routing request to Gateway: ${GATEWAY_URL}`);
      const { data } = await gatewayClient.get("/", {
        params: { choice }
      });

      // 3. Render
      return res.render("index", data);
    } catch (err) {
      // Specific logging for different failure modes
      const timestamp = new Date().toISOString();
      if (err.code === 'ECONNABORTED') {
        console.error(`[${timestamp}] GATEWAY_TIMEOUT: Gateway at ${GATEWAY_URL} took too long to respond.`);
      } else {
        console.error(`[${timestamp}] GATEWAY_ERROR: Failed to reach ${GATEWAY_URL}. Message: ${err.message}`);
      }
      
      // Pass the error to the global handler in app.js
      return next(err);
    }
  });

  return router;
};
