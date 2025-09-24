#!/bin/bash

# Jenkins Docker Deployment Script for MERN Stack Application
# This script handles the complete deployment process

set -e  # Exit on any error

# Configuration
APP_NAME="mern-stack-app"
BUILD_NUMBER=${BUILD_NUMBER:-latest}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"your-registry.com"}
ENVIRONMENT=${DEPLOY_ENV:-"production"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if required tools are available
check_requirements() {
    log "Checking requirements..."
    
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    success "All required tools are available"
}

# Build Docker images
build_images() {
    log "Building Docker images..."
    
    # Build backend image
    log "Building backend image..."
    cd backend
    docker build -t ${DOCKER_REGISTRY}/${APP_NAME}-backend:${BUILD_NUMBER} .
    docker tag ${DOCKER_REGISTRY}/${APP_NAME}-backend:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${APP_NAME}-backend:latest
    cd ..
    
    # Build frontend image
    log "Building frontend image..."
    cd frontend
    docker build -t ${DOCKER_REGISTRY}/${APP_NAME}-frontend:${BUILD_NUMBER} .
    docker tag ${DOCKER_REGISTRY}/${APP_NAME}-frontend:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${APP_NAME}-frontend:latest
    cd ..
    
    success "Docker images built successfully"
}

# Test images locally
test_images() {
    log "Testing Docker images..."
    
    # Test backend image
    log "Testing backend image..."
    docker run -d --name test-backend -p 5001:5000 ${DOCKER_REGISTRY}/${APP_NAME}-backend:${BUILD_NUMBER}
    sleep 10
    
    # Test health endpoints
    if curl -f http://localhost:5001/ping; then
        success "Backend image test passed"
    else
        error "Backend image test failed"
        docker logs test-backend
        docker stop test-backend
        docker rm test-backend
        exit 1
    fi
    
    docker stop test-backend
    docker rm test-backend
    
    success "Image testing completed"
}

# Push images to registry
push_images() {
    if [ "$ENVIRONMENT" != "production" ] && [ "$ENVIRONMENT" != "staging" ]; then
        warning "Skipping image push for environment: $ENVIRONMENT"
        return
    fi
    
    log "Pushing images to registry..."
    
    # Login to registry (credentials should be provided by Jenkins)
    if [ -n "$DOCKER_USER" ] && [ -n "$DOCKER_PASS" ]; then
        echo $DOCKER_PASS | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin
    fi
    
    # Push backend image
    docker push ${DOCKER_REGISTRY}/${APP_NAME}-backend:${BUILD_NUMBER}
    docker push ${DOCKER_REGISTRY}/${APP_NAME}-backend:latest
    
    # Push frontend image
    docker push ${DOCKER_REGISTRY}/${APP_NAME}-frontend:${BUILD_NUMBER}
    docker push ${DOCKER_REGISTRY}/${APP_NAME}-frontend:latest
    
    success "Images pushed successfully"
}

# Deploy using docker-compose
deploy_with_compose() {
    log "Deploying with docker-compose..."
    
    # Export environment variables for docker-compose
    export BUILD_NUMBER
    export DOCKER_REGISTRY
    
    # Create environment file
    cat > .env << EOF
MONGO_USERNAME=mernuser
MONGO_PASSWORD=mernpass123
JWT_SECRET=your-super-secret-jwt-key-here
BUILD_NUMBER=${BUILD_NUMBER}
DOCKER_REGISTRY=${DOCKER_REGISTRY}
EOF
    
    # Deploy using docker-compose
    if [ "$ENVIRONMENT" == "production" ]; then
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose -f docker-compose.test.yml up -d
    fi
    
    success "Deployment completed"
}

# Health check after deployment
post_deploy_health_check() {
    log "Running post-deployment health checks..."
    
    # Wait for services to start
    sleep 30
    
    local endpoints=(
        "http://localhost:5000/ping"
        "http://localhost:5000/health"
        "http://localhost:5000/alive"
        "http://localhost/health"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -f "$endpoint" &> /dev/null; then
            success "Health check passed: $endpoint"
        else
            warning "Health check failed: $endpoint"
        fi
    done
    
    # Check container status
    log "Checking container status..."
    docker-compose ps
    
    success "Post-deployment health checks completed"
}

# Cleanup old resources
cleanup() {
    log "Cleaning up old resources..."
    
    # Remove old images (keep last 5 versions)
    docker images ${DOCKER_REGISTRY}/${APP_NAME}-backend --format "table {{.Tag}}" | tail -n +2 | sort -V | head -n -5 | xargs -r docker rmi ${DOCKER_REGISTRY}/${APP_NAME}-backend: 2>/dev/null || true
    
    # Clean up dangling images
    docker image prune -f
    
    success "Cleanup completed"
}

# Rollback function
rollback() {
    local previous_version=$1
    if [ -z "$previous_version" ]; then
        error "Previous version not specified for rollback"
        exit 1
    fi
    
    warning "Rolling back to version: $previous_version"
    
    # Update images to previous version
    docker-compose down
    
    export BUILD_NUMBER=$previous_version
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Rollback completed to version: $previous_version"
}

# Main deployment function
main() {
    local action=${1:-deploy}
    
    log "Starting Jenkins Docker deployment for $APP_NAME"
    log "Environment: $ENVIRONMENT"
    log "Build Number: $BUILD_NUMBER"
    log "Action: $action"
    
    case $action in
        "build")
            check_requirements
            build_images
            ;;
        "test")
            test_images
            ;;
        "push")
            push_images
            ;;
        "deploy")
            check_requirements
            build_images
            test_images
            push_images
            deploy_with_compose
            post_deploy_health_check
            cleanup
            ;;
        "rollback")
            rollback $2
            ;;
        *)
            error "Unknown action: $action"
            echo "Usage: $0 [build|test|push|deploy|rollback <version>]"
            exit 1
            ;;
    esac
    
    success "Jenkins deployment completed successfully!"
}

# Run main function with all arguments
main "$@"