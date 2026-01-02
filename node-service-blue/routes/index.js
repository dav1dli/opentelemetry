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

router.get("/", async (req, res, next) => {
  try {
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