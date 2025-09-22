const mongoose = require("mongoose");

// Health check counters and metrics
let healthCheckCount = 0;
let lastHealthCheck = null;
const startTime = Date.now();

/**
 * Increment health check counter
 */
const incrementHealthCheckCount = () => {
  healthCheckCount++;
  lastHealthCheck = new Date().toISOString();
};

/**
 * Get basic health status
 */
const getBasicHealth = () => {
  return {
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    message: "Server is healthy",
    version: process.env.npm_package_version || "1.0.0",
  };
};

/**
 * Check database connectivity
 */
const checkDatabase = async () => {
  try {
    const dbState = mongoose.connection.readyState;
    const states = {
      0: "disconnected",
      1: "connected",
      2: "connecting",
      3: "disconnecting",
    };

    if (dbState === 1) {
      const startTime = Date.now();
      await mongoose.connection.db.admin().ping();
      const responseTime = Date.now() - startTime;

      return {
        status: "OK",
        state: states[dbState],
        name: mongoose.connection.name,
        host: mongoose.connection.host,
        port: mongoose.connection.port,
        responseTime: `${responseTime}ms`,
      };
    } else {
      return {
        status: "ERROR",
        state: states[dbState],
        error: "Database is not connected",
      };
    }
  } catch (error) {
    return {
      status: "ERROR",
      error: error.message,
    };
  }
};

/**
 * Get system metrics
 */
const getSystemMetrics = () => {
  const memoryUsage = process.memoryUsage();
  const cpuUsage = process.cpuUsage();

  return {
    system: {
      nodeVersion: process.version,
      platform: process.platform,
      architecture: process.arch,
      uptime: process.uptime(),
      pid: process.pid,
      startTime: new Date(startTime).toISOString(),
    },
    memory: {
      rss: Math.round((memoryUsage.rss / 1024 / 1024) * 100) / 100,
      heapTotal: Math.round((memoryUsage.heapTotal / 1024 / 1024) * 100) / 100,
      heapUsed: Math.round((memoryUsage.heapUsed / 1024 / 1024) * 100) / 100,
      external: Math.round((memoryUsage.external / 1024 / 1024) * 100) / 100,
      heapUsedPercentage: Math.round(
        (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100
      ),
    },
    cpu: {
      user: cpuUsage.user,
      system: cpuUsage.system,
    },
  };
};

/**
 * Get detailed health status
 */
const getDetailedHealth = async () => {
  const dbCheck = await checkDatabase();
  const systemMetrics = getSystemMetrics();

  const healthCheck = {
    status: dbCheck.status === "OK" ? "OK" : "ERROR",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || "1.0.0",
    environment: process.env.NODE_ENV || "development",
    port: process.env.PORT || 5000,
    healthCheckCount: healthCheckCount,
    lastHealthCheck: lastHealthCheck,
    checks: {
      server: "OK",
      database: dbCheck,
      memory: {
        used: systemMetrics.memory.heapUsed + " MB",
        total: systemMetrics.memory.heapTotal + " MB",
        usage: systemMetrics.memory.heapUsedPercentage + "%",
      },
      system: systemMetrics.system,
    },
  };

  return healthCheck;
};

/**
 * Check if application is ready to serve traffic
 */
const checkReadiness = async () => {
  try {
    if (mongoose.connection.readyState === 1) {
      await mongoose.connection.db.admin().ping();
      return {
        status: "READY",
        message: "Application is ready to serve traffic",
        timestamp: new Date().toISOString(),
      };
    } else {
      return {
        status: "NOT_READY",
        message: "Database connection not ready",
        timestamp: new Date().toISOString(),
      };
    }
  } catch (error) {
    return {
      status: "NOT_READY",
      message: "Application not ready",
      error: error.message,
      timestamp: new Date().toISOString(),
    };
  }
};

/**
 * Simple liveness check
 */
const checkLiveness = () => {
  return {
    status: "ALIVE",
    message: "Application is alive",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  };
};

module.exports = {
  incrementHealthCheckCount,
  getBasicHealth,
  getDetailedHealth,
  checkDatabase,
  getSystemMetrics,
  checkReadiness,
  checkLiveness,
};
