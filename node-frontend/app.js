const path = require("path");

const createError = require("http-errors");
const express = require("express");
const logger = require("morgan");
const helmet = require("helmet");

const app = express();
app.use(helmet());
app.disable("x-powered-by");

const indexRouter = require("./routes/index");

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, "public")));

app.use("/", indexRouter());

// catch 404 and forward to error handler
app.use((req, res, next) => {
  next(createError(404));
});

// error handler
app.use((err, req, res, next) => {
  const isDev = req.app.get("env") === "development";
  const timestamp = new Date().toISOString();
  
  // Log the full error to the console (visible in ACA logs)
  console.error(`[${timestamp}] UNCAUGHT_ERROR: ${err.stack || err.message}`);

  res.status(err.response?.status || err.status || 500);
  
  // Determine user-friendly message
  let message = "Something went wrong on our end.";
  if (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND') {
    message = "Our backend services are temporarily unavailable. Please try again in a moment.";
  }

  res.render("error", {
    message: isDev ? err.message : message,
    error: isDev ? err : {}
  });
});

module.exports = app;
