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
    mac_address = local.hosts["production"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = local.hosts["production"].vlan
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = "nas:vztmpl/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}


resource "proxmox_virtual_environment_container" "s3" {
  vm_id      = "107"
  node_name  = "proxmox"
  protection = true
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
    size         = 64
  }

  initialization {
    hostname = "s3"

    dns {
      servers = [
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
    mac_address = local.hosts["s3"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = local.hosts["s3"].vlan
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = "nas:vztmpl/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}
