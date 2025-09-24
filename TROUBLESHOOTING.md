# MERN Stack Development Troubleshooting Guide

This guide helps you resolve common issues encountered during MERN stack development and deployment.

## Table of Contents
1. [Proxy Connection Errors (ECONNREFUSED)](#proxy-connection-errors)
2. [React Hook Dependency Warnings](#react-hook-warnings)
3. [MongoDB Connection Issues](#mongodb-issues)
4. [ESLint and Code Quality Issues](#eslint-issues)
5. [Docker and Jenkins Issues](#docker-jenkins-issues)
6. [Build and Compilation Errors](#build-errors)

## Proxy Connection Errors (ECONNREFUSED) {#proxy-connection-errors}

### Problem
```
Proxy error: Could not proxy request /manifest.json from localhost:3000 to http://localhost:5000/
See https://nodejs.org/api/errors.html#errors_common_system_errors for more information (ECONNREFUSED).
```

### Root Causes
1. Backend server not running on port 5000
2. Backend server crashed or failed to start
3. Incorrect proxy configuration
4. MongoDB connection issues preventing backend startup

### Solutions

#### Solution 1: Check Backend Server Status
```bash
# Check if backend is running
cd backend
npm run dev

# Check if port 5000 is in use
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # macOS/Linux
```

#### Solution 2: Fix Proxy Configuration
Ensure you have the proper proxy setup in `frontend/src/setupProxy.js`:

```javascript
const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app) {
  app.use(
    '/api',
    createProxyMiddleware({
      target: 'http://localhost:5000',
      changeOrigin: true,
      logLevel: 'debug'
    })
  );
};
```

#### Solution 3: Install Required Dependencies
```bash
cd frontend
npm install http-proxy-middleware
```

#### Solution 4: Check Environment Variables
Ensure your `backend/.env` file exists:
```bash
# backend/.env
MONGODB_URI=mongodb://localhost:27017/mernapp
PORT=5000
NODE_ENV=development
JWT_SECRET=your_jwt_secret_key_here
```

#### Solution 5: Start Services in Correct Order
1. Start MongoDB
2. Start Backend (cd backend && npm run dev)
3. Start Frontend (cd frontend && npm start)

### Quick Fix Commands
```bash
# Windows - Use the provided script
scripts\start-dev.bat

# Manual start
# Terminal 1: Start Backend
cd backend && npm run dev

# Terminal 2: Start Frontend  
cd frontend && npm start
```

## React Hook Dependency Warnings {#react-hook-warnings}

### Problem
```
React Hook useEffect has a missing dependency: 'fetchUser'. 
Either include it or remove the dependency array react-hooks/exhaustive-deps
```

### Root Cause
ESLint exhaustive-deps rule requires all dependencies used inside useEffect to be listed in the dependency array.

### Solutions

#### Solution 1: Use useCallback for Functions
```javascript
import React, { useState, useEffect, useCallback } from 'react';

const MyComponent = () => {
  const [data, setData] = useState([]);
  
  const fetchData = useCallback(async () => {
    // Fetch logic here
  }, [dependency1, dependency2]);
  
  useEffect(() => {
    fetchData();
  }, [fetchData]);
};
```

#### Solution 2: Move Function Inside useEffect (for simple cases)
```javascript
useEffect(() => {
  const fetchData = async () => {
    // Fetch logic here
  };
  
  fetchData();
}, [dependency1, dependency2]);
```

#### Solution 3: Disable ESLint Rule (last resort)
```javascript
useEffect(() => {
  fetchData();
}, []); // eslint-disable-line react-hooks/exhaustive-deps
```

### Applied Fixes in This Project

**EditUser.js:**
```javascript
const fetchUser = useCallback(async () => {
  // Fetch user logic
}, [id]);

useEffect(() => {
  fetchUser();
}, [fetchUser]);
```

**UserList.js:**
```javascript
const fetchUsers = useCallback(async () => {
  // Fetch users logic
}, [currentPage, usersPerPage]);

const handleSearch = useCallback(async () => {
  // Search logic
}, [searchTerm, fetchUsers]);

useEffect(() => {
  fetchUsers();
}, [fetchUsers]);

useEffect(() => {
  if (searchTerm) {
    handleSearch();
  } else {
    fetchUsers();
  }
}, [searchTerm, handleSearch, fetchUsers]);
```

## MongoDB Connection Issues {#mongodb-issues}

### Common Problems
1. MongoDB not installed or running
2. Connection string incorrect
3. Authentication issues
4. Network/firewall issues

### Solutions

#### Local MongoDB Setup
```bash
# Windows - Install MongoDB Community Server
# Download from: https://www.mongodb.com/try/download/community

# Start MongoDB Service
net start MongoDB

# Check if running
mongosh --eval "db.adminCommand('ping')"
```

#### Using MongoDB Atlas (Cloud)
1. Create account at https://www.mongodb.com/atlas
2. Create a cluster
3. Get connection string
4. Update `.env` file:
```bash
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/mernapp
```

#### Docker MongoDB
```bash
docker run -d --name mongodb -p 27017:27017 mongo:5.0
```

## ESLint and Code Quality Issues {#eslint-issues}

### Common Warnings and Fixes

#### Unused Imports
```javascript
// Problem
import React, { useState, useEffect, useCallback } from 'react';
// Only using useState

// Solution - Remove unused imports
import React, { useState } from 'react';
```

#### Missing Dependencies
```javascript
// Problem
useEffect(() => {
  fetchData();
}, []); // Missing fetchData dependency

// Solution
const fetchData = useCallback(() => {
  // logic
}, [dependencies]);

useEffect(() => {
  fetchData();
}, [fetchData]);
```

#### Async useEffect
```javascript
// Problem - useEffect can't be async directly
useEffect(async () => {
  const data = await fetchData();
}, []);

// Solution - Use async function inside
useEffect(() => {
  const loadData = async () => {
    const data = await fetchData();
  };
  loadData();
}, []);
```

## Docker and Jenkins Issues {#docker-jenkins-issues}

### Common Docker Problems

#### Docker Build Failures
```bash
# Clear Docker cache
docker system prune -f

# Rebuild without cache
docker build --no-cache -t image-name .

# Check Docker logs
docker logs container-name
```

#### Permission Issues
```bash
# Linux/macOS - Add user to docker group
sudo usermod -aG docker $USER

# Windows - Run as Administrator
```

#### Port Conflicts
```bash
# Check what's using port 5000
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # macOS/Linux

# Kill process using port
taskkill /PID <pid> /F        # Windows
kill -9 <pid>                 # macOS/Linux
```

### Jenkins Configuration Issues

#### Missing Plugins
Install required Jenkins plugins:
- Docker Pipeline
- NodeJS Plugin
- Git Plugin
- Blue Ocean

#### Credentials Setup
1. Docker Registry credentials: `docker-credentials`
2. MongoDB URI: `mongodb-uri`
3. Kubeconfig: `kubeconfig` (if using Kubernetes)

#### Build Failures
```bash
# Check Jenkins logs
tail -f /var/log/jenkins/jenkins.log

# Clean workspace
# In Jenkins job configuration: "Delete workspace before build starts"

# Docker cleanup in Jenkins
docker system prune -f
docker image prune -f
```

## Build and Compilation Errors {#build-errors}

### React Build Issues

#### Memory Issues
```bash
# Increase Node.js memory limit
NODE_OPTIONS="--max_old_space_size=4096" npm run build

# Or set in package.json
"scripts": {
  "build": "NODE_OPTIONS='--max_old_space_size=4096' react-scripts build"
}
```

#### Dependencies Issues
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Or use npm ci for clean install
npm ci
```

### Backend Build Issues

#### Missing Environment Variables
Ensure all required environment variables are set:
```bash
# Check current environment
printenv | grep NODE  # Linux/macOS
set | findstr NODE    # Windows

# Set missing variables
export NODE_ENV=development  # Linux/macOS
set NODE_ENV=development     # Windows
```

#### MongoDB Connection Timeout
```javascript
// Increase connection timeout in server.js
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 10000, // 10 seconds
  connectTimeoutMS: 10000,
});
```

## Quick Diagnostic Commands

### Health Check Commands
```bash
# Check all services
curl http://localhost:5000/health    # Backend health
curl http://localhost:3000           # Frontend
mongosh --eval "db.adminCommand('ping')"  # MongoDB

# Check processes
ps aux | grep node                   # Linux/macOS
tasklist | findstr node             # Windows

# Check ports
netstat -tlnp | grep :5000         # Linux
netstat -ano | findstr :5000       # Windows
```

### Log Locations
```bash
# Application logs
backend/logs/                       # If configured
~/.npm/_logs/                      # npm logs
/var/log/jenkins/                  # Jenkins logs

# Docker logs
docker logs container-name
docker-compose logs service-name
```

### Reset Everything (Nuclear Option)
```bash
# Stop all services
docker-compose down
pkill -f node                      # Kill all Node.js processes

# Clean everything
rm -rf node_modules package-lock.json
rm -rf backend/node_modules backend/package-lock.json  
rm -rf frontend/node_modules frontend/package-lock.json

# Docker cleanup
docker system prune -a
docker volume prune

# Reinstall
npm install
cd backend && npm install
cd ../frontend && npm install

# Restart
scripts/start-dev.bat              # Windows
scripts/dev-setup.sh && scripts/start-dev.sh  # Linux/macOS
```

## Getting Help

### Log Analysis
1. Check browser console (F12) for frontend errors
2. Check backend terminal for server errors
3. Check MongoDB logs for database issues
4. Check Jenkins console output for CI/CD issues

### Community Resources
- [MERN Stack Documentation](https://www.mongodb.com/mern-stack)
- [React Documentation](https://reactjs.org/docs)
- [Express.js Documentation](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)

### Debug Mode
Enable debug logging:
```bash
# Backend
DEBUG=* npm run dev

# Frontend (in setupProxy.js)
logLevel: 'debug'

# MongoDB
mongosh --verbose
```

This troubleshooting guide covers the most common issues. Keep it handy during development!