const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function (app) {
  // Proxy API requests to backend
  app.use(
    "/api",
    createProxyMiddleware({
      target: "http://localhost:5000",
      changeOrigin: true,
      logLevel: "debug",
    })
  );

  // Proxy health check endpoints to backend
  app.use(
    ["/health", "/ping", "/alive", "/ready", "/metrics"],
    createProxyMiddleware({
      target: "http://localhost:5000",
      changeOrigin: true,
      logLevel: "debug",
    })
  );
};
