{
  programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      diagnostics.enable = true;
      git.enable = true;
      updateFocusedFile.enable = true;
    };
    maps.normal = {
      "<leader>op" = {
        action = "<cmd>NvimTreeToggle<cr>";
        desc = "Project View";
      };
    };
  };
}
