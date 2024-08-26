{
  imports = [
    # ./nc.nix
    ./gitlab.nix
    ./atuin.nix
    ./tailscale.nix
    ./tailscale-headscale.nix
    ./wireguard.nix
    ./restic.nix
    ./lldap.nix
    ./authelia.nix
    ./traefik.nix
    # ./matrix-synapse.nix
    ./psql-backup.nix
    # ./matterbridge.nix
    # ./mjolnir.nix
    # ./weechat.nix
    # ./maubot.nix
    # ./maubot-alert.nix
    # ./maubot-github.nix
    # ./maubot-rss.nix
  ];
}
