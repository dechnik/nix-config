{ lib, pkgs, ... }: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
  environment.systemPackages = with pkgs; [ podman-compose ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/containers"
    ];
  };
}
