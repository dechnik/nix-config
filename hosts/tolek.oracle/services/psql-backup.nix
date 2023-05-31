{
  services.postgresqlBackup = {
    enable = true;

    databases = [ "matrix-synapse" ];
  };
}
