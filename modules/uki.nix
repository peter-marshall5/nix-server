{ config, pkgs, lib, modulesPath, ... }: let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in {

  # include rootfs in UKI

  # imports = [
  #   (modulesPath + "/installer/netboot/netboot.nix")
  # ];

  # netboot.squashfsCompression = "zstd -Xcompression-level 12 -b 1M";

  # boot.uki.settings = {
  #   UKI.Initrd = "${config.system.build.netbootRamdisk}/initrd";
  # };

  boot.uki.tries = 3;

  system.build.espContents = pkgs.linkFarm "esp-contents" [
    {
      name = "EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI";
      path = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
    }
    {
      name = "EFI/Linux/${config.system.boot.loader.ukiFile}";
      path = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
    }
  ];

}
