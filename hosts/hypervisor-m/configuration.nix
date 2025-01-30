{ config, pkgs, lib, modulesPath, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ../../modules/profiles/base.nix
  ];

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-8" ];

  networking.hostName = "hypervisor-m";

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
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
    "raid1"
  ];

  boot.kernelModules = [
    "dm_thin_pool"
    "kvm_amd"
  ];

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    PROGRAM=echo
  '';

  fileSystems = {
    "/" = {
      fsType = "btrfs";
      device = "UUID=25e9f999-cd07-4665-98f5-9aec1da6e5c9";
      encrypted = {
        enable = true;
        label = "root";
        blkDev = "UUID=3adedd5c-8a8e-4d45-a1f0-ae7c10b115e2";
      };
    };
    "/boot" = {
      fsType = "vfat";
      device = "UUID=FFE8-23CF";
    };
  };

  system.stateVersion = "24.05";

}
