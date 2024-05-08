{
  containers.vault = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      users.users.petms = {
        isNormalUser = true;
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
  networking.firewall.allowedTCPPorts = [ 2272 ];
}
