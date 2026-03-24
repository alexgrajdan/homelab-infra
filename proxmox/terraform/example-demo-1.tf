resource "proxmox_vm_qemu" "k3s_master" {
  count       = 3
  name        = format("k3s-master-%02d", count.index + 1)
  desc        = "Ubuntu Server 24.04 LTS - Master #${count.index + 1}"
  agent       = 1
  target_node = var.PROXMOX_NODE
  vmid        = var.VM_ID + count.index
  tags        = "terraform,k3s,master,test"

  clone      = var.VM_TEMPLATE
  full_clone = true

  onboot = true
  scsihw = "virtio-scsi-single"
  boot   = "order=scsi0;net0"

  cpu {
    cores   = 4
    type    = "x86-64-v2-AES"
    sockets = 1
  }
  memory = 4096

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
  ciuser     = var.PROXMOX_CI_USER
  cipassword = var.PROXMOX_CI_PASSWORD
  sshkeys    = var.PUBLIC_SSH_KEY
}

resource "proxmox_vm_qemu" "k3s_worker" {
  count       = 3
  name        = format("k3s-worker-%02d", count.index + 1)
  desc        = "Ubuntu Server 24.04 LTS - Worker #${count.index + 1}"
  agent       = 1
  target_node = var.PROXMOX_NODE
  vmid        = var.VM_ID + 3 + count.index # Începem de la VM_ID + 10 pentru a evita conflictele
  tags        = "terraform,k3s,worker,test"

  # Aceasta linie asigura ordinea: masters prima data, apoi workers
  depends_on = [proxmox_vm_qemu.k3s_master]

  clone      = var.VM_TEMPLATE
  full_clone = true

  onboot = true
  scsihw = "virtio-scsi-single"
  boot   = "order=scsi0;net0"

  cpu {
    cores   = 4
    type    = "x86-64-v2-AES"
    sockets = 1
  }
  memory = 4096

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
  ciuser     = var.PROXMOX_CI_USER
  cipassword = var.PROXMOX_CI_PASSWORD
  sshkeys    = var.PUBLIC_SSH_KEY
}
