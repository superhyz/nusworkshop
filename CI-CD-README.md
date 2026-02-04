# CI/CD Pipeline Setup Guide

This repository includes a comprehensive CI/CD pipeline using GitHub Actions for automated testing, building, and deployment of the LLM Frontend and Backend applications.

## Pipeline Overview

The pipeline consists of the following jobs:

1. **Backend Tests** - Linting, unit tests, and coverage for the FastAPI backend
2. **Frontend Tests** - Linting and validation for the Flask frontend
3. **Integration Tests** - End-to-end testing of both services working together
4. **Security Scan** - Dependency vulnerability scanning
5. **Docker Build** - Building and pushing Docker images (main branch only)
6. **Deploy** - Automated deployment to production (main branch only)

## Required GitHub Secrets

To use this pipeline, configure the following secrets in your GitHub repository:

### Docker Hub Secrets (for Docker build job)
- `DOCKER_USERNAME` - Your Docker Hub username
- `DOCKER_PASSWORD` - Your Docker Hub password or access token

### Deployment Secrets (for deploy job)
- `DEPLOY_HOST` - SSH host for your deployment server
- `DEPLOY_USER` - SSH username
- `DEPLOY_SSH_KEY` - SSH private key for authentication
- `DEPLOY_URL` - Public URL of your deployed application

### Application Secrets (for runtime)
- `OPENAI_API_KEY` - OpenAI API key (if using OpenAI)
- `ANTHROPIC_API_KEY` - Anthropic API key (if using Claude)

## Setting Up GitHub Secrets

1. Go to your GitHub repository
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its corresponding value

## Pipeline Triggers

The pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

## Docker Setup

### Building Images Locally

```bash
# Build backend
docker build -f Dockerfile.backend -t llm-backend:latest ./llm-python

# Build frontend
docker build -f Dockerfile.frontend -t llm-frontend:latest ./llm-frontend-python
```

### Running with Docker Compose

```bash
# Create .env file with your API keys
cat > .env << EOF
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
EOF

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Accessing the Application

- Frontend: http://localhost:5000
- Backend API: http://localhost:8080
- Backend Health: http://localhost:8080/health

## Deployment Options

### Option 1: Docker Compose on VPS/Cloud

1. SSH into your server
2. Clone the repository
3. Create `.env` file with secrets
4. Run `docker-compose up -d`

### Option 2: Kubernetes

Convert the docker-compose.yml to Kubernetes manifests:

```bash
# Install kompose
curl -L https://github.com/kubernetes/kompose/releases/download/v1.31.2/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin/

# Convert to Kubernetes
kompose convert -f docker-compose.yml

# Apply to cluster
kubectl apply -f .
```

### Option 3: AWS ECS/Fargate

1. Push images to ECR
2. Create ECS task definitions
3. Create ECS service
4. Configure load balancer

### Option 4: Google Cloud Run

```bash
# Deploy backend
gcloud run deploy llm-backend \
  --image $DOCKER_USERNAME/llm-backend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Deploy frontend
gcloud run deploy llm-frontend \
  --image $DOCKER_USERNAME/llm-frontend:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars BACKEND_URL=<backend-url>
```

## Customizing the Pipeline

### Skip Docker Build

Comment out or remove the `docker-build` and `deploy` jobs if you don't need them.

### Change Python Version

Update the `PYTHON_VERSION` environment variable in `.github/workflows/ci-cd.yml`.

### Add More Tests

Add test files in your backend/frontend directories and they'll be picked up by pytest.

### Modify Deployment

Update the `deploy` job in the workflow file to match your infrastructure (AWS, GCP, Azure, etc.).

## Monitoring and Logs

### View GitHub Actions Logs

1. Go to the **Actions** tab in your repository
2. Click on a workflow run
3. Click on individual jobs to see detailed logs

### View Docker Container Logs

```bash
# View backend logs
docker logs llm-backend

# View frontend logs
docker logs llm-frontend

# Follow logs in real-time
docker logs -f llm-backend
docker logs -f llm-frontend
```

## Troubleshooting

### Pipeline Fails on Backend Tests

- Check if all dependencies are in `requirements.txt`
- Ensure test files are properly structured
- Verify Python version compatibility

### Pipeline Fails on Integration Tests

- Check if ports 8080 and 5000 are available
- Verify backend health endpoint returns 200
- Check backend URL configuration in frontend

### Docker Build Fails

- Verify Dockerfile paths are correct
- Check if all required files are present
- Ensure `.dockerignore` isn't excluding necessary files

### Deployment Fails

- Verify all deployment secrets are set correctly
- Check SSH key format (should be private key)
- Ensure deployment server is accessible
- Verify docker-compose is installed on deployment server

## Best Practices

1. **Branch Protection**: Enable branch protection on `main` to require PR reviews
2. **Environment Secrets**: Use GitHub Environments for production secrets
3. **Version Tagging**: Tag releases for better version tracking
4. **Rollback Strategy**: Keep previous Docker image versions for quick rollbacks
5. **Monitoring**: Set up application monitoring (e.g., Datadog, New Relic)
6. **Alerts**: Configure GitHub Actions notifications for failed builds

## Local Development

For local development without Docker:

```bash
# Terminal 1 - Backend
cd llm-python
python3 -m uvicorn app.main:app --port 8080 --reload

# Terminal 2 - Frontend
cd llm-frontend-python
python3 app.py

# Open http://localhost:5000
```

## Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Ensure all tests pass locally
4. Create a pull request to `develop`
5. After review, merge to `develop`
6. Periodically merge `develop` to `main` for production releases

## Support

For issues with the CI/CD pipeline:
1. Check the Actions tab for detailed error logs
2. Review this README for common issues
3. Create an issue in the repository with error details
