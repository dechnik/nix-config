{
  imports = [
    ./gh-runner.nix
    ./attic.nix
    ./traefik.nix
    ./binary-cache.nix
    ./dhcp.nix
    # ./dnsmasq.nix
    ./hydra
    ./files.nix
    # ./cgit
    ./psql-backup.nix
    ./gitea
    ./gitea/runner.nix
    # ./uwsgi.nix
    # ./searx.nix
    # ./website.nix
    ./restic-server.nix
    ./monitoring.nix
    ./loki.nix
    ./grafana.nix
    ./headscale.nix
    ./tailscale.nix
    ./restic.nix
    # ./golink.nix
    ./wireguard.nix
    ./jellyfin.nix
    # ./gitness.nix
    # ./grafana-matrix-forwarder.nix
    # ./wormhole.nix
  ];

  environment.persistence."/persist".directories = [
    "/var/lib/private"
  ];

}
