{ pkgs, config, lib, ... }:
let
  fetchKey = { url, sha256 ? lib.fakeSha256 }:
    builtins.fetchurl { inherit sha256 url; };

  pinentry =
    if config.gtk.enable then {
      packages = [ pkgs.pinentry-gnome pkgs.gcr ];
      name = "gnome3";
    } else {
      packages = [ pkgs.pinentry-curses ];
      name = "curses";
    };
in
{
  home.packages = pinentry.packages;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [
      "EE6FCD5EF119342E3A679BBA23A2A6BD2AC7ACC6"
      "05095B28F0B05E3C2EA1820655692ED47A6EA731"
    ];
    pinentryFlavor = pinentry.name;
    enableExtraSocket = true;
  };

  programs =
    let
      fixGpg = ''
        gpgconf --launch gpg-agent
      '';
    in
    {
      # Start gpg-agent if it's not running or tunneled in
      # SSH does not start it automatically, so this is needed to avoid having to use a gpg command at startup
      # https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
      bash.profileExtra = fixGpg;
      fish.loginShellInit = fixGpg;
      zsh.loginExtra = fixGpg;

      gpg = {
        enable = true;
        settings = {
          trust-model = "tofu+pgp";
        };
        publicKeys = [
          {
            source = fetchKey {
              url = "https://keys.openpgp.org/vks/v1/by-fingerprint/35655963B7835180125FE55DD7BCC570927C355B";
              sha256 = "sha256:0y683smdzz9zqa957dqny9k29vhap4k3i5fp5rzf1fwjnmc2ib2g";
            };
            trust = 5;
          }
          {
            source = fetchKey {
              url = "https://keys.openpgp.org/vks/v1/by-fingerprint/7C80BD2C48817A0B7AD6E0D04FF55C0369CABA69";
              sha256 = "sha256:1n7zy45667ddns50iaq6nfmkvzv1w5nvgs0d25if87zc67f1jmdv";
            };
            trust = 5;
          }
        ];
      };
    };
  # home.persistence = {
  #   "/persist/home/lukasz".directories = [ ".gnupg" ];
  # };

  # Link /run/user/$UID/gnupg to ~/.gnupg-sockets
  # So that SSH config does not have to know the UID
  systemd.user.services.link-gnupg-sockets = {
    Unit = {
      Description = "link gnupg sockets from /run to /home";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/ln -Tfs /run/user/%U/gnupg %h/.gnupg-sockets";
      ExecStop = "${pkgs.coreutils}/bin/rm $HOME/.gnupg-sockets";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
# vim: filetype=nix
