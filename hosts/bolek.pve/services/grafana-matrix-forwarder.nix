{ inputs, config, ... }:
{
  imports = [ inputs.grafana-matrix-forwarder.nixosModules.default ];

  sops.secrets = {
    matrix-bot-auth = {
      owner = "gmf";
      group = "gmf";
      sopsFile = ../secrets.yaml;
    };
  };

  services.grafana-matrix-forwarder = {
    enable = true;
    openFirewall = true;
    serverHost = "127.0.0.1";
    serverPort = 6000;
    matrixAuthFile = config.sops.secrets.matrix-bot-auth.path;
  };
}
