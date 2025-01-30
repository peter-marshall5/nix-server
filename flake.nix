{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    nixvirt = {
      url = "github:petm5/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, agenix, nixvirt }: let
    hostPkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    # apps.x86_64-linux.pihole-net = let
    #   sys = nixpkgs.lib.nixosSystem {
    #     modules = [
    #       ./hosts/pihole-net/configuration.nix
    #     ];
    #   };
    #   build = sys.config.system.build;
    #   runner = hostPkgs.writers.writeBash "run-pixiecore" ''
    #     exec ${hostPkgs.pixiecore}/bin/pixiecore \
    #       boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
    #       --cmdline "init=${build.toplevel}/init loglevel=4" \
    #       --debug --dhcp-no-bind \
    #       --port 64172 --status-port 64172 "$@"
    #   '';
    # in {
    #   type = "app";
    #   program = "${runner}";
    # };
    # nixosConfigurations.hypervisor-m = nixpkgs.lib.nixosSystem {
    #   modules = [
    #     ./hosts/hypervisor-m/configuration.nix
    #   ];
    # };
    checks.x86_64-linux.hypervisor = import ./tests/hypervisor.nix {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      inherit self nixvirt;
    };
  };
}
