{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = { self, nixpkgs, deploy-rs }: {
    nixosConfigurations.petms = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules
        ./hosts/petms/configuration.nix
      ];
    };

    deploy.nodes.petms = {
      hostname = "opcc.opcc.tk";
      remoteBuild = false;
      profiles.system = {
        sshUser = "admin";
        sshOpts = [ "-p" "2273" ];
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.petms;
      };
    };
  };
}
