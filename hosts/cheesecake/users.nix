{

  admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
  };

  petms = {
    isNormalUser = true;
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjg1Y1b2YyhoC73I4is0/NRmVb3FeRmpLf2Yk8adrxq petms@peter-pc"
    ];
  };

  jomshall = {
    isNormalUser = true;
    linger = true;
  };

}
