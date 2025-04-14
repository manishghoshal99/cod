#!/bin/bash

# Exit on error
set -e

# Source OpenStack RC file
source openrc.sh

# Check if OpenStack credentials are set
if [ -z "$OS_USERNAME" ] || [ -z "$OS_PASSWORD" ] || [ -z "$OS_PROJECT_NAME" ]; then
    echo "Error: OpenStack credentials not set. Please check openrc.sh"
    exit 1
fi

# Run the main playbook
ansible-playbook -i inventory.ini main.yaml

# Verify the deployment
echo "Verifying deployment..."
ansible-playbook -i inventory.ini -l master_node verify.yaml

echo "NeCTAR setup completed successfully!" 