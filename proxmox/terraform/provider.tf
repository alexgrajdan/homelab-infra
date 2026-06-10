terraform {
    required_version = ">= 0.13.0"

  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 1.0.0" 
    }
  }
}

data "sops_file" "my_secrets" {
  source_file = "secrets.enc.json"
}

provider "proxmox" {
  pm_api_url          = local.proxmox_url
  pm_api_token_id     = local.proxmox_token_id
  pm_api_token_secret = local.proxmox_token_secret

  # NOTE Optional, but recommended to set to true if you are using self-signed certificates.
  pm_tls_insecure = true
}