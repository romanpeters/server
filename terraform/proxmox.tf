resource "proxmox_vm_qemu" "homeassistant" {
  vmid        = 201
  name        = "HomeAssistant"
  target_node = "proxmox"

  memory      = 4096
  cores       = 1
  sockets     = 2
  bios        = "ovmf"
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          backup  = true
          size    = "64G"
          storage = "local-zfs"
        }
      }
    }
  }

  network {
    bridge    = "vmbr0"
    firewall  = false
    id        = 0
    link_down = false
    macaddr   = "de:53:8c:82:a2:84"
    model     = "virtio"
    tag       = 0
  }

  full_clone             = false
  define_connection_info = false
  onboot                 = true
  vm_state               = "running"
  protection             = true
  agent                  = 1
  tags                   = "terraform"
}

resource "proxmox_vm_qemu" "ansible" {
  vmid        = 204
  name        = "AAP"
  target_node = "proxmox"

  cpu_type    = "x86-64-v2-AES"
  bios        = "seabios"
  boot        = "order=scsi0;net0"
  cores       = 1
  memory      = 6144
  scsihw      = "virtio-scsi-single"
  sockets     = 4

  disks {
    scsi {
      scsi0 {
        disk {
          backup  = true
          size    = "64G"
          storage = "local-zfs"
        }
      }
    }
  }

  network {
    bridge    = "vmbr0"
    firewall  = false
    id        = 0
    link_down = false
    macaddr   = "bc:24:11:4a:98:b6"
    model     = "virtio"
    tag       = 20
  }

  full_clone             = false
  define_connection_info = false
  onboot                 = true
  vm_state               = "running"
  tags                   = "terraform"
}

resource "proxmox_lxc" "production" {
  vmid        = 300
  hostname    = "production"
  target_node = "proxmox"

  ostemplate  = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  cores       = 2
  memory      = 1024
  swap        = 512

  rootfs {
    storage = "local-zfs"
    size    = "16G"
  }

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "dhcp"
    tag     = 20
  }

  nameserver        = "10.10.20.10 10.10.20.1"
  onboot            = true
  start             = true
  password          = var.root_password
  ssh_public_keys   = var.ssh_key
  tags              = "terraform"
}
