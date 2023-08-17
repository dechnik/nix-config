{ pkgs, ... }: {
  programs.nixvim = {
    plugins.telescope.enable = true;

    plugins.telescope.enabledExtensions = [ "ui-select" "projects" ];
    plugins.telescope.extensionConfig.ui-select = {};

    plugins.telescope.extensions.frecency.enable = true;
    plugins.telescope.extensions.fzf-native.enable = true;
    #plugins.telescope.extensions.media_files.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      project-nvim
    ];

    maps.normal = {
      "<leader>pf" = "<cmd>Telescope find_files<cr>";
      "<leader>ps" = "<cmd>Telescope live_grep<cr>";
      "<leader>pb" = "<cmd>Telescope buffers<cr>";
      "<leader>pp" = "<cmd>Telescope projects<cr>";
      "<leader>ph" = "<cmd>Telescope help_tags<cr>";

      "<c-p>" = "<cmd>Telescope find_files<cr>";
      "<c-s-p>" = "<cmd>Telescope commands<cr>";
      "<c-k>" = "<cmd>Telescope buffers<cr>";
      "<c-s-k>" = "<cmd>Telescope keymaps<cr>";
    };
  };
}
