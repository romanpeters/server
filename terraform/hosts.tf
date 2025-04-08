resource "proxmox_vm_qemu" "server" {
  #vmid        = 200
  name        = "server"
  target_node = "proxmox"
  memory      = 8192
  cores       = 2
  sockets     = 4
  bios        = "seabios"
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  disks {
    scsi {
      scsi0 {
        disk {
          backup  = true
          size    = "160G"
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
    macaddr   = local.hosts_map["server"].mac
    model     = "virtio"
    tag       = 20
  }
  full_clone             = false
  define_connection_info = false
  onboot                 = true
  vm_state               = "running"
  protection             = true
  tags                   = "terraform"
}

resource "proxmox_vm_qemu" "homeassistant" {
  vmid        = 201
  name        = "homeassistant"
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
    macaddr   = local.hosts_map["homeassistant"].mac
    model     = "virtio"
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
  name        = "ansible"
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
    macaddr   = local.hosts_map["ansible"].mac
    model     = "virtio"
    tag       = 20
  }
  full_clone             = false
  define_connection_info = false
  onboot                 = true
  vm_state               = "running"
  agent                  = 1
  tags                   = "terraform"
}

resource "proxmox_lxc" "production" {
  vmid        = 300
  hostname    = "production"
  target_node = "proxmox"
  ostemplate  = "nas:vztmpl/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
  unprivileged = true
  ostype       = "ubuntu"
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
    hwaddr  = local.hosts_map["production"].mac
    tag     = 20
  }
  features {
    nesting = true
  }
  nameserver        = "10.10.20.10 10.10.20.1"
  onboot            = true
  start             = true
  password          = var.root_password
  ssh_public_keys   = var.ssh_key
  tags              = "terraform"
}

resource "proxmox_lxc" "adguard" {
  vmid        = 301
  hostname    = "adguard"
  target_node = "proxmox"
  ostemplate  = "nas:vztmpl/nixos-system-x86_64-linux.tar.xz"
  unprivileged = true
  ostype      = "nixos"
  cores       = 2
  memory      = 1024
  swap        = 512
  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "dhcp"
    hwaddr  = local.hosts_map["adguard"].mac
  }
  features {
    nesting = true
  }
  nameserver        = "10.10.20.10 10.10.20.1"
  onboot            = true
  start             = true
  ssh_public_keys   = var.ssh_key
  tags              = "terraform"
}