{ config, lib, pkgs, ... }: let
  cfg = config.virtualisation.vm-guests;
in {

  options.virtualisation.vm-guests = {
    enable = lib.mkEnableOption "VM guest support" // {
      default = cfg.guests != [];
    };
    guests = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          disk = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          memorySize = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1024;
          };
          cores = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1;
          };
          useEFIBoot = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          useTpm = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          macAddress = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          qemuOptions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
        };
      });
      default = [];
    };
    efi = {
      OVMF = lib.mkOption {
        type = lib.types.package;
        default = pkgs.OVMF;
      };
      firmware = lib.mkOption {
        type = lib.types.path;
        default = cfg.efi.OVMF.firmware;
      };
      variables = lib.mkOption {
        type = lib.types.path;
        default = cfg.efi.OVMF.variables;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services = (lib.listToAttrs (map
      (guest: lib.nameValuePair "vm-guest@${guest.name}" (let
        qemuOptions = lib.optionals guest.useEFIBoot [
          "-drive if=pflash,format=raw,unit=0,readonly=on,file=${cfg.efi.firmware}"
          "-drive if=pflash,format=raw,unit=1,readonly=on,file=${cfg.efi.variables}"
        ] ++ lib.optionals guest.useTpm [
          "-chardev socket,id=chrtpm,path=${tpmDir}/socket"
          "-tpmdev emulator,id=tpm0,chardev=chrtpm"
          "-device tpm-tis,tpmdev=tpm0"
        ] ++ lib.optional (guest.disk != null) "-drive if=virtio,format=raw,file=${guest.disk}"
        ++ lib.optionals (guest.macAddress != null) [
          "-netdev bridge,id=net0,br=br0"
          "-device virtio-net-pci,romfile=,netdev=net0,mac=${guest.macAddress}"
        ] ++ guest.qemuOptions;
        tpmDir = "/var/lib/vm-guests/${guest.name}/swtpm";
      in {
        script = ''
          ${lib.optionalString guest.useTpm ''
            mkdir -p "${tpmDir}"
            ${pkgs.swtpm}/bin/swtpm \
              socket \
              --tpmstate dir="${tpmDir}" \
              --ctrl type=unixio,path="${tpmDir}"/socket,terminate \
              --pid file="${tpmDir}"/pid --daemon \
              --tpm2 \
              --log file="${tpmDir}"/stdout,level=6
          ''}

          ${pkgs.qemu_test}/bin/qemu-kvm \
            -nographic \
            -m ${toString guest.memorySize} \
            -smp ${toString guest.cores} \
            ${lib.concatStringsSep " \\\n  " qemuOptions}
        '';
        wantedBy = [ "multi-user.target" ];
        unitConfig.ConditionPathExists = lib.mkIf (guest.disk != null) [ "${guest.disk}" ];
      }))
      cfg.guests));
  };

}
