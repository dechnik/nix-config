{
  imports = [
    ./binary-cache.nix
    ./dhcp.nix
    ./hydra
    ./files.nix
    # ./cgit
    ./psql-backup.nix
    ./gitea
    ./uwsgi.nix
    ./searx.nix
    ./website.nix
    ./restic-server.nix
    ./monitoring.nix
    ./loki.nix
    ./grafana.nix
    ./headscale.nix
    ./tailscale.nix
    ./restic.nix
    # ./golink.nix
    ./wireguard.nix
    ./nginx-jellyfin.nix
  ];

  environment.persistence."/persist".directories = [
    "/var/lib/private"
  ];

}
