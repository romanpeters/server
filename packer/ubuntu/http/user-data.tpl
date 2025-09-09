#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
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
  ansible:
    install_method: pip
    pull:
      - url: "https://github.com/romanpeters/server.git"
        playbook_names: [ansible/roles/configure_hosts.yml]
        extra_vars:
	  role_to_run: base
	  username: ${username}
	  email: mail@romanpeters.nl
