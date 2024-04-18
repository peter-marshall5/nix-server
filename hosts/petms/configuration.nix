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

  services.openssh.enable = true;
  services.openssh.ports = [ 2273 ];

  services.upnpc.enable = true;

  time.timeZone = "America/Toronto";

  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [ "console=ttyS0" ];

  boot.enableContainers = true;

  containers.dev = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      users.users.petms = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      system.stateVersion = "24.05";
    };
  };

  containers.backup = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      services.borgbackup.repos."petms" = {
        quota = "256G";
        authorizedKeysAppendOnly = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
        ];
      };
      system.stateVersion = "24.05";
    };
  };

  containers.router = {
    autoStart = true;
    privateNetwork = true;
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

  containers.torrent = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "ibr0";
    localAddress = "10.102.1.2";
    config = { config, lib, pkgs, ... }: {
      imports = [ ../../modules/services/qbittorrent.nix ];
      services.qbittorrent = {
        package = pkgs.qbittorrent-nox;
        webuiPort = 8080;
      };
      system.stateVersion = "24.05";
    };
  };

  networking.bridges."ibr0".interfaces = [];

  system.stateVersion = "24.05";

}
