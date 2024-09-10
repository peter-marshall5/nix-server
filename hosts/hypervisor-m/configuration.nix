{ config, pkgs, lib, modulesPath, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ../../modules/virtualisation/vm-guests.nix
    ../../modules/profiles/base.nix
  ];

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-8" ];

  networking.hostName = "hypervisor-m";

  virtualisation.vm-guests.guests = [
    {
      name = "cheesecraft";
      disk = "/dev/vghm/cheesecraft";
      memorySize = 2048;
      macAddress = "B7:41:39:68:09:2B";
    }
    {
      name = "petms";
      disk = "/dev/vghm/petms";
      memorySize = 1024;
      macAddress = "EE:5E:65:D4:53:D4";
    }
    {
      name = "joms";
      disk = "/dev/vghm/joms";
      memorySize = 1024;
      macAddress = "CF:57:FD:74:FC:06";
    }
  ];

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
  };

  users.allowNoPasswordLogin = true;

  services.openssh.enable = true;

  time.timeZone = "America/Toronto";

  boot.blacklistedKernelModules = [
    "amdgpu"
    "radeon"
  ];

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  boot.initrd.kernelModules = [
    "usb-storage"
    "uas"
    "ahci"
  ];

  # boot.initrd.systemd.enable = lib.mkForce false;

  boot.loader.systemd-boot.configurationLimit = 1;

  fileSystems = {
    "/" = {
      fsType = "btrfs";
      device = "PARTUUID=3e4e6f59-85de-432f-941a-0963ea0a2105";
    };
    "/boot" = {
      fsType = "vfat";
      device = "UUID=DDFE-46F7";
    };
  };

  systemd.targets."tpm2".enable = false;

  systemd.network.netdevs."10-br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-br0-eth" = {
    matchConfig.Name = "en*";
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.networks."11-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCP = "yes";
    };
  };

  system.stateVersion = "24.05";

}
