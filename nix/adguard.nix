{ config, modulesPath, pkgs, ... }:

{
  system.stateVersion = "24.11";

  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  networking.hostName = "adguard";

  services.resolved.enable = false;
  services.dnsmasq.enable = false;

  # Enable AdGuard Home
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    settings = assert pkgs.adguardhome.schema_version == 28; {
      dns = {
        bootstrap_dns = [ "tls://1.1.1.1" "tls://1.0.0.1"];
        upstream_dns = [ "tls://1.1.1.1" "tls://1.0.0.1" ];
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
      };

      filtering.rewrites = [
          {
            domain = "*.romanpeters.nl";
            answer = "10.10.20.10";
          }
      ];

      # Optional: Disable admin interface if not needed
      http = {
        address = "0.0.0.0:3000";
      };
    };
  };

  # Open firewall ports for DNS and admin interface
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  users.users.root = {
    hashedPassword = "$y$j9T$xZNFhv5fs4DEz84DjOTgb0$vNq5IMGqahDH5o.KGqHDqEId8BB1Jih0hN8hQrmN1O2";
  };

  nixpkgs.config.allowUnfree = true;

  systemd.services.dbus.enable = true;
  systemd.services.networkd.enable = true;
}
