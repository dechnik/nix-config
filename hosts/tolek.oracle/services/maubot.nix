{ inputs, config, ... }:
{
  imports = [
    inputs.maubot.nixosModules.default
  ];

  sops.secrets = {
    maubot-config = {
      owner = config.systemd.services.maubot.serviceConfig.User;
      group = config.systemd.services.maubot.serviceConfig.Group;
      sopsFile = ../secrets.yaml;
    };
  };

  services.maubot = {
    enable = true;
    serverHostname = "127.0.0.1";
    serverPort = 29316;
    publicUrl = "https://matrix.dechnik.net";
    dataDir = "/var/lib/maubot";
    secretYAML = config.sops.secrets.maubot-config.path;
  };
}
