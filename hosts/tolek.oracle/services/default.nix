{
  imports = [
    # ./nc.nix
    ./atuin.nix
    ./tailscale.nix
    ./wireguard.nix
    ./restic.nix
    ./lldap.nix
    ./authelia.nix
    ./traefik.nix
    ./matrix-synapse.nix
    ./psql-backup.nix
    # ./matterbridge.nix
    ./mjolnir.nix
    ./weechat.nix
    # ./maubot.nix
    # ./maubot-alert.nix
    # ./maubot-github.nix
    # ./maubot-rss.nix
  ];
}
