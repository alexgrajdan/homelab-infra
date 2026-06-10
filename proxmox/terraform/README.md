# Proxmox Terraform Configuration

This directory contains Terraform configuration files for managing resources on a Proxmox VE server using a secure, encrypted secrets workflow.

## 🛠 Prerequisites

- **[Terraform](https://www.terraform.io/)** installed.
- **[SOPS](https://github.com/getsops/sops)** installed for secret encryption.
- **[age](https://github.com/FiloSottile/age)** installed for key management.
- Access to your Proxmox server and API credentials.

## 🔐 Secrets Management

We use **SOPS** with **age** to encrypt sensitive data. Secrets are stored in `secrets.enc.json` and decrypted on-the-fly by Terraform.

### 1. Configure Secrets
Create a temporary `secrets.json` file (this file is git-ignored):
```json
{
  "PROXMOX_URL": "https://<your-proxmox-ip>:8006/api2/json",
  "PROXMOX_TOKEN_ID": "user@pve!tokenid",
  "PROXMOX_TOKEN_SECRET": "uuid-secret-here",
  "PROXMOX_NODE": "<your-proxmox-node>",
  "VM_TEMPLATE": "<your-vm-template>",
  "VM_ID": <your-id>,
  "PROXMOX_CI_USER": "<your-user>",
  "PROXMOX_CI_PASSWORD": "securepassword",
  "PUBLIC_SSH_KEY": "ssh-rsa ..."
}
```
### 2. Encrypt with SOPS
Run the following command to create the encrypted file used by Terraform:
```bash
sops --encrypt --age <your-public-key> secrets.json > secrets.enc.json
```
> [!NOTE]  
> You can then safely delete the plain-text `secrets.json`.

## 🚀 Getting Started

### 1. Initialize Terraform
This will download the required providers (Telmate Proxmox and Carlpett SOPS):
```bash
terraform init
```

### 2. Review the Execution Plan
Terraform will automatically decrypt `secrets.enc.json` using your local age key:
```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

## 📂 Project Structure
- `provider.tf`: Defines the Proxmox and SOPS providers.
- `locals.tf`: Maps encrypted secrets to local variables for cleaner code.
- `demo-resources.tf`: Standalone demo VM resources.
- `k3s-resources.tf`: Configuration for the 3-master, 3-worker K3s cluster.
- `secrets.enc.json`: The encrypted vault containing all credentials.

## ⚠️ Notes
- **Security**: Decrypted secrets exist in plain text in `terraform.tfstate`. Ensure this file is never committed to version control.
- **Modifying Secrets**: To edit secrets, use `sops secrets.enc.json`. It will open your default editor and re-encrypt upon saving.