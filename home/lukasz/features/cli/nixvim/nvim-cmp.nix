{
  programs.nixvim = {
    plugins.nvim-cmp = {
      enable = true;
      preselect = "None";
      snippet.expand = "luasnip";
      sources = [
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "path"; }
        { name = "dictionary"; }
        { name = "buffer"; }
        { name = "nvim_lsp_signature_help"; }
        { name = "nvim_lua"; }
      ];
      formatting = {
        fields = [ "abbr" "kind" "menu" ];
      };
      mappingPresets = [ "insert" "cmdline" ];
      mapping."<CR>".modes = [ "i" "s" "c" ];
      mapping."<CR>".action = ''
        function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end
      '';
    };
  };
}
