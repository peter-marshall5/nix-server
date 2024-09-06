{ config, lib, pkgs, ... }: {

  system.build.cmdline = pkgs.writeText "cmdline" "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}";

  system.build.vmBundle = pkgs.linkFarm "vm-bundle" [
    {
      name = "initrd.gz";
      path = "${config.system.build.bundleRamdisk}/initrd";
    }
    {
      name = "bzImage";
      path = "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";
    }
    {
      name = "cmdline";
      path = config.system.build.cmdline;
    }
  ];

}
