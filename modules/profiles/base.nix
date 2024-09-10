{ modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  networking.useNetworkd = true;

  boot.initrd.systemd.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  services.logind.lidSwitch = "ignore";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

}
