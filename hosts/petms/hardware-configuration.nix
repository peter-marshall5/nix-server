{ modulesPath, ... }: {

  boot.initrd.kernelModules = [ "usb_storage" "uas" "ahci" ];

  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/nixos1:/dev/disk/by-partlabel/nixos2";
      fsType = "bcachefs";
      options = [ "compression=zstd" ];
    };
    "/boot" = {
      label = "ESP";
      fsType = "vfat";
    };
  };

}
