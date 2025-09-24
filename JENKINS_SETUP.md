# Jenkins Docker Deployment Setup Guide

This guide will help you set up Jenkins to deploy your MERN stack application using Docker.

## Prerequisites

### 1. Jenkins Server Requirements
- Jenkins 2.400+ with Blue Ocean plugin
- Docker installed on Jenkins server
- Docker Compose installed
- Git plugin
- NodeJS plugin
- Docker Pipeline plugin
- Slack notification plugin (optional)

### 2. Required Jenkins Plugins
```bash
# Install these plugins in Jenkins
- Docker Pipeline
- Docker Commons Plugin
- NodeJS Plugin
- Git Plugin
- Blue Ocean
- Slack Notification Plugin
- Pipeline: Stage View Plugin
- Build Timeout Plugin
- Timestamper Plugin
```

### 3. Jenkins Server Setup
```bash
# Install Docker on Jenkins server (Ubuntu/Debian)
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Verify installation
docker --version
docker-compose --version
```

## Jenkins Configuration

### 1. Create Jenkins Credentials

#### a) Docker Registry Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add new Username/Password credential
   - ID: `docker-credentials`
   - Username: Your Docker registry username
   - Password: Your Docker registry password/token

#### b) MongoDB URI (if using external MongoDB)
1. Add Secret Text credential
   - ID: `mongodb-uri`
   - Secret: Your MongoDB connection string

#### c) Docker Registry URL
1. Add Secret Text credential
   - ID: `docker-registry`
   - Secret: Your Docker registry URL (e.g., `your-registry.com`)

#### d) Kubernetes Config (if using K8s)
1. Add Secret File credential
   - ID: `kubeconfig`
   - File: Your kubeconfig file

### 2. Configure Global Tools

#### a) NodeJS Installation
1. Go to Jenkins → Manage Jenkins → Global Tool Configuration
2. Add NodeJS installation:
   - Name: `Node18`
   - Version: `18.x`
   - Install automatically: ✓

#### b) Docker Installation
1. Ensure Docker is available in PATH
2. Test: `docker --version` in Jenkins console

### 3. Environment Variables
Set these in Jenkins → Manage Jenkins → Configure System → Global Properties:

```properties
# Application Configuration
APP_NAME=mern-stack-app
NODE_ENV=production

# Docker Configuration
DOCKER_REGISTRY=your-registry.com
DOCKER_NAMESPACE=mern-stack

# Deployment Configuration
DEPLOY_ENV=production
HEALTH_CHECK_TIMEOUT=300

# Slack Configuration (optional)
SLACK_CHANNEL=#deployments
```

## Pipeline Setup

### 1. Create New Pipeline Job
1. Jenkins → New Item → Pipeline
2. Name: `mern-stack-app-deploy`
3. Configure:
   - ✓ GitHub project: Your repository URL
   - ✓ Build Triggers: GitHub hook trigger for GITScm polling
   - Pipeline Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your Git repository
   - Branch: `*/main` (or your default branch)
   - Script Path: `JenkinsFile`

### 2. Webhook Configuration (GitHub)
1. Go to your GitHub repository → Settings → Webhooks
2. Add webhook:
   - Payload URL: `http://your-jenkins-server/github-webhook/`
   - Content type: `application/json`
   - Events: Just the push event

### 3. Branch Protection (Optional)
Configure branch protection rules in GitHub:
- Require status checks to pass
- Require pull request reviews
- Restrict who can push to matching branches

## Deployment Configuration

### 1. Update Environment Files

#### `.env.docker` (for production)
```bash
# Copy and customize the environment file
cp .env.docker .env.production

# Update with your production values:
DOCKER_REGISTRY=your-registry.com
MONGO_USERNAME=prod_user
MONGO_PASSWORD=secure_production_password
JWT_SECRET=your-super-secret-production-jwt-key
```

#### `.env.jenkins` (for Jenkins-specific config)
```bash
# Update registry and notification settings
DOCKER_REGISTRY=your-registry.com
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
SONAR_HOST_URL=https://sonarqube.yourdomain.com
```

### 2. Docker Registry Setup

#### Using Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag and push images
docker tag mern-stack-app-backend:latest your-dockerhub-username/mern-stack-app-backend:latest
docker push your-dockerhub-username/mern-stack-app-backend:latest
```

#### Using Private Registry
```bash
# Login to private registry
docker login your-registry.com

# Update DOCKER_REGISTRY in environment files
```

### 3. Production Server Setup

#### Using Docker Compose
```bash
# On production server
git clone your-repository
cd mern_stack_application_jenkins_auto

# Copy environment file
cp .env.docker .env

# Update production values in .env
nano .env

# Deploy
docker-compose -f docker-compose.jenkins.yml up -d
```

#### Using Kubernetes
```bash
# Apply Kubernetes manifests
kubectl apply -f backend/k8s-deployment.yaml

# Update deployment with new images (handled by Jenkins)
kubectl set image deployment/mern-backend mern-backend=your-registry.com/mern-stack-app-backend:latest
```

## Monitoring and Troubleshooting

### 1. Health Checks
The pipeline includes comprehensive health checks:
- Application ping endpoints
- Database connectivity
- Service availability
- Performance metrics

### 2. Logging
```bash
# View application logs
docker-compose -f docker-compose.jenkins.yml logs backend
docker-compose -f docker-compose.jenkins.yml logs frontend

# View Jenkins build logs
# Available in Jenkins web interface
```

### 3. Troubleshooting Common Issues

#### Build Failures
```bash
# Check Docker daemon
sudo systemctl status docker

# Check disk space
df -h

# Clean up Docker resources
docker system prune -f
```

#### Deployment Issues
```bash
# Check running containers
docker ps

# Check container logs
docker logs container_name

# Restart services
docker-compose restart
```

#### Network Issues
```bash
# Check Docker networks
docker network ls

# Inspect network configuration
docker network inspect mern-network
```

## Security Best Practices

### 1. Secrets Management
- Use Jenkins credentials store
- Never commit secrets to repository
- Rotate secrets regularly
- Use strong passwords and keys

### 2. Image Security
```bash
# Scan images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image your-image:tag

# Use official base images
# Keep base images updated
# Run containers as non-root user
```

### 3. Network Security
- Use private Docker networks
- Implement proper firewall rules
- Use HTTPS in production
- Restrict container capabilities

## Performance Optimization

### 1. Build Optimization
- Use multi-stage Docker builds
- Leverage Docker layer caching
- Minimize image sizes
- Use .dockerignore files

### 2. Deployment Optimization
- Implement rolling updates
- Use health checks
- Configure resource limits
- Monitor performance metrics

### 3. Jenkins Optimization
- Clean up old builds
- Use pipeline parallel stages
- Optimize Jenkins heap size
- Use build agents for scaling

## Backup and Recovery

### 1. Database Backups
```bash
# MongoDB backup
docker exec mongodb mongodump --out /backup

# Schedule regular backups
0 2 * * * docker exec mongodb mongodump --out /backup/$(date +\%Y-\%m-\%d)
```

### 2. Application Backups
- Backup Docker images
- Backup configuration files
- Backup SSL certificates
- Version control all infrastructure code

## Production Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Security scan completed
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Monitoring configured
- [ ] Backup strategy implemented

### Post-Deployment
- [ ] Health checks passing
- [ ] Application accessible
- [ ] Database connectivity verified
- [ ] Logs being generated
- [ ] Monitoring alerts configured
- [ ] Performance metrics normal

## Additional Resources

### Documentation Links
- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MongoDB Docker Documentation](https://hub.docker.com/_/mongo)
- [Nginx Docker Documentation](https://hub.docker.com/_/nginx)

### Monitoring Tools
- Prometheus + Grafana for metrics
- ELK Stack for log aggregation
- Jaeger for distributed tracing
- Slack for notifications

### Useful Commands
```bash
# Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/

# Docker management
docker system df  # Check Docker disk usage
docker system prune -a  # Clean up everything
docker-compose logs -f  # Follow logs

# Kubernetes management
kubectl get pods
kubectl logs pod-name
kubectl describe pod pod-name
```

This setup provides a robust, scalable, and maintainable deployment pipeline for your MERN stack application using Jenkins and Docker.