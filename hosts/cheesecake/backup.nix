{

  age.secrets.rclone.file = ../../secrets/rclone.age;
  age.secrets.backup-password.file = ../../secrets/backup-password.age;

  services.restic.backups.main = {
    rcloneConfigFile = config.age.secrets.rclone.path;
    repository = "rclone:onedrive:backups/petms";
    initialize = true;
    paths = [
      "/home"
      "/var"
    ];
    passwordFile = config.age.secrets.backup-password.path;
    timerConfig = {
      OnCalendar = "00:05";
      RandomizedDelaySec = "2h";
    };
    rcloneOptions = {
      log-level = "debug";
    };
  };

}
