{ config, pkgs, ... }: {

  services.openssh.authorizedKeysInHomedir = false;
  users.mutableUsers = false;

  boot.kernelModules = [ "virtio_pci" "virtio_mmio" "virtio_net" "virtio_blk" "virtio_balloon" "virtio_console" ];

  boot.kernelParams = [ "console=hvc0" "panic=1" "boot.panic_on_fail" "vga=normal" "nomodeset" "reboot=t" "systemd.journald.forward_to_console=1" ];

  systemd.enableEmergencyMode = false;
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

}
