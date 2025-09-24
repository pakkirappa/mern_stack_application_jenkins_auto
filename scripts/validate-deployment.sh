#!/bin/bash

# Quick deployment validation script
# This script validates that the deployment is working correctly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Validating MERN Stack Deployment${NC}"
echo "======================================="

# Check if Docker is running
echo -e "\n${YELLOW}Checking Docker...${NC}"
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"

# Check if Docker Compose is available
echo -e "\n${YELLOW}Checking Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose is available${NC}"

# Check environment file
echo -e "\n${YELLOW}Checking environment configuration...${NC}"
if [ ! -f ".env.docker" ]; then
    echo -e "${RED}❌ .env.docker file not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Environment file found${NC}"

# Check Docker Compose file
echo -e "\n${YELLOW}Checking Docker Compose configuration...${NC}"
if [ ! -f "docker-compose.jenkins.yml" ]; then
    echo -e "${RED}❌ docker-compose.jenkins.yml file not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose file found${NC}"

# Validate Docker Compose file
echo -e "\n${YELLOW}Validating Docker Compose configuration...${NC}"
if docker-compose -f docker-compose.jenkins.yml config >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose configuration is valid${NC}"
else
    echo -e "${RED}❌ Docker Compose configuration is invalid${NC}"
    docker-compose -f docker-compose.jenkins.yml config
    exit 1
fi

# Check if required scripts exist
echo -e "\n${YELLOW}Checking deployment scripts...${NC}"
if [ ! -f "scripts/jenkins-deploy.sh" ]; then
    echo -e "${RED}❌ jenkins-deploy.sh script not found${NC}"
    exit 1
fi

if [ ! -x "scripts/jenkins-deploy.sh" ]; then
    echo -e "${YELLOW}⚠️ Making jenkins-deploy.sh executable${NC}"
    chmod +x scripts/jenkins-deploy.sh
fi
echo -e "${GREEN}✅ Deployment scripts are ready${NC}"

# Check Dockerfiles
echo -e "\n${YELLOW}Checking Dockerfiles...${NC}"
if [ ! -f "backend/Dockerfile" ]; then
    echo -e "${RED}❌ Backend Dockerfile not found${NC}"
    exit 1
fi

if [ ! -f "frontend/Dockerfile" ]; then
    echo -e "${RED}❌ Frontend Dockerfile not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dockerfiles are present${NC}"

# Check package.json files
echo -e "\n${YELLOW}Checking package.json files...${NC}"
if [ ! -f "backend/package.json" ]; then
    echo -e "${RED}❌ Backend package.json not found${NC}"
    exit 1
fi

if [ ! -f "frontend/package.json" ]; then
    echo -e "${RED}❌ Frontend package.json not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Package.json files are present${NC}"

# Check health check script
echo -e "\n${YELLOW}Checking health check script...${NC}"
if [ ! -f "backend/healthcheck.sh" ]; then
    echo -e "${RED}❌ Backend health check script not found${NC}"
    exit 1
fi

if [ ! -x "backend/healthcheck.sh" ]; then
    echo -e "${YELLOW}⚠️ Making healthcheck.sh executable${NC}"
    chmod +x backend/healthcheck.sh
fi
echo -e "${GREEN}✅ Health check script is ready${NC}"

# Test build (optional - only if user wants full validation)
if [ "$1" = "--full" ]; then
    echo -e "\n${YELLOW}Testing Docker build process...${NC}"
    
    # Load environment
    source .env.docker
    
    echo "Building backend image..."
    cd backend
    if docker build -t test-backend:validation . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend image builds successfully${NC}"
        docker rmi test-backend:validation >/dev/null 2>&1
    else
        echo -e "${RED}❌ Backend image build failed${NC}"
        exit 1
    fi
    cd ..
    
    echo "Building frontend image..."
    cd frontend
    if docker build -t test-frontend:validation . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend image builds successfully${NC}"
        docker rmi test-frontend:validation >/dev/null 2>&1
    else
        echo -e "${RED}❌ Frontend image build failed${NC}"
        exit 1
    fi
    cd ..
fi

# Final summary
echo -e "\n${GREEN}🎉 Deployment Validation Summary${NC}"
echo "================================="
echo -e "${GREEN}✅ Docker environment: Ready${NC}"
echo -e "${GREEN}✅ Configuration files: Present and valid${NC}"
echo -e "${GREEN}✅ Deployment scripts: Ready${NC}"
echo -e "${GREEN}✅ Application files: Present${NC}"
echo -e "${GREEN}✅ Health check system: Ready${NC}"

if [ "$1" = "--full" ]; then
    echo -e "${GREEN}✅ Docker builds: Successful${NC}"
fi

echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Configure Jenkins with the provided setup guide (JENKINS_SETUP.md)"
echo "2. Set up your Docker registry credentials in Jenkins"
echo "3. Update environment variables in .env.docker for your environment"
echo "4. Commit and push your code to trigger the Jenkins pipeline"
echo "5. Monitor the deployment through Jenkins dashboard"

echo ""
echo -e "${BLUE}🚀 Ready for Jenkins Deployment!${NC}"