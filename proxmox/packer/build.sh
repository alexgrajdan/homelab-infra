#!/bin/bash
# Navigate to the directory containing this script
cd "$(dirname "$0")"

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install it from https://www.packer.io/downloads"
    exit 1
fi

# Check if secrets file exists
if [ ! -f "secrets.pkrvars.hcl" ]; then
    echo "Creating example secrets file..."
    cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
    echo "Please edit secrets.pkrvars.hcl with your actual credentials before running this script again."
    exit 1
fi

# Initialize Packer plugins
echo "Initializing Packer plugins..."
# CHANGE: Point to the directory (.) instead of a single file
packer init .

# Run Packer build with both variable files
echo "Starting Packer build..."

packer build -force -on-error=ask \
    -var-file=secrets.pkrvars.hcl \
    .

echo "Build process completed!"