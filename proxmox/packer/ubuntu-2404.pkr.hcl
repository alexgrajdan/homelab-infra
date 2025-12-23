packer {
  required_plugins {
    proxmox = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

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


#######################################################################################
# LOCALS
#######################################################################################

locals {
    buildtime = formatdate("YYYY-MM-DD HH:mm ZZZ", timestamp())    
}

#######################################################################################
# SOURCE
#######################################################################################

source "proxmox-iso" "ubuntu-2404" {
  # Proxmox Connection Settings
  proxmox_url               = var.PROXMOX_URL
  username                  = var.PROXMOX_USERNAME
  token                     = var.PROXMOX_TOKEN_SECRET
  insecure_skip_tls_verify  = true
  node                      = var.PROXMOX_NODE

  # VM General Settings
  vm_id                     = var.VM_ID
  vm_name                   = "ubuntu-2404-template"
  template_description      = "Ubuntu 24.04 Server Template - built with Packer on ${local.buildtime}"

  # VM ISO Settings

  boot_iso {
    type              = "ide"
    iso_file          = var.ISO_FILE
    unmount           = true
    keep_cdrom_device = false
    iso_checksum      = var.ISO_CHECKSUM
  }

  # Explicitly set the boot order to prefer scsi0 (installed disk) over ide devices
  boot = "order=scsi0;net0;ide0"

  # VM System Settings
  qemu_agent = true
  cores      = "2"
  memory     = "2048"

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size     = "20G"
    format        = "raw"
    storage_pool  = "local-lvm"
    type          = "scsi"
    ssd           = true
  }

  # VM Network Settings
  network_adapters {
    model      = "virtio"
    bridge     = "vmbr0"
    firewall   = false
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Cloud-Init config via additional ISO
  additional_iso_files {
    type              = "ide"
    index             = 1
    iso_storage_pool  = "local"
    unmount           = true
    keep_cdrom_device = false
    cd_files = [
      "./http/meta-data",
      "./http/user-data",
    ]
    cd_label = "cidata"
  }

  # PACKER Boot Commands
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall quiet ds=nocloud",
    "<f10><wait>",
    "<wait1m>",
    "yes<enter>"
  ]

  # Comunication Settings
  ssh_username = var.SSH_USERNAME
  ssh_password = var.SSH_PASSWORD
  ssh_timeout  = "30m"
}
#######################################################################################
# BUILD
#######################################################################################  

build {
  name = "ubuntu-2404"
  sources = ["source.proxmox-iso.ubuntu-2404"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync",
      "echo 'Ubuntu 24.04 Template by Packer - Creation date: $(date)' | sudo tee /etc/issue"
    ]
  }

  # Added provisioner to forcibly eject ISO and prepare for reboot
  provisioner "shell" {
    inline = [
     "echo 'Completed installation, Preparing for template conversion...'",
     "echo 'Ejecting CD-ROM devices...'",
     "sudo eject /dev/sr0 || true",
     "sudo eject /dev/sr1 || true",
     "echo 'Removing CD-ROM entries from fstab if present...'",
     "sudo sed -i '/cdrom/d' /etc/fstab",
     "sudo sync",
     "echo 'Setting disk as boot device...'",
     "sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub",
     "sudo update-grub",
     "echo 'Clearing cloud-init status to ensure fresh start on first boot...'",
     "sudo cloud-init clean --logs",
     "echo 'Installation and cleanup completed successfully!'"
    ]
    expect_disconnect = true
  }
}
