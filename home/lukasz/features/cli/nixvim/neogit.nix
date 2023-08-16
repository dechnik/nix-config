{ pkgs, ... }: {
  programs.nixvim = {
    plugins.neogit = {
      enable = true;
      autoRefresh = true;
      useMagitKeybindings = true;
      integrations = {
        diffview = true;
      };
    };
    maps.normal = {
      "<leader>gg" = "<cmd>Neogit<cr>";
      "<leader>gd" = "<cmd>DiffviewOpen<cr>";
    };
  };
}
