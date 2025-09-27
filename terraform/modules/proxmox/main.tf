
resource "proxmox_virtual_environment_container" "production" {
  vm_id      = "100"
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

    user_account {
      password = var.root_password
      keys     = [var.ssh_key]
    }

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
    mac_address = var.hosts["production"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = var.hosts["production"].vlan
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = var.ubuntu_lxc_template
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
  unprivileged = false

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

    user_account {
      password = var.root_password
      keys     = [var.ssh_key]
    }

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
    mac_address = var.hosts["s3"].mac
    mtu         = 0
    name        = "eth0"
    rate_limit  = 0
    vlan_id     = var.hosts["s3"].vlan
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = var.ubuntu_lxc_template
  }

  features {
    nesting = true
  }

  mount_point {
    volume = "/mnt/pve/containers"
    path   = "/mnt/containers"
  }
}

resource "proxmox_virtual_environment_vm" "server25" {
  acpi          = true
  description   = "Managed by Terraform."
  name          = "server"
  node_name     = "proxmox"
  started       = true
  scsi_hardware = "virtio-scsi-pci"
  tags = [
    "terraform",
  ]
  template = false
  vm_id    = 210

  clone {
    vm_id = 500
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  cpu {
    cores   = 2
    sockets = 4
    type    = "host"
  }


  boot_order = ["scsi0"]

  initialization {
    datastore_id = "local-zfs"
    user_account {
      keys = [
        var.ssh_key,
      ]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.hosts["server25"].mac
    model       = "virtio"
    vlan_id     = var.hosts["server25"].vlan
  }

  lifecycle {
    ignore_changes = [
      operating_system,
      initialization,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "server" {
  acpi          = true
  bios          = "seabios"
  description   = "Managed by Terraform."
  name          = "server-old"
  node_name     = "proxmox"
  protection    = true
  scsi_hardware = "virtio-scsi-pci"
  started       = true
  tablet_device = true
  tags = [
    "terraform",
  ]
  template = false
  vm_id    = 200

  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  cpu {
    cores      = 2
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 4
    type       = "host"
    units      = 1024
  }

  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-zfs"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = false
    path_in_datastore = "vm-200-disk-0"
    replicate         = false
    size              = 200
    ssd               = false
  }

  initialization {
    datastore_id = "local-zfs"
    user_account {
      keys = [
        var.ssh_key,
      ]
    }
  }

  memory {
    dedicated = 8192
    floating  = 0
    shared    = 0
  }

  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = false
    mac_address  = var.hosts["server"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = var.hosts["server"].vlan
  }

  vga {
    memory = 16
    type   = "qxl"
  }

  lifecycle {
    ignore_changes = [
      operating_system,
      initialization,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  acpi          = true
  bios          = "ovmf"
  description   = "Managed by Terraform."
  machine       = "q35"
  name          = "homeassistant"
  node_name     = "proxmox"
  protection    = true
  scsi_hardware = "virtio-scsi-pci"
  started       = true
  tablet_device = true
  tags = [
    "terraform",
  ]
  template = false
  vm_id    = 201

  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  cpu {
    cores      = 1
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 2
    type       = "host"
    units      = 1024
  }

  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-zfs"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = false
    path_in_datastore = "vm-201-disk-1"
    replicate         = false
    size              = 64
    ssd               = false
  }

  memory {
    dedicated      = 4096
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }

  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = false
    mac_address  = var.hosts["home-assistant"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = var.hosts["home-assistant"].vlan
  }

  lifecycle {
    ignore_changes = [
      efi_disk,
      operating_system,
      initialization,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "ansible" {
  acpi          = true
  bios          = "seabios"
  description   = "Managed by Terraform."
  name          = "ansible"
  node_name     = "proxmox"
  protection    = true
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags = [
    "terraform",
  ]
  template = false
  vm_id    = 204

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
  }

  cpu {
    cores      = 1
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 4
    type       = "x86-64-v2-AES"
    units      = 1024
  }

  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-zfs"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = false
    path_in_datastore = "vm-204-disk-0"
    replicate         = false
    size              = 64
    ssd               = false
  }

  memory {
    dedicated      = 6144
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }

  network_device {
    bridge       = "vmbr0"
    disconnected = false
    enabled      = true
    firewall     = false
    mac_address  = var.hosts["ansible"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = var.hosts["ansible"].vlan
  }

  lifecycle {
    ignore_changes = [
      operating_system,
      initialization,
    ]
  }
}
