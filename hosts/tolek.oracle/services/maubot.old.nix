{ inputs, config, ... }:
{
  disabledModules = [ "services/matrix/maubot.nix" ];
  imports = [ inputs.maubot.nixosModules.default ];

  sops.secrets = {
    maubot-config = {
      owner = "maubot";
      group = "maubot";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/maubot" ];
  };

  services.maubot = {
    enable = true;
    serverHostname = "127.0.0.1";
    serverPort = 29316;
    publicUrl = "https://matrix.dechnik.net";
    dataDir = "/var/lib/maubot";
    secretYAML = config.sops.secrets.maubot-config.path;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.maubot = {
      loadBalancer.servers = [ { url = "http://127.0.0.1:29316"; } ];
    };

    routers.maubot = {
      rule = "(Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix/maubot`)))";
      service = "maubot";
      priority = 990;
      entryPoints = [ "web" ];
    };
  };
}
