{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, nixpkgs, deploy-rs, agenix }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./hosts/petms/configuration.nix
        agenix.nixosModules.default
      ];
    };

    deploy.nodes.petms = {
      hostname = "petms";
      remoteBuild = false;
      profiles.system = {
        sshUser = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.petms;
      };
    };
  };
}
