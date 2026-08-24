resource "proxmox_vm_qemu" "linux-training" {
  name        = "linux-training"
  description = "Demo Ubuntu Server 26.04 LTS"

  agent       = 1
  target_node = local.proxmox_node
  vmid        = local.vm_id + 500
  tags        = "terraform,test" # for multiple tags, use a single string with comma-separated tags, e.g. "tag1,tag2"

  clone      = local.vm_template
  full_clone = true

  start_at_node_boot = true
  scsihw             = "virtio-scsi-single"
  boot               = "order=scsi0;net0"

  cpu {
    cores   = 2
    type    = "x86-64-v2-AES"
    sockets = 1
  }
  memory = 2048

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  disks {
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "32G"
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  ipconfig0  = "ip=dhcp"
  ciuser     = local.ci_user
  cipassword = local.ci_password
  sshkeys    = local.ssh_key
}