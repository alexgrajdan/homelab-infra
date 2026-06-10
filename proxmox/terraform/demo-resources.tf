resource "proxmox_vm_qemu" "example-demo-1" {
    name = "example-demo-1"
    desc = "Ubuntu Server 24.04 LTS"

    agent = 1
    target_node = var.PROXMOX_NODE
    vmid = var.VM_ID
    tags = "terraform"    # for multiple tags, use a single string with comma-separated tags, e.g. "tag1,tag2"

    clone = var.VM_TEMPLATE
    full_clone = true

    onboot = true
    scsihw = "virtio-scsi-single"
    boot = "order=scsi0;net0"

    cpu {
        cores = 2
        type = "x86-64-v2-AES"
        sockets = 1
    }
    memory = 2048

    network {
        id = 0
        bridge = "vmbr0"
        model = "virtio"        
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
                    size = "32G"
                    }
            }
        }
    }

    serial {
        id = 0
        type = "socket"
    }

    ipconfig0 = "ip=dhcp"
    ciuser = var.PROXMOX_CI_USER
    cipassword = var.PROXMOX_CI_PASSWORD
    sshkeys = var.PUBLIC_SSH_KEY
}