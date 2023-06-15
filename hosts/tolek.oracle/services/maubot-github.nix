{ inputs, config, ... }:
{
  imports = [
    inputs.maubot.nixosModules.github
  ];

  sops.secrets = {
    maubot-github-config = {
      owner = "maubot-github";
      group = "maubot-github";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/maubot-github"
    ];
  };

  services.maubot-github = {
    enable = true;
    serverHostname = "127.0.0.1";
    serverPort = 8821;
    userName = "@github:dechnik.net";
    homeServer = "https://matrix.dechnik.net";
    publicUrl = "https://matrix.dechnik.net";
    dataDir = "/var/lib/maubot-github";
    secretYAML = config.sops.secrets.maubot-github-config.path;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.maubot-github = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:8821"; }];
    };

    routers.maubot-github = {
      rule = "(Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix/maubot/plugin/github`)))";
      service = "maubot-github";
      priority = 999;
      entryPoints = [ "web" ];
    };
  };
}
