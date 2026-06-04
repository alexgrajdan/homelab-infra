# Proxmox Ubuntu 24.04 Packer Templates

This repository contains modular Packer templates for building Ubuntu 24.04 VM templates on Proxmox, featuring **SOPS + age** for secure secrets management.

## 🛠 Prerequisites

- [Packer](https://www.packer.io/) (v1.7.0+)
- [SOPS](https://github.com/getsops/sops) installed
- [age](https://github.com/FiloSottile/age) installed
- Access to Proxmox API

## 📂 File Structure

The configuration is split into multiple files for better maintainability:
- `packer.pkr.hcl`: Plugin requirements.
- `variables.pkr.hcl`: Definitions for all input variables.
- `locals.pkr.hcl`: Logic for timestamps and template naming.
- `source.pkr.hcl`: Proxmox VM hardware and ISO configuration.
- `build.pkr.hcl`: Shell provisioning and cleanup logic.
- `.sops.yaml`: Configuration for SOPS encryption rules.
- `secrets.enc.json`: **Encrypted** variable values.
- `build.sh`: Automation script for decryption and building.

## 🔐 Secrets Management (SOPS + age)

We use SOPS to ensure that sensitive data (passwords, tokens) is never stored in plaintext in Git.

### 1. Setup your age key
The build script expects your private key to be located at `~/.sops/age.agekey`. If you haven't generated one yet:
```bash
mkdir -p ~/.sops
age-keygen -o ~/.sops/age.agekey
```

### 2. Configure secrets
Create a file named `secrets.enc.json` in JSON format. Ensure all keys match the variables defined in `variables.pkr.hcl`:

```json
{
  "PROXMOX_URL": "https://your-proxmox:8006/api2/json",
  "PROXMOX_USERNAME": "your-user@pam!your-user",
  "PROXMOX_TOKEN_SECRET": "your-token",
  "PROXMOX_NODE": "your-pve-node",
  "VM_ID": "replace-with-any-number-and-remove-quotes",
  "ISO_FILE": "local:iso/ubuntu-24.04-live-server-amd64.iso",
  "ISO_CHECKSUM": "your-checksum",
  "SSH_USERNAME": "your-username",
  "SSH_PASSWORD": "yourpassword",
  "SSH_PASSWORD_HASH": "yourhash",
  "SSH_PUBLIC_KEY": "ssh-rsa ...",
  "HOSTNAME": "ubuntu-template"
}
```

### 3. Encrypt the file
Use the pre-configured `.sops.yaml` rules to encrypt the file:
```bash
sops -e -i secrets.enc.json
```

### 4. Editing secrets
To update your passwords or tokens, simply run:
```bash
sops secrets.enc.json
```
This will decrypt the file in memory, open your default editor, and re-encrypt it automatically upon saving.

## 🚀 Running the Build
The provided `build.sh` script handles the complexity of decrypting secrets to a temporary location and triggering the Packer build.
```bash
chmod +x build.sh
./build.sh
```

### What the script does:
1. Decrypts secrets.enc.json into a temporary tmp_secrets.json file.
2. Sets a shell trap to ensure the temporary plaintext file is deleted even if the build fails or is cancelled.
3. Initializes Packer and runs the build against the current directory.

## 📝 Notes
- **Git Security**: The `.gitignore` is configured to ignore any `tmp_secrets.json` or `.pkrvars.hcl` files. Only `secrets.enc.json` (the encrypted version) should be committed to the repository.
- **Cleanup**: The template build process includes a cleanup stage that removes unique identifiers (machine-id) and clears cloud-init logs to ensure the template is "clean" for cloning.