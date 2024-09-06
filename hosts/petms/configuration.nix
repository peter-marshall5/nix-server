{ config, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    # ./vpn.nix
  ];

  users.users.petms = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
    extraGroups = [ "wheel" ];
  };

  users.allowNoPasswordLogin = true;

  networking.hostName = "petms";
  networking.domain = "opcc.tk";

  services.openssh.enable = true;
  services.openssh.hostKeys = [{
    path = "/efi/secrets/ssh_host_ed25519_key";
    type = "ed25519";
  }];

  security.doas.wheelNeedsPassword = false;

  boot.initrd = {
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
        ];
        ignoreEmptyHostKeys = true;
        extraConfig = ''
          HostKey /sysroot/efi/secrets/ssh_host_ed25519_key
        '';
      };
    };
    systemd = {
      enable = true;
      network.enable = true;
      users.root.shell = "/bin/systemd-tty-ask-password-agent";
      services.sshd.unitConfig.RequiresMountsFor = "/sysroot/efi";
      services.systemd-ask-password-console.enable = false;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "America/Toronto";

  system.stateVersion = "24.05";

}
