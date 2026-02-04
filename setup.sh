#!/bin/bash

# Setup script for LLM Frontend/Backend Application
# This script helps set up the development environment

set -e

echo "=========================================="
echo "LLM Application Setup Script"
echo "=========================================="
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "✅ Python $PYTHON_VERSION found"

# Check for Docker (optional)
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | sed 's/,//')
    echo "✅ Docker $DOCKER_VERSION found"
    HAS_DOCKER=true
else
    echo "⚠️  Docker not found (optional for deployment)"
    HAS_DOCKER=false
fi

echo ""
echo "=========================================="
echo "Setting up environment..."
echo "=========================================="

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env and add your API keys!"
    echo ""
fi

# Setup backend
echo "Setting up backend..."
cd llm-python
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Backend virtual environment created"
fi

source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✅ Backend dependencies installed"
deactivate
cd ..

# Setup frontend
echo "Setting up frontend..."
cd llm-frontend-python
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Frontend virtual environment created"
fi

source venv/bin/activate
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✅ Frontend dependencies installed"
deactivate
cd ..

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "To run the application locally:"
echo ""
echo "  Terminal 1 - Backend:"
echo "  $ cd llm-python"
echo "  $ source venv/bin/activate"
echo "  $ python3 -m uvicorn app.main:app --port 8080 --reload"
echo ""
echo "  Terminal 2 - Frontend:"
echo "  $ cd llm-frontend-python"
echo "  $ source venv/bin/activate"
echo "  $ python3 app.py"
echo ""
echo "  Then open: http://localhost:5000"
echo ""

if [ "$HAS_DOCKER" = true ]; then
    echo "Or run with Docker:"
    echo "  $ docker-compose up -d"
    echo ""
fi

echo "⚠️  Don't forget to:"
echo "  1. Edit .env and add your API keys"
echo "  2. Set up GitHub secrets for CI/CD"
echo "  3. Review CI-CD-README.md for deployment options"
echo ""
echo "Happy coding! 🚀"
