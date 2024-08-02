{ inputs, config, ... }:
{
  imports = [ inputs.maubot.nixosModules.rss ];

  sops.secrets = {
    maubot-rss-config = {
      owner = "maubot-rss";
      group = "maubot-rss";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/maubot-rss" ];
  };

  services.maubot-rss = {
    enable = true;
    serverHostname = "127.0.0.1";
    serverPort = 8823;
    userName = "@rss:dechnik.net";
    homeServer = "https://matrix.dechnik.net";
    publicUrl = "https://matrix.dechnik.net";
    dataDir = "/var/lib/maubot-rss";
    notificationTemplate = "New post in $feed_title: [$title]($link)";
    updateInterval = 60;
    adminUsers = [ "@lukasz:dechnik.net" ];
    secretYAML = config.sops.secrets.maubot-rss-config.path;
  };
  services.traefik.dynamicConfigOptions.http = {
    services.maubot-rss = {
      loadBalancer.servers = [ { url = "http://127.0.0.1:8823"; } ];
    };

    routers.maubot-rss = {
      rule = "(Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix/maubot/plugin/rss`)))";
      service = "maubot-rss";
      priority = 998;
      entryPoints = [ "web" ];
    };
  };
}
