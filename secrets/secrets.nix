let
  hostKeys = import ../ssh/host-keys.nix;
  trustedKeys = import ../ssh/trusted-keys.nix;
  keysFor = hosts: (map (host: hostKeys.${host}) hosts) ++ trustedKeys;
in
{
  "rclone.age".publicKeys = keysFor ["petms"];
  "backup-password.age".publicKeys = keysFor ["petms"];
}
