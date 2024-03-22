{ lib, inputs, config, ... }:
{
  # disabledModules = [ "services/matrix/maubot.nix" ];
  # imports = [
  #   inputs.maubot.nixosModules.default
  # ];

  sops.secrets = {
    maubot-config = {
      owner = "maubot";
      group = "maubot";
      sopsFile = ../secrets.yaml;
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/maubot"
    ];
  };

  services.maubot = {
    enable = true;
    extraConfigFile = config.sops.secrets.maubot-config.path;
    dataDir = "/var/lib/maubot";
    settings = {
      server.port = 29316;
      server.hostname = "127.0.0.1";
      server.public_url = "https://matrix.dechnik.net";
      server.ui_base_path = "/_matrix/maubot";
      database = "sqlite:${config.services.maubot.dataDir}/maubot.db";
      plugin_databases.sqlite = "${config.services.maubot.dataDir}/plugins";
      plugin_databases.postgres = null;
    };
    # plugins = with config.services.maubot.package.plugins; [
    #   rss
    # ];
  };

  # services.maubot = {
  #   enable = true;
  #   serverHostname = "127.0.0.1";
  #   serverPort = 29316;
  #   publicUrl = "https://matrix.dechnik.net";
  #   dataDir = "/var/lib/maubot";
  #   secretYAML = config.sops.secrets.maubot-config.path;
  # };
  services.traefik.dynamicConfigOptions.http = {
    services.maubot = {
      loadBalancer.servers = [{ url = "http://127.0.0.1:29316"; }];
    };

    routers.maubot = {
      rule = "(Host(`matrix.dechnik.net`) && (PathPrefix(`/_matrix/maubot`)))";
      service = "maubot";
      priority = 990;
      entryPoints = [ "web" ];
    };
  };
}
