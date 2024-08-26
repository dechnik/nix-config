{
  services.postgresqlBackup = {
    enable = true;

    databases = [
      "git"
      "atuin"
    ];
  };
}
