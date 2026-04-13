const express = require("express");
const router = express.Router();
const { MongoClient } = require("mongodb");

// 1. Read from environment variable with fallback
const uri = process.env.DB_URI || "mongodb://localhost:27017";
const client = new MongoClient(uri);

// Connect once at the start of the app
client.connect().catch(err => console.error("MongoDB Connection Error:", err));

function fibonacci(n) {
  if (n < 2) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

router.get("/health", async (req, res) => {
  const timestamp = new Date().toISOString();
  
  try {
    // Attempt to ping the admin database
    // Setting a maxTimeMS ensures the health check doesn't hang indefinitely
    await client.db("admin").command({ ping: 1 }, { maxTimeMS: 2000 });

    // Success Log: Helpful for confirming the container is alive in the stream
    console.log(`[${timestamp}] HEALTHCHECK: MongoDB connection is healthy.`);

    return res.status(200).json({
      status: "UP",
      database: "connected",
      timestamp: timestamp
    });
  } catch (err) {
    // Error Log: Detailed breakdown of the failure
    console.error(`[${timestamp}] HEALTHCHECK_FAILURE: Database is unreachable.`);
    console.error(`[${timestamp}] ERROR_DETAILS: ${err.message}`);
    
    // Log the topology status if available to see if it's a timeout vs. a total crash
    if (client.topology) {
       console.error(`[${timestamp}] DB_TOPOLOGY: ${client.topology.description.type}`);
    }

    return res.status(503).json({
      status: "DOWN",
      database: "disconnected",
      error: err.message,
      timestamp: timestamp
    });
  }
});

router.get("/", async (req, res, next) => {
  try {
    if (!client.topology || !client.topology.isConnected()) {
        await client.connect();
    }
    const database = client.db("voting");
    const votes = database.collection("votes");
    const choice = req.query.choice;

    if (choice === "clear") {
      await votes.deleteMany({});
    } else if (choice) {
      await votes.insertOne({ choice: choice });
    }

    const spaces = await votes.countDocuments({ choice: "spaces" });
    const tabs = await votes.countDocuments({ choice: "tabs" });

    // Simulation of CPU heavy task
    if (Math.random() < 0.5) {
      fibonacci(40);
    }

    return res.json({ spaces, tabs });
  } catch (err) {
    console.error("Database error:", err.message);
    return next(err);
  }
});

module.exports = router;