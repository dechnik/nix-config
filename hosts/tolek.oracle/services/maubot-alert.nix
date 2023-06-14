{ inputs, config, ... }:
{
  imports = [
    inputs.maubot.nixosModules.alert
  ];

  sops.secrets = {
    maubot-alert-config = {
      owner = "maubot-alert";
      group = "maubot-alert";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/maubot-alert"
    ];
  };

  services.maubot-alert = {
    enable = true;
    serverHostname = "127.0.0.1";
    serverPort = 8820;
    userName = "@alert:dechnik.net";
    homeServer = "https://matrix.dechnik.net";
    publicUrl = "https://matrix.dechnik.net";
    dataDir = "/var/lib/maubot-alert";
    secretYAML = config.sops.secrets.maubot-config.path;
  };
}
