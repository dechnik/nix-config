{ pkgs, ... }:
let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      black
      mypy
      tldextract # required by qute-pass
      pylatexenc
    ]
  );
in
{
  imports = [
    ./atuin.nix
    ./bash.nix
    ./bat.nix
    ./fish.nix
    ./zsh.nix
    ./fzf.nix
    ./git.nix
    ./gpg.nix
    ./k3s.nix
    ./lf.nix
    ./gh.nix
    # ./neovim.nix
    # ./nixvim/neovim.nix
    # ./nixcats
    ./nvf.nix
    ./direnv.nix
    ./nix-index.nix
    # ./pfetch.nix
    ./ranger
    ./lyrics.nix
    # ./screen.nix
    ./shellcolor.nix
    ./ssh.nix
    # ./spotifytui.nix
    ./starship.nix
    ./xpo.nix
    ./tmux.nix
    ./zoxide.nix
    ./yazi.nix
  ];
  home.packages = with pkgs; [
    pythonEnv
    pkgs.inputs.attic.default
    comma # Install and run programs by sticking a , before them
    # distrobox # Nice escape hatch, integrates docker images with my environment
    cryptsetup
    unzip
    zip
    just
    jless
    # magic-wormhole

    bc # Calculator
    bottom # System viewer
    ncdu # TUI disk usage
    eza # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    jq # JSON pretty printer and manipulator
    # trekscii # Cute startrek cli printer
    kubectl

    nil # Nix LSP
    nixfmt-rfc-style
    nvd # Differ
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM
  ];
}
