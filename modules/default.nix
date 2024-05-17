{ config, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./services/upnp.nix
  ];

  nixpkgs.overlays = [ (final: prev: {
    qemu_kvm = prev.qemu_test;
  }) ];

  boot.initrd.systemd.enable = false;

  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  services.logind.lidSwitch = "ignore";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
