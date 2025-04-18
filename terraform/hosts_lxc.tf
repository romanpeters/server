resource "proxmox_virtual_environment_container" "production" {
  vm_id      = "300"
  node_name  = "proxmox"
  protection = false
  started    = true
  tags = [
    "terraform",
  ]
  template     = false
  unprivileged = true

  cpu {
    architecture = "amd64"
    cores        = 2
    units        = 1024
  }

  disk {
    datastore_id = "local-zfs"
    size         = 16
  }

  initialization {
    hostname = "production"

    dns {
      servers = [
        "10.10.20.10",
        "10.10.20.1",
      ]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  memory {
    dedicated = 4096
    swap      = 512
  }

  network_interface {
    bridge      = "vmbr0"
    enabled     = true
    firewall    = false
    mac_address = local.hosts_map["production"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = local.hosts_map["production"].vlan
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = "nas:vztmpl/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}

resource "proxmox_virtual_environment_container" "adguard" {
  vm_id      = "301"
  node_name  = "proxmox"
  protection = false
  started    = true
  tags = [
    "terraform",
  ]
  template     = false
  unprivileged = true

  cpu {
    architecture = "amd64"
    cores        = 2
    units        = 1024
  }

  disk {
    datastore_id = "local-zfs"
    size         = 8
  }

  initialization {
    hostname = "adguard"

    dns {
      servers = [
        "10.10.10.254",
      ]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  memory {
    dedicated = 1024
    swap      = 512
  }

  network_interface {
    bridge      = "vmbr0"
    enabled     = true
    firewall    = false
    mac_address = local.hosts_map["adguard"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = local.hosts_map["adguard"].vlan
  }

  operating_system {
    type             = "nixos"
    template_file_id = "nas:vztmpl/nixos-system-x86_64-linux.tar.xz"
  }

}
