{ pkgs, self, nixvirt }: let
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
        services.openssh.ports = [ 2222 ];
        users.users.root.openssh.authorizedKeys.keys = [ sshKeys.snakeOilPublicKey ];
        networking.useDHCP = true;
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
in (import ./lib.nix) {

  name = "hypervisor";

  nodes.hypervisor = { config, ... }: {
    imports = [
      ../modules/virtualisation/vm-guests.nix
      nixvirt.nixosModules.default
    ];

    virtualisation.libvirt.enable = true;
    virtualisation.libvirt.swtpm.enable = true;
    virtualisation.libvirt.connections."qemu:///system" =
      {
        domains =
          [
            {
              definition = let base = nixvirt.lib.domain.templates.linux
                {
                  name = "guest";
                  uuid = "cbac8f2d-5de2-4f76-a9cd-aaa2140cc5ed";
                  memory = { count = 512; unit = "MiB"; };
                  network = "default";
                  storage_vol = "/mnt${mutableImage}";
                  virtio_video = false;
                  virtio_net = false;
                };
              in nixvirt.lib.domain.writeXML (base // {
                  devices = base.devices // {
                    serial =
                      {
                        type = "pty";
                        target =
                          {
                            type = "isa-serial";
                            port = 0;
                          };
                      };
                      tpm =
                        {
                          model = "tpm-crb";
                          backend =
                            {
                              type = "emulator";
                              version = "2.0";
                            };
                        };
                  };
                  os = base.os // {
                    loader =
                      {
                        readonly = true;
                        type = "pflash";
                        path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
                        stateless = true;
                      };
                  };
                });
              active = true;
            }
          ];
        networks =
          [
            {
              definition = nixvirt.lib.network.writeXML
                {
                  name = "default";
                  uuid = "3e126f34-81f9-43f9-a7aa-d13725706d3b";
                  forward =
                    {
                      mode = "nat";
                      nat =
                        {
                          port =
                            {
                              start = 1024;
                              end = 65535;
                            };
                        };
                    };
                  bridge = { name = "virbr0"; };
                  ip =
                    {
                      address = "192.168.71.1";
                      netmask = "255.255.255.0";
                      dhcp =
                        {
                          range =
                            {
                              start = "192.168.71.2";
                              end = "192.168.71.2";
                            };
                        };
                    };
                };
              active = true;
            }
          ];
      };

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
    hypervisor.wait_for_unit("libvirtd.service")

    hypervisor.wait_for_open_port(2222, "192.168.71.2")
    hypervisor.succeed("cat ${sshKeys.snakeOilPrivateKey} > privkey.snakeoil")
    hypervisor.succeed("chmod 600 privkey.snakeoil")
    hypervisor.succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i privkey.snakeoil -p 2222 root@192.168.71.2 true", timeout=30)

    hypervisor.succeed("ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i privkey.snakeoil -p 2222 root@192.168.71.2 \"echo -n secret | systemd-creds encrypt -p --name=test --with-key=tpm2 - - > /dev/console\"", timeout=30)
  '';

} { inherit pkgs self; }
