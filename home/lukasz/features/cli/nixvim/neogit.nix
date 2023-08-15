{ pkgs, ... }: {
  programs.nixvim = {
    plugins.neogit = {
      enable = true;
      autoRefresh = true;
      useMagitKeybindings = true;
    };
    maps.normal = {
      "<leader>gg" = "<cmd>Neogit<cr>";
    };
  };
}
