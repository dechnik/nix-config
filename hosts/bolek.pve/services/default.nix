{
  imports = [
    ./binary-cache.nix
    ./dhcp.nix
    ./hydra.nix
    ./files.nix
    # ./cgit
    # ./git-remote.nix
    ./uwsgi.nix
    # ./rss.nix
    ./searx.nix
    ./website.nix
    ./restic-server.nix
    ./monitoring.nix
    ./loki.nix
    ./grafana.nix
    ./headscale.nix
    ./tailscale.nix
    ./restic.nix
    ./wireguard.nix
    ./nginx-jellyfin.nix
  ];

  environment.persistence."/persist".directories = [
    "/var/lib/private"
  ];

}
