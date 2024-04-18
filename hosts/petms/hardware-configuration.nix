{ modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "btrfs";
    };
    "/boot" = {
      label = "ESP";
      fsType = "vfat";
    };
  };

}
