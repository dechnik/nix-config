{ pkgs, ... }: {
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
    comma # Install and run programs by sticking a , before them
    # distrobox # Nice escape hatch, integrates docker images with my environment
    cryptsetup
    unzip
    zip
    just
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
    nixfmt-classic # Nix formatter
    nvd # Differ
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM
  ];
}
