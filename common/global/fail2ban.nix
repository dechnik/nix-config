{ lib, config, ... }:
{
  environment.persistence = {
    "/persist" = {
      directories = [ "/var/lib/fail2ban" ];
    };
  };
  services.fail2ban = {
    enable = config.networking.firewall.enable;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    bantime-increment = {
      enable = true;
      maxtime = "168h";
      factor = "4";
    };

    jails.DEFAULT = lib.mkDefault ''
      blocktype = DROP
      bantime = 2h
      findtime = 1h
    '';
  };
}
