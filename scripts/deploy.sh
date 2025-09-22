#!/bin/bash

# MERN Stack Deployment Script
# This script handles deployment to different environments

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
BUILD_NUMBER=${BUILD_NUMBER:-"latest"}
GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse --short HEAD)}
DEPLOY_TYPE="docker-compose"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        -t|--type)
            DEPLOY_TYPE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -e, --environment   Deployment environment (development, staging, production)"
            echo "  -b, --build         Build number/tag"
            echo "  -t, --type          Deployment type (docker-compose, kubernetes)"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_info "Starting deployment for $ENVIRONMENT environment"
print_info "Build Number: $BUILD_NUMBER"
print_info "Git Commit: $GIT_COMMIT"
print_info "Deployment Type: $DEPLOY_TYPE"

# Validate environment
case $ENVIRONMENT in
    development|staging|production)
        print_success "Environment validated: $ENVIRONMENT"
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        print_error "Valid environments: development, staging, production"
        exit 1
        ;;
esac

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if [[ $DEPLOY_TYPE == "docker-compose" ]] && ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check kubectl for Kubernetes deployment
    if [[ $DEPLOY_TYPE == "kubernetes" ]] && ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to set environment variables
set_environment_variables() {
    print_info "Setting environment variables for $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        development)
            export MONGODB_URI=${DEV_MONGODB_URI:-"mongodb://localhost:27017/mernapp_dev"}
            export API_URL=${DEV_API_URL:-"http://localhost:5000"}
            export FRONTEND_URL=${DEV_FRONTEND_URL:-"http://localhost:3000"}
            ;;
        staging)
            export MONGODB_URI=${STAGING_MONGODB_URI:-"mongodb://staging-db:27017/mernapp_staging"}
            export API_URL=${STAGING_API_URL:-"https://api-staging.yourdomain.com"}
            export FRONTEND_URL=${STAGING_FRONTEND_URL:-"https://staging.yourdomain.com"}
            ;;
        production)
            export MONGODB_URI=${PROD_MONGODB_URI:-"mongodb://prod-db:27017/mernapp"}
            export API_URL=${PROD_API_URL:-"https://api.yourdomain.com"}
            export FRONTEND_URL=${PROD_FRONTEND_URL:-"https://yourdomain.com"}
            ;;
    esac
    
    export BUILD_NUMBER
    export GIT_COMMIT
    export ENVIRONMENT
    
    print_success "Environment variables set"
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    print_info "Deploying with Docker Compose..."
    
    local compose_file
    case $ENVIRONMENT in
        development)
            compose_file="docker-compose.test.yml"
            ;;
        staging|production)
            compose_file="docker-compose.prod.yml"
            ;;
    esac
    
    # Stop existing containers
    print_info "Stopping existing containers..."
    docker-compose -f $compose_file down || true
    
    # Pull latest images
    print_info "Pulling latest images..."
    docker-compose -f $compose_file pull
    
    # Start services
    print_info "Starting services..."
    docker-compose -f $compose_file up -d
    
    # Wait for services to be healthy
    print_info "Waiting for services to be healthy..."
    sleep 30
    
    # Check health
    check_deployment_health
    
    print_success "Docker Compose deployment completed"
}

# Function to deploy with Kubernetes
deploy_kubernetes() {
    print_info "Deploying with Kubernetes..."
    
    local namespace
    case $ENVIRONMENT in
        development)
            namespace=${K8S_NAMESPACE_DEV:-"mern-dev"}
            ;;
        staging)
            namespace=${K8S_NAMESPACE_STAGING:-"mern-staging"}
            ;;
        production)
            namespace=${K8S_NAMESPACE_PROD:-"mern-prod"}
            ;;
    esac
    
    # Create namespace if it doesn't exist
    kubectl create namespace $namespace || true
    
    # Apply deployment
    print_info "Applying Kubernetes manifests..."
    kubectl apply -f backend/k8s-deployment.yaml -n $namespace
    
    # Update image tag
    print_info "Updating image tag to $BUILD_NUMBER..."
    kubectl set image deployment/mern-backend mern-backend=${DOCKER_REGISTRY}/mern-stack-app-backend:${BUILD_NUMBER} -n $namespace
    
    # Wait for rollout
    print_info "Waiting for rollout to complete..."
    kubectl rollout status deployment/mern-backend -n $namespace --timeout=300s
    
    # Check deployment health
    check_kubernetes_health $namespace
    
    print_success "Kubernetes deployment completed"
}

# Function to check deployment health
check_deployment_health() {
    print_info "Checking deployment health..."
    
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_info "Health check attempt $attempt/$max_attempts..."
        
        # Check if backend is responding
        if curl -f http://localhost:5000/health &> /dev/null; then
            print_success "Backend health check passed"
            return 0
        fi
        
        print_warning "Health check failed, retrying in 30 seconds..."
        sleep 30
        ((attempt++))
    done
    
    print_error "Health check failed after $max_attempts attempts"
    return 1
}

# Function to check Kubernetes deployment health
check_kubernetes_health() {
    local namespace=$1
    print_info "Checking Kubernetes deployment health..."
    
    # Get pod status
    kubectl get pods -n $namespace -l app=mern-backend
    
    # Check if pods are ready
    local ready_pods=$(kubectl get pods -n $namespace -l app=mern-backend -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -o True | wc -l)
    local total_pods=$(kubectl get pods -n $namespace -l app=mern-backend --no-headers | wc -l)
    
    if [ $ready_pods -eq $total_pods ] && [ $total_pods -gt 0 ]; then
        print_success "All pods are ready ($ready_pods/$total_pods)"
    else
        print_error "Not all pods are ready ($ready_pods/$total_pods)"
        return 1
    fi
}

# Function to run post-deployment tests
run_post_deployment_tests() {
    print_info "Running post-deployment tests..."
    
    local base_url
    case $ENVIRONMENT in
        development)
            base_url="http://localhost:5000"
            ;;
        staging)
            base_url=$API_URL
            ;;
        production)
            base_url=$API_URL
            ;;
    esac
    
    # Test health endpoints
    print_info "Testing health endpoints..."
    
    curl -f $base_url/ping || { print_error "Ping test failed"; return 1; }
    print_success "Ping test passed"
    
    curl -f $base_url/health || { print_error "Health test failed"; return 1; }
    print_success "Health test passed"
    
    curl -f $base_url/alive || { print_error "Liveness test failed"; return 1; }
    print_success "Liveness test passed"
    
    curl -f $base_url/ready || { print_error "Readiness test failed"; return 1; }
    print_success "Readiness test passed"
    
    print_success "All post-deployment tests passed"
}

# Function to send notification
send_notification() {
    local status=$1
    local message=$2
    
    print_info "Sending notification..."
    
    # Send Slack notification if webhook URL is configured
    if [ -n "${SLACK_WEBHOOK_URL}" ]; then
        local color
        case $status in
            success) color="good" ;;
            warning) color="warning" ;;
            error) color="danger" ;;
        esac
        
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\", \"color\":\"$color\"}" \
            $SLACK_WEBHOOK_URL || print_warning "Failed to send Slack notification"
    fi
}

# Main deployment function
main() {
    print_info "=== MERN Stack Deployment Started ==="
    
    # Check prerequisites
    check_prerequisites
    
    # Set environment variables
    set_environment_variables
    
    # Deploy based on type
    case $DEPLOY_TYPE in
        docker-compose)
            deploy_docker_compose
            ;;
        kubernetes)
            deploy_kubernetes
            ;;
        *)
            print_error "Invalid deployment type: $DEPLOY_TYPE"
            exit 1
            ;;
    esac
    
    # Run post-deployment tests
    if run_post_deployment_tests; then
        send_notification "success" "🎉 $ENVIRONMENT deployment successful! Build: $BUILD_NUMBER, Commit: $GIT_COMMIT"
        print_success "=== Deployment completed successfully ==="
    else
        send_notification "error" "❌ $ENVIRONMENT deployment failed! Build: $BUILD_NUMBER, Commit: $GIT_COMMIT"
        print_error "=== Deployment failed ==="
        exit 1
    fi
}

# Trap errors and send failure notification
trap 'send_notification "error" "❌ $ENVIRONMENT deployment failed with error! Build: $BUILD_NUMBER, Commit: $GIT_COMMIT"' ERR

# Run main function
main