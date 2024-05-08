{ config, ... }: {

  imports = [
    ./hardware-configuration.nix
    ./mc.nix
    ./vault.nix
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

  boot.enableContainers = true;

  containers.petms-dev = {
    autoStart = true;
    privateNetwork = true;
    config = import ../dev/configuration.nix;
  };

  networking.nat.enable = true;
  networking.nat.externalInterface = "enp2s0f1";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 25565 ];
  };

  age.secrets.wg.file = ../../secrets/wg.age;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 25565;
    privateKeyFile = config.age.secrets.wg.path;
    peers = [
      { # Phone
        publicKey = "qnXuHWI3HUpLw+fxbVkvUiY0Enz7v36EdHAyrH45U0A=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  system.stateVersion = "24.05";

}
