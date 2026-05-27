source "proxmox-iso" "ubuntu-2404" {
  proxmox_url               = var.PROXMOX_URL
  username                  = var.PROXMOX_USERNAME
  token                     = var.PROXMOX_TOKEN_SECRET
  insecure_skip_tls_verify  = true
  node                      = var.PROXMOX_NODE

  vm_id                     = var.VM_ID
  vm_name                   = "ubuntu-2404-template"
  template_description      = "Ubuntu 24.04 Server Template - built with Packer on ${local.buildtime}"
  tags                      = "packer;template"

  boot_iso {
    type              = "ide"
    iso_file          = var.ISO_FILE
    unmount           = true
    keep_cdrom_device = false
    iso_checksum      = var.ISO_CHECKSUM
  }

  boot = "order=scsi0;net0;ide0"
  qemu_agent = true
  cores      = "2"
  memory     = "2048"
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size     = "20G"
    format        = "raw"
    storage_pool  = "local-lvm"
    type          = "scsi"
    ssd           = true
  }

  network_adapters {
    model      = "virtio"
    bridge     = "vmbr0"
    firewall   = false
  }

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

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

  ssh_username = var.SSH_USERNAME
  ssh_password = var.SSH_PASSWORD
  ssh_timeout  = "30m"
}