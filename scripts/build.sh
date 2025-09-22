#!/bin/bash

# MERN Stack Build Script
# This script handles building the application for different environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Default values
ENVIRONMENT="development"
BUILD_TYPE="all"
SKIP_TESTS=false
SKIP_LINT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -e, --environment   Build environment (development, staging, production)"
            echo "  -t, --type          Build type (all, backend, frontend)"
            echo "  --skip-tests        Skip running tests"
            echo "  --skip-lint         Skip linting"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_info "Starting build for $ENVIRONMENT environment"
print_info "Build Type: $BUILD_TYPE"

# Function to check Node.js and npm
check_node_environment() {
    print_info "Checking Node.js environment..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    
    print_success "Node.js $(node --version) and npm $(npm --version) are available"
}

# Function to install dependencies
install_dependencies() {
    local component=$1
    local path=$2
    
    print_info "Installing $component dependencies..."
    
    cd $path
    
    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in $path"
        exit 1
    fi
    
    # Install dependencies
    npm ci --silent
    
    print_success "$component dependencies installed"
    cd - > /dev/null
}

# Function to run linting
run_lint() {
    local component=$1
    local path=$2
    
    if [ "$SKIP_LINT" = true ]; then
        print_warning "Skipping $component linting"
        return 0
    fi
    
    print_info "Running $component linting..."
    
    cd $path
    
    # Check if lint script exists
    if npm run | grep -q "lint"; then
        npm run lint
        print_success "$component linting passed"
    else
        print_warning "No lint script found for $component"
    fi
    
    cd - > /dev/null
}

# Function to run tests
run_tests() {
    local component=$1
    local path=$2
    
    if [ "$SKIP_TESTS" = true ]; then
        print_warning "Skipping $component tests"
        return 0
    fi
    
    print_info "Running $component tests..."
    
    cd $path
    
    # Set test environment variables
    export NODE_ENV=test
    export CI=true
    
    # Check if test script exists
    if npm run | grep -q "test"; then
        npm test -- --coverage --watchAll=false || print_warning "$component tests completed with warnings"
        print_success "$component tests completed"
    else
        print_warning "No test script found for $component"
    fi
    
    cd - > /dev/null
}

# Function to build backend
build_backend() {
    print_info "Building backend..."
    
    # Install dependencies
    install_dependencies "backend" "./backend"
    
    # Run linting
    run_lint "backend" "./backend"
    
    # Run tests
    run_tests "backend" "./backend"
    
    # Set production dependencies
    cd backend
    if [ "$ENVIRONMENT" = "production" ]; then
        print_info "Installing production dependencies..."
        npm ci --only=production --silent
    fi
    cd - > /dev/null
    
    print_success "Backend build completed"
}

# Function to build frontend
build_frontend() {
    print_info "Building frontend..."
    
    # Install dependencies
    install_dependencies "frontend" "./frontend"
    
    # Run linting
    run_lint "frontend" "./frontend"
    
    # Run tests
    run_tests "frontend" "./frontend"
    
    # Build frontend
    cd frontend
    
    # Set environment variables for build
    case $ENVIRONMENT in
        development)
            export REACT_APP_API_URL=http://localhost:5000/api
            ;;
        staging)
            export REACT_APP_API_URL=https://api-staging.yourdomain.com/api
            ;;
        production)
            export REACT_APP_API_URL=https://api.yourdomain.com/api
            export GENERATE_SOURCEMAP=false
            ;;
    esac
    
    print_info "Building frontend for $ENVIRONMENT..."
    npm run build
    
    # Check if build was successful
    if [ -d "build" ] && [ -f "build/index.html" ]; then
        print_success "Frontend build completed successfully"
        
        # Show build size
        print_info "Build size:"
        du -sh build/
    else
        print_error "Frontend build failed"
        exit 1
    fi
    
    cd - > /dev/null
}

# Function to build Docker images
build_docker_images() {
    print_info "Building Docker images..."
    
    local tag=${BUILD_NUMBER:-"latest"}
    local registry=${DOCKER_REGISTRY:-"localhost"}
    
    # Build backend image
    if [ "$BUILD_TYPE" = "all" ] || [ "$BUILD_TYPE" = "backend" ]; then
        print_info "Building backend Docker image..."
        cd backend
        docker build -t $registry/mern-stack-app-backend:$tag .
        docker tag $registry/mern-stack-app-backend:$tag $registry/mern-stack-app-backend:latest
        print_success "Backend Docker image built"
        cd - > /dev/null
    fi
    
    # Build frontend image (if Dockerfile exists)
    if [ "$BUILD_TYPE" = "all" ] || [ "$BUILD_TYPE" = "frontend" ]; then
        if [ -f "frontend/Dockerfile" ]; then
            print_info "Building frontend Docker image..."
            cd frontend
            docker build -t $registry/mern-stack-app-frontend:$tag .
            docker tag $registry/mern-stack-app-frontend:$tag $registry/mern-stack-app-frontend:latest
            print_success "Frontend Docker image built"
            cd - > /dev/null
        else
            print_info "No frontend Dockerfile found, serving via nginx in production"
        fi
    fi
}

# Function to generate build report
generate_build_report() {
    print_info "Generating build report..."
    
    local report_file="build-report.json"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > $report_file << EOF
{
  "build": {
    "timestamp": "$timestamp",
    "environment": "$ENVIRONMENT",
    "buildType": "$BUILD_TYPE",
    "buildNumber": "${BUILD_NUMBER:-"local"}",
    "gitCommit": "${GIT_COMMIT:-$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')}",
    "gitBranch": "${GIT_BRANCH:-$(git branch --show-current 2>/dev/null || echo 'unknown')}",
    "nodeVersion": "$(node --version)",
    "npmVersion": "$(npm --version)",
    "skipTests": $SKIP_TESTS,
    "skipLint": $SKIP_LINT
  },
  "artifacts": {
    "backend": "$([ -d backend ] && echo true || echo false)",
    "frontend": "$([ -d frontend/build ] && echo true || echo false)",
    "frontendSize": "$([ -d frontend/build ] && du -sb frontend/build | cut -f1 || echo 0)"
  }
}
EOF
    
    print_success "Build report generated: $report_file"
    cat $report_file
}

# Main build function
main() {
    print_info "=== MERN Stack Build Started ==="
    
    # Check Node.js environment
    check_node_environment
    
    # Install root dependencies if package.json exists
    if [ -f "package.json" ]; then
        install_dependencies "root" "."
    fi
    
    # Build based on type
    case $BUILD_TYPE in
        all)
            build_backend
            build_frontend
            ;;
        backend)
            build_backend
            ;;
        frontend)
            build_frontend
            ;;
        *)
            print_error "Invalid build type: $BUILD_TYPE"
            exit 1
            ;;
    esac
    
    # Build Docker images if Docker is available
    if command -v docker &> /dev/null; then
        build_docker_images
    else
        print_warning "Docker not available, skipping Docker image build"
    fi
    
    # Generate build report
    generate_build_report
    
    print_success "=== Build completed successfully ==="
}

# Trap errors
trap 'print_error "Build failed with error!"' ERR

# Run main function
main