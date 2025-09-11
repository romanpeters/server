#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  network:
    version: 2
    ethernets:
      id0:
        match:
          name: "en*"
        dhcp4: true
  ssh:
    install-server: true
    allow-pw: false
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - git
    - qemu-guest-agent
    - sudo
    - zsh
  storage:
    layout:
      name: direct
    swap:
      size: 0
  # user-data is processed by cloud-init after the OS is installed
  user-data:
    package_upgrade: true
    timezone: Europe/Amsterdam
    users:
      - name: ${username}
        passwd: ${ssh_password_hashed}
        groups: [adm, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/zsh
        ssh_authorized_keys:
          - ${ssh_key}
