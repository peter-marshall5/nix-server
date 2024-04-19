{ modulesPath, ... }: {

  boot.initrd.availableKernelModules = [ "usb_storage" "uas" "ahci" "xhci_pci" "ehci_pci" "sd_mod" "rtsx_pci_sdmmc" ];

  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems = {
    "/" = {
      device = "UUID=e868fc43-6591-420d-be5b-66574052ae82";
      fsType = "bcachefs";
      options = [ "compression=zstd" ];
    };
    "/boot" = {
      label = "ESP";
      fsType = "vfat";
    };
  };

}
