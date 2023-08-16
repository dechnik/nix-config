{ inputs, ...}:
{
  imports = [
    ./languages.nix
    ./telescope.nix
    ./which-key.nix
    ./neogit.nix
    ./treesitter.nix
    ./harpoon.nix
    ./nvim-tree.nix
    ./nvim-cmp.nix
    ./bufferline.nix
    ./trouble.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs.nixvim = {
    enable = true;

    colorschemes.gruvbox.enable = true;
    luaLoader.enable = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    options = {
      # Mouse support
      mouse = "a";
      mousemoveevent = true;

      # Background
      background = "dark";

      # Enable filetype indentation
      #filetype plugin indent on

      termguicolors = true;

      # Line Numbers
      number = true;
      relativenumber = true;

      # Spellcheck
      spelllang = "en_us";

      # Use X clipboard
      clipboard = "unnamedplus";

      # Some defaults
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      # backupdir = "~/.config/nvim/backup";
      # directory = "~/.config/nvim/swap";
      # undodir = "~/.config/nvim/undo";
      #
    };

    maps = {
      # Disable middle-click paste (triggers when scrolling with trackpoint)
      normalVisualOp."<MiddleMouse>" = "<nop>";
      insert."<MiddleMouse>" = "<nop>";
    };

    plugins.specs = {
      enable = true;
      color = "#ff00ff";
    };

    plugins.notify = {
      enable = true;
      backgroundColour = "#00000000";
    };

    editorconfig.enable = true;
    plugins.trouble.enable = true;

    plugins.lualine = {
      enable = true;
      sections = {
        lualine_c = [
          {
            extraConfig = {
              path = 1;
              newfile_status = true;
            };
          }
        ];
      };
    };
  };
}
