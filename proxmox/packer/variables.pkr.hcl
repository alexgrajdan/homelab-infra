#######################################################################################
# VARIABLES
#######################################################################################

# Connection Variables
variable "PROXMOX_URL" {
  type        = string
  description = "Proxmox API URL"
}

variable "PROXMOX_USERNAME" {
  type        = string
  description = "Proxmox username for API operations"
}

variable "PROXMOX_TOKEN_SECRET" {
  type        = string
  description = "Proxmox API token secret"
  sensitive = true
}

variable "PROXMOX_NODE" {
  type        = string
  description = "Proxmox node to deploy the VM on"
}

# VM Identification
variable "VM_ID" {
  type        = number
  description = "Unique ID for the VM in Proxmox"
}

# VM ISO Settings
variable "ISO_FILE" {
  type        = string
  description = "Path to the ISO file for the VM"
}

variable "ISO_CHECKSUM" {
  type        = string
  description = "Checksum of the ISO file"
}

# VM Credentials
variable "SSH_USERNAME" {
  type        = string
  description = "Username for SSH access to the VM"
}

variable "SSH_PASSWORD" {
  type        = string
  description = "Password for SSH access to the VM"
  sensitive = true
}

variable "SSH_PASSWORD_HASH" {
  type        = string
  description = "Hashed password for SSH access to the VM"
  sensitive = true
}

variable "SSH_PUBLIC_KEY" {
  type        = string
  description = "Public SSH key for access to the VM"
}

variable "HOSTNAME" {
  type        = string
  description = "Hostname for the VM"
}