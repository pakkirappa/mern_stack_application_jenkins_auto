#!/bin/bash

# Development setup script for MERN stack application
# This script helps start the application in development mode

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 MERN Stack Development Setup${NC}"
echo "================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Node.js is installed
echo -e "\n${YELLOW}Checking Node.js installation...${NC}"
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js is installed: ${NODE_VERSION}${NC}"
else
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
echo -e "\n${YELLOW}Checking npm installation...${NC}"
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm is installed: v${NPM_VERSION}${NC}"
else
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
fi

# Check if MongoDB is running (optional for development)
echo -e "\n${YELLOW}Checking MongoDB connection...${NC}"
if command_exists mongosh; then
    if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MongoDB is running and accessible${NC}"
    else
        echo -e "${YELLOW}⚠️ MongoDB is not running or not accessible${NC}"
        echo -e "${YELLOW}   You can start MongoDB or use MongoDB Atlas${NC}"
    fi
elif command_exists mongo; then
    if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MongoDB is running and accessible${NC}"
    else
        echo -e "${YELLOW}⚠️ MongoDB is not running or not accessible${NC}"
        echo -e "${YELLOW}   You can start MongoDB or use MongoDB Atlas${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ MongoDB client not found${NC}"
    echo -e "${YELLOW}   Install MongoDB or use MongoDB Atlas${NC}"
fi

# Install backend dependencies
echo -e "\n${YELLOW}Installing backend dependencies...${NC}"
cd backend
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
else
    echo -e "${RED}❌ Backend package.json not found${NC}"
    exit 1
fi
cd ..

# Install frontend dependencies
echo -e "\n${YELLOW}Installing frontend dependencies...${NC}"
cd frontend
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
else
    echo -e "${RED}❌ Frontend package.json not found${NC}"
    exit 1
fi
cd ..

# Install root dependencies (if any)
echo -e "\n${YELLOW}Installing root dependencies...${NC}"
if [ -f "package.json" ]; then
    npm install
    echo -e "${GREEN}✅ Root dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠️ No root package.json found${NC}"
fi

echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Start MongoDB if not already running"
echo "2. Start the backend server: cd backend && npm run dev"
echo "3. In a new terminal, start the frontend: cd frontend && npm start"
echo "4. Open http://localhost:3000 in your browser"
echo ""
echo -e "${BLUE}📝 Useful Commands:${NC}"
echo "Backend development: cd backend && npm run dev"
echo "Frontend development: cd frontend && npm start"
echo "Build for production: cd frontend && npm run build"
echo "Run tests: npm test"