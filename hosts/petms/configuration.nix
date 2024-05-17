{ config, ... }: {

  imports = [
    ./hardware-configuration.nix
    ./mc.nix
  ];

  networking.hostName = "cheesecake";
  networking.domain = "opcc.tk";

  security.sudo.wheelNeedsPassword = false;

  users.users = import ./users.nix;

  services.openssh.enable = true;
  services.openssh.openFirewall = false;

  services.upnpc.enable = true;

  time.timeZone = "America/Toronto";

  boot.loader.systemd-boot.enable = true;

  boot.enableContainers = true;

  networking.nat.enable = true;
  networking.nat.externalInterface = "enp2s0f1";
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall.allowedUDPPorts = [ 25565 ];
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 22 ];

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

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;

  programs.bash.promptInit = ''
    PS1="\n\[\033[1;32m\]\u@\h:\w\[\033[36m\]\$\[\033[0m\] "
  '';

  system.stateVersion = "24.05";

}
