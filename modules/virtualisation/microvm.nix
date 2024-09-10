{

  options.virtualisation.microvms

    ${qemu}/bin/qemu-kvm \
      -m "$mem" -smp "$cpus" \
      -cpu host,kvmclock \
      -M microvm,x-option-roms=off,pit=off,pic=off,rtc=on,acpi=off,isa-serial=off \
      -nographic -nodefaults -no-user-config \
      -bios ${pkgs.qboot}/bios.bin \
      -kernel "$kernel" -initrd "$initrd" -append "$(cat "$cmdline")" \
      -chardev stdio,id=virtiocon0 \
      -device virtio-serial-device \
      -device virtconsole,chardev=virtiocon0 \
      -drive id=disk0,file="$disk",format=raw,if=none \
      -device virtio-blk-device,drive=disk0 \
      -netdev tap,id=net0,ifname="$tapname",script=no,downscript=no \
      -device virtio-net-device,netdev=net0
  '';
