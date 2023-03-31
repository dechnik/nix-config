{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [ docker-compose ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
