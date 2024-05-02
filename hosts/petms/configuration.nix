{ config, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "petms";
  networking.domain = "opcc.tk";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.ports = [ 2273 ];

  services.upnpc.enable = true;

  time.timeZone = "America/Toronto";

  boot.loader.systemd-boot.enable = true;

  age.secrets.rclone.file = ../../secrets/rclone.age;
  age.secrets.backup-password.file = ../../secrets/backup-password.age;

  # services.restic.backups.main = {
  #   rcloneConfigFile = config.age.secrets.rclone.path;
  #   repository = "rclone:onedrive:backups/petms";
  #   initialize = true;
  #   paths = [
  #     "/home"
  #     "/var"
  #   ];
  #   passwordFile = config.age.secrets.backup-password.path;
  #   timerConfig = {
  #     OnCalendar = "00:05";
  #     RandomizedDelaySec = "2h";
  #   };
  #   rcloneOptions = {
  #     log-level = "debug";
  #   };
  # };

  boot.enableContainers = true;

  containers.vault = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      users.users.petms = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAi/FBbtRWsSbEX5iyqtzFXs5qgDi3DANUkwromz9m85 root@peter-pc"
        ];
      };
      services.openssh.enable = true;
      services.openssh.ports = [ 2272 ];
      services.openssh.extraConfig = ''
        PermitTTY no
        PermitTunnel no
        AllowAgentForwarding no 
        AllowTcpForwarding no
        X11Forwarding no
        ForceCommand internal-sftp 
      '';
      system.stateVersion = "24.05";
    };
  };

  containers.dev = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      services.openssh.enable = true;
      services.openssh.ports = [ 2274 ];
      users.users.petms = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
        ];
      };
      system.stateVersion = "24.05";
    };
  };

  containers.router = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      services.i2pd = {
        enable = true;
        upnp.enable = true;
      };
      system.stateVersion = "24.05";
    };
    extraVeths."int0" = {
      hostBridge = "ibr0";
      localAddress = "10.102.1.1";
    };
  };

  # containers.torrent = {
  #   autoStart = true;
  #   privateNetwork = true;
  #   config = { config, lib, pkgs, ... }: {
  #     imports = [ ../../modules/services/qbittorrent.nix ];
  #     services.qbittorrent = {
  #       package = pkgs.qbittorrent-nox;
  #       webuiPort = 8080;
  #     };
  #     system.stateVersion = "24.05";
  #   };
  #   extraVeths."int1" = {
  #     hostBridge = "ibr0";
  #     localAddress = "10.102.1.2";
  #   };
  # };

  networking.bridges."ibr0".interfaces = [];

  networking.firewall.allowedTCPPorts = [ 2272 2273 2274 ];

  system.stateVersion = "24.05";

}
