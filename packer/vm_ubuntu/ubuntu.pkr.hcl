# Ubuntu Server Noble Numbat
# ---
# Packer Template to create an Ubuntu Server 24.04 LTS (Noble Numbat) on Proxmox

# Resource Definiation for the VM Template

packer {
  required_plugins {
    name = {
      version = "~> 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-server-noble-numbat" {

    # Proxmox Connection Settings
    # Uses ENV vars:
    # - PROXMOX_USERNAME
    # - PROXMOX_TOKEN
    proxmox_url = var.proxmox_api_url

    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # VM General Settings
    node = var.proxmox_node
    vm_id = "999"
    vm_name = "ubuntu"
    template_description = "PKR: Noble Numbat"

    # VM OS Settings
    boot_iso {
      type = "scsi"
      # (Option 1) Local ISO File
      # iso_file = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
      # (Option 2) Download ISO
      iso_url = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
      unmount = true
      iso_checksum = "sha512:888940b5b7e76c6312f77b9228b49ab328aee9f56426ffdcce59a57e8d18553067b9fe5482ff7abc31768d23d091c8e1edd992f2b993d4d80f47afe8213ace80"
      iso_storage_pool = var.proxmox_iso_storage_pool
    }

    template_name        = "ubuntu2404"

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "32G"
        format = "raw"
        storage_pool = var.proxmox_storage_pool
        type = "virtio"
    }

    # VM CPU Settings
    cores = 2

    # VM Memory Settings
    memory = 2048

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = var.proxmox_bridge
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = var.proxmox_storage_pool

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    # http_directory = "./http"
    http_content = {
      "/user-data" = templatefile("${path.root}/http/user-data.tpl", {
      username     = var.username
      ssh_key      = var.ssh_key
    })
      "/meta-data" = file("${path.root}/http/meta-data")
  }
    #http_bind_address = "10.1.149.166"
    # (Optional) Bind IP Address and Port
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = var.username

    # (Option 1) Add your Password here (if the user is ubuntu it will have login by password disabled by default)
    # ssh_password = var.ssh_password
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_ed25519"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-noble-numbat"
    sources = ["proxmox-iso.ubuntu-server-noble-numbat"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

}
