#!/bin/bash

# Docker health check script for the MERN application
# This script can be used in Dockerfile HEALTHCHECK instruction

HOST="localhost"
PORT=${PORT:-5000}

# Check if the basic health endpoint responds
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}:${PORT}/health)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "Health check passed - HTTP $HTTP_CODE"
    exit 0
else
    echo "Health check failed - HTTP $HTTP_CODE"
    exit 1
fi