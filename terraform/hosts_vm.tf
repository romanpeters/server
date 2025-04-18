resource "proxmox_virtual_environment_vm" "server" {
  acpi          = true
  bios          = "seabios"
  description   = "Managed by Terraform."
  name          = "server"
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
    size              = 160
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
    mac_address  = local.hosts_map["server"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = local.hosts_map["server"].vlan
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
    mac_address  = local.hosts_map["home-assistant"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = local.hosts_map["home-assistant"].vlan
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
    mac_address  = local.hosts_map["ansible"].mac
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = local.hosts_map["ansible"].vlan
  }

  lifecycle {
    ignore_changes = [
      operating_system,
      initialization,
    ]
  }
}
