{
  containers.mc = {
    autoStart = true;
    config = { config, lib, pkgs, ... }: {
      virtualisation.oci-containers.containers = {
        cheesecraft = {
          image = "itzg/minecraft-bedrock-server:latest";
          volumes = ["cheesecraft:/data"];
          environment = {
            EULA = "true";
            SERVER_NAME = "CheeseCraft - Survival";
            LEVEL_NAME = "CheeseCraft Season 5";
            SERVER_PORT = "19132";
            SERVER_PORT_V6 = "19133";
          };
          extraOptions = [
            "--memory=1024m"
            "--network=host"
            "--cgroups=disabled"
            "-it"
          ];
        };
        # build-battle = {
        #   image = "itzg/minecraft-bedrock-server:latest";
        #   volumes = ["/var/lib/mcbe/build-battle:/data"];
        #   environment = {
        #     EULA = "true";
        #     SERVER_NAME = "Build Battle";
        #     LEVEL_NAME = "Build Battle";
        #     SERVER_PORT = 19134;
        #     SERVER_PORT_V6 = 19135;
        #   };
        #   extraOptions = [
        #     "--memory=1024m"
        #     "--network=host"
        #     "--cgroups=disabled"
        #     "-it"
        #   ];
        # };
      };
      system.stateVersion = "24.05";
    };
    extraFlags = map (syscall: "--system-call-filter=${syscall}") [
      "@privileged"
      "@keyring"
    ];
  };
}  
