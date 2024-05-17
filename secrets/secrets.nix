let
  hostKeys = import ../ssh/host-keys.nix;
  trustedKeys = import ../ssh/trusted-keys.nix;
  keysFor = hosts: (map (host: hostKeys.${host}) hosts) ++ trustedKeys;
in
{
  "rclone.age".publicKeys = keysFor ["petms"];
  "backup-password.age".publicKeys = keysFor ["petms"];
  "wg.age".publicKeys = keysFor ["petms"];
  "06cafcb6-9210-469b-bfff-42397ef69ce3.json.age".publicKeys = keysFor ["petms"];
}
