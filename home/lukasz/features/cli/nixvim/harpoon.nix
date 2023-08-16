{
  programs.nixvim = {
    plugins.harpoon = {
      enable = true;
      keymaps.addFile = "<leader>a";
      keymaps.toggleQuickMenu = "<C-e>";
      keymaps.navFile = {
        "1" = "<C-1>";
        "2" = "<C-2>";
        "3" = "<C-3>";
        "4" = "<C-4>";
      };
    };
  };
}
