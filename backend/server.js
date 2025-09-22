const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const healthCheck = require("./utils/healthCheck");
require("dotenv").config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`${timestamp} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Health check request counter middleware
app.use("/health", (req, res, next) => {
  healthCheck.incrementHealthCheckCount();
  next();
});

// MongoDB connection
const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://localhost:27017/mernapp";

mongoose
  .connect(MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to MongoDB");
  })
  .catch((error) => {
    console.error("MongoDB connection error:", error);
  });

// Health Check Routes
app.get("/health", (req, res) => {
  const health = healthCheck.getBasicHealth();
  res.status(200).json(health);
});

// Simple ping endpoint for load balancers
app.get("/ping", (req, res) => {
  res.status(200).json({
    status: "OK",
    message: "pong",
    timestamp: new Date().toISOString(),
  });
});

// Detailed health check with database status
app.get("/health/detailed", async (req, res) => {
  try {
    const health = await healthCheck.getDetailedHealth();
    const statusCode = health.status === "OK" ? 200 : 503;
    res.status(statusCode).json(health);
  } catch (error) {
    res.status(503).json({
      status: "ERROR",
      message: "Health check failed",
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

// Database-specific health check
app.get("/health/database", async (req, res) => {
  try {
    const dbCheck = await healthCheck.checkDatabase();
    const statusCode = dbCheck.status === "OK" ? 200 : 503;
    res.status(statusCode).json({
      status: dbCheck.status,
      database: dbCheck,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(503).json({
      status: "ERROR",
      database: {
        error: error.message,
      },
      timestamp: new Date().toISOString(),
    });
  }
});

// Readiness probe (for Kubernetes/Docker)
app.get("/ready", async (req, res) => {
  try {
    const readiness = await healthCheck.checkReadiness();
    const statusCode = readiness.status === "READY" ? 200 : 503;
    res.status(statusCode).json(readiness);
  } catch (error) {
    res.status(503).json({
      status: "NOT_READY",
      message: "Readiness check failed",
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

// Liveness probe (for Kubernetes/Docker)
app.get("/alive", (req, res) => {
  const liveness = healthCheck.checkLiveness();
  res.status(200).json(liveness);
});

// System metrics endpoint
app.get("/metrics", (req, res) => {
  const metrics = healthCheck.getSystemMetrics();
  res.status(200).json({
    ...metrics,
    timestamp: new Date().toISOString(),
  });
});

// Health monitoring dashboard endpoint
app.get("/health/dashboard", async (req, res) => {
  try {
    const [basicHealth, detailedHealth, dbCheck, readiness, liveness, metrics] =
      await Promise.all([
        healthCheck.getBasicHealth(),
        healthCheck.getDetailedHealth(),
        healthCheck.checkDatabase(),
        healthCheck.checkReadiness(),
        healthCheck.checkLiveness(),
        healthCheck.getSystemMetrics(),
      ]);

    res.status(200).json({
      dashboard: {
        overall_status: detailedHealth.status,
        timestamp: new Date().toISOString(),
        checks: {
          basic: basicHealth,
          detailed: detailedHealth,
          database: dbCheck,
          readiness: readiness,
          liveness: liveness,
          metrics: metrics,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      dashboard: {
        overall_status: "ERROR",
        error: error.message,
        timestamp: new Date().toISOString(),
      },
    });
  }
});

// Routes
const userRoutes = require("./routes/users");
app.use("/api/users", userRoutes);

// Basic route
app.get("/", (req, res) => {
  res.json({
    message: "Welcome to MERN Stack Application API",
    version: process.env.npm_package_version || "1.0.0",
    environment: process.env.NODE_ENV || "development",
    endpoints: {
      users: "/api/users",
      ping: "/ping",
      healthCheck: "/health",
      detailedHealth: "/health/detailed",
      databaseHealth: "/health/database",
      healthDashboard: "/health/dashboard",
      readiness: "/ready",
      liveness: "/alive",
      metrics: "/metrics",
    },
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error(error);
  res.status(500).json({ error: "Internal Server Error" });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
