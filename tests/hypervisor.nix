{ pkgs, self }: let
  inherit (pkgs) lib;
  sshKeys = import (pkgs.path + "/nixos/tests/ssh-keys.nix") pkgs;
  testSystem = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit pkgs lib;
    system = null;
    modules = [
      {
        nixpkgs.hostPlatform = pkgs.hostPlatform;
        system.stateVersion = lib.versions.majorMinor lib.version;
      }
      {
        services.openssh.enable = true;
        users.users.root.openssh.authorizedKeys.keys = [ sshKeys.snakeOilPublicKey ];
      }
      {
        # Speeds up the runLinuxInVM invocation in make-disk-image
        nixpkgs.overlays = [(self: super: {
          qemu_kvm = super.qemu_test;
        })];
      }
      ({ pkgs, modulesPath, ... }: {
        imports = [
          (modulesPath + "/profiles/minimal.nix")
          (modulesPath + "/profiles/headless.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
        ];
        boot.kernelModules = [
          "tpm_tis"
        ];
        boot.loader.grub.enable = false;
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = false;
        boot.loader.timeout = 0;
        boot.kernelParams = [ "console=ttyS0" ];
        fileSystems = {
          "/boot" = {
            device = "/dev/vda1";
            fsType = "vfat";
          };
          "/" = {
            device = "/dev/vda2";
            fsType = "ext4";
          };
        };
      })
    ];
  };
  diskImage = import (pkgs.path + "/nixos/lib/make-disk-image.nix") {
    inherit (testSystem) config lib pkgs;
    label = "nixos";
    format = "qcow2";
    partitionTableType = "efi";
    installBootLoader = true;
  };
  mutableImage = "/tmp/linked-image.qcow2";
in { inherit diskImage; test = (import ./lib.nix) {

  name = "hypervisor";

  nodes.hypervisor = { config, ... }: {
    imports = [
      ../modules/virtualisation/vm-guests.nix
    ];

    virtualisation.vm-guests.guests = [{
      name = "test";
      memorySize = 512;
      qemuOptions = [
        "-nic user,hostfwd=tcp:127.0.0.1:2222-:22"
        "-drive if=virtio,format=qcow2,file=/mnt${mutableImage}"
      ];
    }];

    # Share the mutable image
    virtualisation.sharedDirectories.tmp = {
      source = "/tmp";
      target = "/mnt/tmp";
    };
  };

  testScript = ''
    import subprocess

    subprocess.check_call(
        [
            "qemu-img",
            "create",
            "-f",
            "qcow2",
            "-F",
            "qcow2",
            "-b",
            "${diskImage}/nixos.qcow2",
            "${mutableImage}",
        ]
    )

    start_all()
    hypervisor.wait_for_unit("multi-user.target")
    hypervisor.wait_for_unit("vm-guest@test.service")

    hypervisor.wait_for_open_port(2222)
    hypervisor.succeed("cat ${sshKeys.snakeOilPrivateKey} > privkey.snakeoil")
    hypervisor.succeed("chmod 600 privkey.snakeoil")
    hypervisor.succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i privkey.snakeoil -p 2222 root@127.0.0.1 true", timeout=30)

    hypervisor.succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i privkey.snakeoil -p 2222 root@127.0.0.1 \"echo -n secret | systemd-creds encrypt -p --name=test --with-key=tpm2 - - > /dev/console\"", timeout=30)
  '';

} { inherit pkgs self; }; }
