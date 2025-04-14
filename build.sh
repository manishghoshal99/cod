#!/bin/bash
# build.sh - Build, Test, and Deploy Automation Script for Big Data Analytics Project

# Exit immediately if a command exits with a non-zero status.
set -e

# Function: Build the Docker image for the backend API
build_backend_api() {
  echo "Building backend API Docker image..."
  docker build -t myproject-backend-api ./backend/api
}

# Function: Build Docker images for the harvesters (Mastodon, Reddit, BlueSky)
build_harvesters() {
  echo "Building Mastodon harvester Docker image..."
  docker build -t myproject-harvester-mastodon ./backend/harvesters/mastodon
  echo "Building Reddit harvester Docker image..."
  docker build -t myproject-harvester-reddit ./backend/harvesters/reddit
  echo "Building BlueSky harvester Docker image..."
  docker build -t myproject-harvester-bluesky ./backend/harvesters/bluesky
}

# Function: Install frontend dependencies (for Jupyter Notebook and utilities)
build_frontend() {
  echo "Installing frontend Python dependencies..."
  pushd frontend >/dev/null
  pip install -r requirements.txt
  popd >/dev/null
}

# Function: Run tests from the test folder using pytest
run_tests() {
  echo "Running backend tests..."
  pytest test/backend/
  echo "Running database tests..."
  pytest test/database/
  echo "Running integration tests..."
  pytest test/integration/
}

# Function: Deploy Kubernetes configurations for ElasticSearch, Jupyter, Fission, and storage.
deploy_k8s() {
  echo "Deploying ElasticSearch configuration..."
  kubectl apply -f kubernetes/elasticsearch.yaml
  
  echo "Deploying Jupyter Notebook configuration..."
  kubectl apply -f kubernetes/jupyter.yaml
  
  echo "Deploying Fission environments and functions..."
  kubectl apply -f kubernetes/fission/environments/python-env.yaml
  kubectl apply -f kubernetes/fission/functions/mastodon-harvester.yaml
  kubectl apply -f kubernetes/fission/functions/reddit-harvester.yaml
  kubectl apply -f kubernetes/fission/functions/bluesky-harvester.yaml
  echo "Deploying Fission triggers..."
  kubectl apply -f kubernetes/fission/triggers/http-triggers.yaml
  kubectl apply -f kubernetes/fission/triggers/time-triggers.yaml

  echo "Deploying persistent storage configuration..."
  kubectl apply -f kubernetes/storage.yaml
}

# Function: Run the Ansible playbook to set up the NeCTAR cloud infrastructure.
run_ansible() {
  echo "Executing NeCTAR setup via Ansible..."
  pushd ansible >/dev/null
  ./run-nectar.sh
  popd >/dev/null
}

# Display usage instructions
usage() {
  echo "Usage: $0 {build|test|deploy|ansible|all}"
  echo "  build   - Build Docker images for backend and harvesters and install frontend dependencies."
  echo "  test    - Run backend, database, and integration tests."
  echo "  deploy  - Deploy all Kubernetes configurations (ElasticSearch, Jupyter, Fission, storage)."
  echo "  ansible - Execute the Ansible playbook for NeCTAR infrastructure setup."
  echo "  all     - Run all tasks: build, test, deploy, and ansible."
  exit 1
}

# Main: Parse command-line argument
if [ $# -ne 1 ]; then
  usage
fi

case "$1" in
  build)
    build_backend_api
    build_harvesters
    build_frontend
    ;;
  test)
    run_tests
    ;;
  deploy)
    deploy_k8s
    ;;
  ansible)
    run_ansible
    ;;
  all)
    build_backend_api
    build_harvesters
    build_frontend
    run_tests
    deploy_k8s
    run_ansible
    ;;
  *)
    usage
    ;;
esac

echo "Task '$1' completed successfully." 