#!/bin/bash
# Navigate to the directory containing this script
cd "$(dirname "$0")"

# 1. Check for requirements
if ! command -v sops &> /dev/null; then 
    echo "Error: SOPS not found"; 
    exit 1; 
fi

if ! command -v packer &> /dev/null; then 
    echo "Error: Packer is not installed. Please install it from https://www.packer.io/downloads"; 
    exit 1; 
fi

if [ ! -f "secrets.enc.json" ]; then 
    echo "Error: secrets.enc.json not found"; 
    exit 1; 
fi

# 2. Define a temporary filename for the decrypted secrets
# We use a .json extension so Packer is happy
TEMP_SECRETS="tmp_secrets.json"

# 3. SET A TRAP: This ensures the file is deleted when the script exits
# (Whether it finishes successfully or crashes)
trap 'rm -f "$TEMP_SECRETS"; echo "Cleanup: Temporary secrets deleted."' EXIT

# 4. Decrypt the secrets to the temporary file
echo "Decrypting secrets..."
sops -d secrets.enc.json > "$TEMP_SECRETS"

# 5. Initialize Packer
echo "Initializing Packer plugins..."
packer init .

# 6. Run Packer build using the temporary file
echo "Starting Packer build..."
packer build -force -on-error=ask \
    -var-file="$TEMP_SECRETS" \
    .

echo "Build process completed!"