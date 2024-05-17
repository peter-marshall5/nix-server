{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./hosts/petms/configuration.nix
        agenix.nixosModules.default
      ];
    };
  };
}
