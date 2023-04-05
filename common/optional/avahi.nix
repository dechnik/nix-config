{ pkgs
, lib
, config
, ...
}:
{
  services.avahi = {
    enable = lib.mkDefault true;
    openFirewall = true;

    hostName = "${config.networking.hostName}";

    nssmdns = true;
    allowPointToPoint = true;

    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };

    extraServiceFiles = {
      ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    };
  };
}
