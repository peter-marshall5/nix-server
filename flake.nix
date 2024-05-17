{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations.cheesecake = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./hosts/cheesecake/configuration.nix
        agenix.nixosModules.default
      ];
    };
  };
}
