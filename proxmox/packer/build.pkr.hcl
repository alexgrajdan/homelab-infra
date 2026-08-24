#######################################################################################
# BUILD
#######################################################################################  

build {
  name = "ubuntu-2604"
  sources = ["source.proxmox-iso.ubuntu-2604"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox
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
      "echo 'Ubuntu 26.04 Template by Packer - Creation date: $(date)' | sudo tee /etc/issue"
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
