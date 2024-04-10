{ config, modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./services/upnp.nix
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
