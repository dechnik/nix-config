{ inputs, ... }: {
  imports = [
    ./global
    ./features/cli/weechat.nix
  ];
  colorscheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;
}
