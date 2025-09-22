# MERN Stack Application with CRUD Operations

A full-stack web application built with MongoDB, Express.js, React, and Node.js (MERN) that provides complete CRUD (Create, Read, Update, Delete) operations for user management.

## 🚀 Features

- **Full CRUD Operations**: Create, read, update, and delete users
- **Search Functionality**: Search users by name or email
- **Pagination**: Handle large datasets with pagination
- **Responsive Design**: Mobile-friendly UI using Bootstrap
- **Form Validation**: Client-side and server-side validation
- **Error Handling**: Comprehensive error handling throughout the application
- **REST API**: Well-structured RESTful API endpoints
- **Modern UI**: Clean and intuitive user interface

## 📁 Project Structure

```
mern_stack_application_jenkins_auto/
├── backend/                 # Backend server (Node.js/Express)
│   ├── models/             # Mongoose models
│   │   └── User.js        # User model
│   ├── routes/             # API routes
│   │   └── users.js       # User routes
│   ├── server.js          # Main server file
│   ├── package.json       # Backend dependencies
│   └── .env              # Environment variables
├── frontend/               # Frontend client (React)
│   ├── public/            # Public assets
│   ├── src/               # Source code
│   │   ├── components/    # React components
│   │   │   ├── Navigation.js
│   │   │   ├── UserList.js
│   │   │   ├── AddUser.js
│   │   │   └── EditUser.js
│   │   ├── services/      # API services
│   │   │   └── api.js
│   │   ├── App.js         # Main App component
│   │   ├── App.css        # App styles
│   │   ├── index.js       # React entry point
│   │   └── index.css      # Global styles
│   └── package.json       # Frontend dependencies
├── package.json           # Root package.json with scripts
└── README.md             # Project documentation
```

## 🛠️ Technologies Used

### Backend
- **Node.js**: JavaScript runtime environment
- **Express.js**: Web framework for Node.js
- **MongoDB**: NoSQL database
- **Mongoose**: MongoDB object modeling tool
- **CORS**: Cross-Origin Resource Sharing middleware
- **dotenv**: Environment variable management

### Frontend
- **React**: JavaScript library for building user interfaces
- **React Router**: Declarative routing for React
- **Bootstrap**: CSS framework for responsive design
- **React Bootstrap**: Bootstrap components for React
- **Axios**: HTTP client for making API requests

## 📋 Prerequisites

Before running this application, make sure you have the following installed:

- [Node.js](https://nodejs.org/) (version 14 or higher)
- [MongoDB](https://www.mongodb.com/) (running locally or MongoDB Atlas)
- [npm](https://www.npmjs.com/) (comes with Node.js)

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/pakkirappa/mern_stack_application_jenkins_auto.git
cd mern_stack_application_jenkins_auto
```

### 2. Install Dependencies

Install all dependencies for both frontend and backend:

```bash
npm run install-all
```

Or install separately:

```bash
# Install root dependencies
npm install

# Install backend dependencies
npm run install-server

# Install frontend dependencies
npm run install-client
```

### 3. Environment Configuration

Create a `.env` file in the backend directory (it's already created, but you may need to modify it):

```env
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/mernapp

# Server Configuration
PORT=5000
NODE_ENV=development

# JWT Secret (for future authentication features)
JWT_SECRET=your_jwt_secret_key_here

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
```

### 4. Start MongoDB

Make sure MongoDB is running on your system:

```bash
# On Windows
mongod

# On macOS/Linux
sudo mongod
```

Or use MongoDB Atlas (cloud database) by updating the MONGODB_URI in your `.env` file.

### 5. Run the Application

#### Development Mode (Recommended)

Start both frontend and backend simultaneously:

```bash
npm run dev
```

This will start:
- Backend server on `http://localhost:5000`
- Frontend development server on `http://localhost:3000`

#### Production Mode

Build the frontend and start the production server:

```bash
npm run build
npm run start
```

#### Run Separately

You can also run the frontend and backend separately:

```bash
# Terminal 1 - Backend
npm run server

# Terminal 2 - Frontend
npm run client
```

## 📚 API Endpoints

### User Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/users` | Get all users (with pagination) |
| GET    | `/api/users/:id` | Get user by ID |
| POST   | `/api/users` | Create a new user |
| PUT    | `/api/users/:id` | Update user by ID |
| DELETE | `/api/users/:id` | Delete user by ID |
| GET    | `/api/users/search/:query` | Search users by name or email |

### Health Check & Monitoring Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/ping` | Simple ping endpoint for load balancers |
| GET    | `/health` | Basic health check |
| GET    | `/health/detailed` | Detailed health check with system metrics |
| GET    | `/health/database` | Database-specific health check |
| GET    | `/health/dashboard` | Comprehensive health monitoring dashboard |
| GET    | `/ready` | Readiness probe (for Kubernetes) |
| GET    | `/alive` | Liveness probe (for Kubernetes) |
| GET    | `/metrics` | System metrics and performance data |

### Request/Response Examples

#### Create User (POST /api/users)

**Request:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "age": 30,
  "city": "New York",
  "phone": "+1-555-0123"
}
```

**Response:**
```json
{
  "message": "User created successfully",
  "user": {
    "_id": "64f8a1b2c3d4e5f6a7b8c9d0",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "age": 30,
    "city": "New York",
    "phone": "+1-555-0123",
    "createdAt": "2023-09-06T10:30:00.000Z",
    "updatedAt": "2023-09-06T10:30:00.000Z"
  }
}
```

#### Health Check Examples

**Basic Health Check (GET /health):**
```json
{
  "status": "OK",
  "timestamp": "2023-09-06T10:30:00.000Z",
  "uptime": 3600.5,
  "message": "Server is healthy",
  "version": "1.0.0"
}
```

**Detailed Health Check (GET /health/detailed):**
```json
{
  "status": "OK",
  "timestamp": "2023-09-06T10:30:00.000Z",
  "uptime": 3600.5,
  "version": "1.0.0",
  "environment": "development",
  "port": 5000,
  "healthCheckCount": 42,
  "checks": {
    "server": "OK",
    "database": {
      "status": "OK",
      "state": "connected",
      "name": "mernapp",
      "host": "localhost",
      "port": 27017,
      "responseTime": "5ms"
    },
    "memory": {
      "used": "45.6 MB",
      "total": "128.3 MB",
      "usage": "35%"
    },
    "system": {
      "nodeVersion": "v18.17.0",
      "platform": "win32",
      "architecture": "x64",
      "uptime": 3600.5,
      "pid": 1234
    }
  }
}
```

**System Metrics (GET /metrics):**
```json
{
  "system": {
    "nodeVersion": "v18.17.0",
    "platform": "win32",
    "architecture": "x64",
    "uptime": 3600.5,
    "pid": 1234,
    "startTime": "2023-09-06T09:30:00.000Z"
  },
  "memory": {
    "rss": 45.6,
    "heapTotal": 128.3,
    "heapUsed": 45.6,
    "external": 12.1,
    "heapUsedPercentage": 35
  },
  "cpu": {
    "user": 12345,
    "system": 6789
  },
  "timestamp": "2023-09-06T10:30:00.000Z"
}
```

## 🎯 Usage

1. **View Users**: Visit the home page to see all users with pagination
2. **Search Users**: Use the search bar to find users by name or email
3. **Add User**: Click "Add User" button to create a new user
4. **Edit User**: Click "Edit" on any user card to modify user information
5. **Delete User**: Click "Delete" on any user card to remove a user (with confirmation)

## 🔧 Available Scripts

### Root Directory

- `npm run dev` - Start both frontend and backend in development mode
- `npm run install-all` - Install all dependencies
- `npm run start` - Start both frontend and backend in production mode

### Backend Directory

- `npm start` - Start the backend server
- `npm run de v` - Start the backend server with nodemon (auto-restart)

### Frontend Directory

- `npm start` - Start the React development server
- `npm run build` - Build the React app for production
- `npm test` - Run the test suite

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check your MONGODB_URI in the .env file
   - Verify your internet connection if using MongoDB Atlas

2. **Port Already in Use**
   - Change the PORT in backend/.env file
   - Kill the process using the port: `npx kill-port 5000`

3. **CORS Errors**
   - Verify CORS_ORIGIN in backend/.env matches your frontend URL
   - Check that backend server is running

4. **Dependencies Issues**
   - Delete node_modules and package-lock.json
   - Run `npm run install-all` again

## � Docker Deployment

The application includes Docker support with built-in health checks:

### Build and Run with Docker

```bash
# Build the backend image
cd backend
docker build -t mern-backend .

# Run the container
docker run -p 5000:5000 -e MONGODB_URI="mongodb://host.docker.internal:27017/mernapp" mern-backend
```

### Docker Health Checks

The Docker container includes automatic health checks that run every 30 seconds:

```bash
# Check container health status
docker ps
# Look for "healthy" status

# View health check logs
docker inspect --format='{{json .State.Health}}' <container-id>
```

## ☸️ Kubernetes Deployment

Deploy to Kubernetes with comprehensive health checks:

```bash
# Apply the deployment
kubectl apply -f backend/k8s-deployment.yaml

# Check pod health
kubectl get pods
kubectl describe pod <pod-name>

# Check health endpoints
kubectl port-forward service/mern-backend-service 8080:80
curl http://localhost:8080/health
```

### Kubernetes Health Probes

The deployment includes three types of health probes:

- **Startup Probe**: `/health` - Ensures container starts properly
- **Liveness Probe**: `/alive` - Restarts container if unhealthy
- **Readiness Probe**: `/ready` - Controls traffic routing

## 📊 Health Monitoring

### Available Health Check Endpoints

1. **Basic Health** (`/health`) - Simple status check
2. **Detailed Health** (`/health/detailed`) - Comprehensive system information
3. **Database Health** (`/health/database`) - Database connectivity check
4. **Health Dashboard** (`/health/dashboard`) - All health checks in one response
5. **Readiness** (`/ready`) - Kubernetes readiness probe
6. **Liveness** (`/alive`) - Kubernetes liveness probe
7. **Metrics** (`/metrics`) - System performance metrics
8. **Ping** (`/ping`) - Simple load balancer check

### Monitoring Integration

These endpoints can be integrated with monitoring systems like:

- **Prometheus** - Use `/metrics` endpoint for metrics collection
- **Grafana** - Create dashboards using health data
- **AWS Application Load Balancer** - Use `/ping` or `/health` for health checks
- **Azure Load Balancer** - Configure health probes
- **Google Cloud Load Balancer** - Set up health checks
- **Kubernetes** - Automatic integration with liveness/readiness probes

## 🔧 Jenkins CI/CD Pipeline

This project includes a comprehensive Jenkins pipeline configuration for automated building, testing, and deployment.

### **Pipeline Features:**

- ✅ **Automated Building** - Build both frontend and backend
- ✅ **Testing** - Run unit tests and integration tests
- ✅ **Health Checks** - Test all health endpoints
- ✅ **Security Scanning** - Docker image vulnerability scanning
- ✅ **Docker Integration** - Build and push Docker images
- ✅ **Kubernetes Deployment** - Automated deployment to K8s
- ✅ **Notifications** - Slack notifications for build status
- ✅ **Multi-environment** - Support for dev, staging, production

### **Jenkins Setup:**

1. **Install Required Plugins:**
   ```bash
   # Install Jenkins plugins
   - Pipeline
   - Docker Pipeline
   - Kubernetes CLI
   - Slack Notification
   - Git
   - NodeJS
   - Blue Ocean (optional)
   ```

2. **Configure Credentials:**
   ```bash
   # Add these credentials in Jenkins
   - mongodb-uri: MongoDB connection string
   - docker-credentials: Docker registry username/password
   - docker-registry: Docker registry URL
   - kubeconfig: Kubernetes configuration file
   - slack-webhook: Slack webhook URL
   ```

3. **Create Pipeline Job:**
   - New Item → Pipeline
   - Pipeline script from SCM
   - Repository URL: Your Git repository
   - Script Path: `JenkinsFile`

### **Environment Variables:**

Configure these in Jenkins or `.env.jenkins`:

```bash
# Docker Configuration
DOCKER_REGISTRY=your-registry.com
DOCKER_NAMESPACE=mern-stack

# Database Configuration
MONGODB_URI=mongodb://your-mongodb-server:27017/mernapp

# Kubernetes Configuration
K8S_NAMESPACE_DEV=mern-dev
K8S_NAMESPACE_STAGING=mern-staging
K8S_NAMESPACE_PROD=mern-prod

# Notification Configuration
SLACK_CHANNEL=#deployments
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
```

### **Pipeline Stages:**

1. **📋 Preparation** - Clean workspace and checkout code
2. **🔧 Setup Environment** - Install Node.js and dependencies  
3. **📦 Install Dependencies** - Install npm packages for all components
4. **🔍 Code Quality & Security** - Linting and security audit
5. **🧪 Testing** - Run unit tests and generate coverage
6. **🏥 Health Check Tests** - Test all health endpoints
7. **🏗️ Build** - Build frontend and prepare backend
8. **🐳 Docker Build** - Create Docker images
9. **🔒 Security Scan** - Scan images for vulnerabilities
10. **🧪 Integration Tests** - Run integration tests
11. **📦 Push Images** - Push to Docker registry
12. **🚀 Deploy** - Deploy to Kubernetes
13. **✅ Post-Deployment Tests** - Verify deployment health

### **Manual Build Scripts:**

You can also run builds manually using the provided scripts:

```bash
# Build the application
./scripts/build.sh --environment production --type all

# Deploy the application  
./scripts/deploy.sh --environment production --type kubernetes

# Build and deploy in one command
npm run build && npm run deploy
```

### **Jenkins Pipeline Triggers:**

- **GitHub Webhook** - Automatic builds on push
- **Poll SCM** - Check for changes every 2 minutes
- **Scheduled Builds** - Nightly builds for testing
- **Manual Trigger** - Build on demand

### **Monitoring & Notifications:**

The pipeline includes comprehensive monitoring:

- **Build Status** - Success/failure notifications
- **Test Results** - Unit test and coverage reports
- **Health Checks** - Endpoint monitoring
- **Security Alerts** - Vulnerability scan results
- **Deployment Status** - Kubernetes rollout status

### **Multi-Environment Support:**

| Environment | Branch | Auto-Deploy | Health Checks |
|-------------|--------|-------------|---------------|
| Development | feature/* | ❌ | ✅ |
| Staging | develop | ✅ | ✅ |
| Production | main/master | ✅ | ✅ |

### **Pipeline Configuration Files:**

- `JenkinsFile` - Main pipeline definition
- `docker-compose.test.yml` - Integration testing setup
- `docker-compose.prod.yml` - Production deployment
- `scripts/build.sh` - Manual build script
- `scripts/deploy.sh` - Manual deployment script
- `jenkins/shared-library.groovy` - Reusable pipeline functions

## �📝 Future Enhancements

- User authentication and authorization
- Image upload functionality
- Email verification
- Data export/import features
- Advanced filtering and sorting
- User roles and permissions
- API rate limiting
- Unit and integration tests

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

- **Pakkirappa** - [GitHub Profile](https://github.com/pakkirappa)

## 🙏 Acknowledgments

- MongoDB community for excellent documentation
- Express.js team for the robust framework
- React team for the amazing library
- Bootstrap team for the responsive CSS framework