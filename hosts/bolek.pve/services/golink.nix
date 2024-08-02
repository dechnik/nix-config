{ config, ... }:
{
  sops.secrets.golink-tskey = {
    sopsFile = ../secrets.yaml;
    owner = config.services.golink.user;
  };

  services.golink = {
    enable = true;
    tailscaleAuthKeyFile = config.sops.secrets.golink-tskey.path;
    verbose = true;
  };

  environment.persistence."/persist".directories = [ "/var/lib/golink" ];
}
