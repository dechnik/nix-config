{
  services.postgresqlBackup = {
    enable = true;

    databases = [ "hydra" ];
  };
}
