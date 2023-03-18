{
  imports = [
    ./binary-cache.nix
    ./hydra.nix
    ./cgit
    ./git-remote.nix
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
    ./wireguard.nix
    ./nginx-jellyfin.nix
  ];
}
