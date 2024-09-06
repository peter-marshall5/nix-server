{ modulesPath, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems = {
    "/efi" = {
      device = "/dev/vda1";
      fsType = "vfat";
      neededForBoot = true;
      options = [ "umask=0777" ];
    };
    "/var" = {
      device = "/dev/vda2";
      fsType = "bcachefs";
      options = [ "compression=zstd" ];
    };
  };

}
