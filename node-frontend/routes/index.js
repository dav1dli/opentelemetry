const express = require("express");
const router = express.Router();
const axios = require("axios");

// Ensure the URL is trimmed and ready
const GATEWAY_URL = (process.env.GATEWAY_URL || "http://127.0.0.1:3001").replace(/\/$/, "");

module.exports = () => {
  router.get("/", async (req, res, next) => {
    try {
      // 1. Extract choice from the query string
      const choice = req.query.choice || "";

      // 2. Validation
      if (
        choice &&
        choice !== "spaces" &&
        choice !== "tabs" &&
        choice !== "clear"
      ) {
        return res.status(400).end();
      }

      // 3. Construct the URL using the variable we just defined
      const targetUrl = `${GATEWAY_URL}/?choice=${choice}`;

      const { data } = await axios.get(targetUrl);

      // 4. Render the page with the data received from the gateway
      return res.render("index", data);
    } catch (err) {
      console.error(`Frontend failed to reach Gateway at ${GATEWAY_URL}: ${err.message}`);
      return next(err);
    }
  });

  return router;
};
