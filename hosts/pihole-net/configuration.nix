{ config, pkgs, lib, modulesPath, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    (modulesPath + "/profiles/image-based-appliance.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/installer/netboot/netboot.nix")
    (modulesPath + "/profiles/perlless.nix")
  ];

  netboot.squashfsCompression = "zstd -Xcompression-level 12";

  virtualisation.oci-containers.containers.pihole = {
    image = "docker.io/pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "67:67/udp"
      "80:80/tcp"
    ];
    environment = {
      TZ = "${config.time.timeZone}";
      WEBPASSWORD = "pihole";
      PIHOLE_DNS_ = "8.8.8.8;8.8.4.4;1.1.1.1";
      DNSSEC = "true";
      QUERY_LOGGING	= "false";
    };
    volumes = [
      "etc-pihole:/etc/pihole"
      "etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    extraOptions = [ "--cap-add=CAP_NET_ADMIN" "--net=slirp4netns" "--dns=127.0.0.1" "--dns=1.1.1.1" ];
  };

  networking.firewall.enable = false;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
  };

  users.allowNoPasswordLogin = true;

  services.openssh.enable = true;

  # Conflicts with pihole
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  time.timeZone = "America/Toronto";

  boot.blacklistedKernelModules = [
    "amdgpu"
    "radeon"
  ];

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  system.stateVersion = "24.05";

}
