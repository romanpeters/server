{ config, modulesPath, pkgs, ... }:

{
  system.stateVersion = "24.11";

  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  networking.hostName = "s3";

  services.seaweedfs = {
    enable = true;

    master = {
      enable = true;
      args = [
        "-ip=0.0.0.0"
        "-mdir=/var/lib/seaweedfs/master"
      ];
    };

    volume = {
      enable = true;
      args = [
        "-ip=0.0.0.0"
        "-dir=/var/lib/seaweedfs/volume"
        "-max=10"
        "-mserver=127.0.0.1:9333"
      ];
    };

    filer = {
      enable = true;
      args = [
        "-ip=127.0.0.1"
        "-master=127.0.0.1:9333"
      ];
    };

    s3 = {
      enable = true;
      args = [
        "-port=8333"
        "-filer=127.0.0.1:8888"
        "-ip=0.0.0.0"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 9333 8080 8888 8333 ];

  systemd.services.seaweedfs-master.wantedBy = [ "multi-user.target" ];
  systemd.services.seaweedfs-volume.wantedBy = [ "multi-user.target" ];
  systemd.services.seaweedfs-filer.wantedBy = [ "multi-user.target" ];
  systemd.services.seaweedfs-s3.wantedBy = [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [ seaweedfs ];
}
