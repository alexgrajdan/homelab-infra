# Used to define local variables for Proxmox configuration and authentication, sourced from an encrypted secrets file using the sops provider.
locals {
  # Proxmox Configuration
  proxmox_url           = data.sops_file.my_secrets.data["PROXMOX_URL"]
  proxmox_token_id      = data.sops_file.my_secrets.data["PROXMOX_TOKEN_ID"]
  proxmox_token_secret  = data.sops_file.my_secrets.data["PROXMOX_TOKEN_SECRET"]
  proxmox_node          = data.sops_file.my_secrets.data["PROXMOX_NODE"]
  vm_template           = data.sops_file.my_secrets.data["VM_TEMPLATE"]
  vm_id                 = tonumber(data.sops_file.my_secrets.data["VM_ID"])

  
  # VM Auth
  ci_user      = data.sops_file.my_secrets.data["PROXMOX_CI_USER"]
  ci_password  = data.sops_file.my_secrets.data["PROXMOX_CI_PASSWORD"]
  ssh_key      = data.sops_file.my_secrets.data["PUBLIC_SSH_KEY"]
}