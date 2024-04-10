{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./hosts/petms/configuration.nix
      ];
    };
  };
}
