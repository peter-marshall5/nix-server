{

  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall.allowedUDPPorts = [ 25565 ];
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 22 ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 25565;
    privateKeyFile = "/var/secrets/wg.key";
    peers = import ./wg-peers.nix;
  };

  boot.kernelModules = [ "wireguard" ];

}
