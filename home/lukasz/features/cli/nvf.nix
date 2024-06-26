{ pkgs, inputs, ... }:
let
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
in
{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];
  programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        debugMode = {
          enable = false;
          level = 16;
          logFile = "/tmp/nvim.log";
        };
        withNodeJs = true;
        withPython3 = true;
        python3Packages = [
        ];
        lsp = {
          formatOnSave = false;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = false;
          nvimCodeActionMenu.enable = false;
          trouble.enable = true;
          lspSignature.enable = true;
          lsplines.enable = false;
          nvim-docs-view.enable = false;
        };
        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          # Nim LSP is broken on Darwin and therefore
          # should be disabled by default. Users may still enable
          # `vim.languages.vim` to enable it, this does not restrict
          # that.
          # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
          nim.enable = false;

          nix.enable = true;

          markdown.enable = false;
          html.enable = false;
          css.enable = false;
          sql.enable = false;
          java.enable = false;
          ts.enable = false;
          svelte.enable = false;
          go.enable = false;
          elixir.enable = false;
          zig.enable = false;
          ocaml.enable = false;
          python.enable = true;
          dart.enable = false;
          bash.enable = true;
          tailwind.enable = false;
          typst.enable = false;
          clang = {
            enable = false;
            lsp.server = "clangd";
          };

          rust = {
            enable = true;
            crates.enable = false;
          };
        };
        visuals = {
          enable = true;
          nvimWebDevicons.enable = true;
          scrollBar.enable = false;
          smoothScroll.enable = false;
          cellularAutomaton.enable = false;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;

          indentBlankline = {
            enable = true;
            fillChar = null;
            eolChar = null;
            scope = {
              enabled = true;
            };
          };

          cursorline = {
            enable = true;
            lineTimeout = 0;
          };
        };
        statusline = {
          lualine = {
            enable = true;
            theme = "gruvbox";
          };
        };
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
          transparent = false;
        };
        autopairs.enable = true;
        autocomplete = {
          enable = true;
          type = "nvim-cmp";
          sources = {
            cody = "[Cody]";
          };
        };
        filetree = {
          nvimTree = {
            enable = true;
            openOnSetup = false;
          };
        };
        tabline = {
          nvimBufferline.enable = true;
        };
        treesitter.context.enable = true;
        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };
        telescope.enable = true;
        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
        };
        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = false; # lighter, faster, and uses lua for configuration
        };
        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = true;
        };
        notify = {
          nvim-notify.enable = true;
        };
        projects = {
          project-nvim.enable = false;
        };
        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          icon-picker.enable = false;
          surround.enable = false;
          diffview-nvim.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
          };

          images = {
            image-nvim.enable = false;
          };
        };
        notes = {
          obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
          orgmode.enable = false;
          mind-nvim.enable = false;
          todo-comments.enable = true;
        };
        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };
        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          modes-nvim.enable = false; # the theme looks terrible with catppuccin
          illuminate.enable = true;
          breadcrumbs = {
            enable = false;
            navbuddy.enable = false;
          };
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = 110;
              ruby = 120;
              java = 130;
              go = [90 130];
            };
          };
        };
        assistant = {
          chatgpt.enable = false;
          copilot = {
            enable = false;
            cmp.enable = false;
          };
        };
        session = {
          nvim-session-manager.enable = false;
        };

        gestures = {
          gesture-nvim.enable = false;
        };

        comments = {
          comment-nvim.enable = true;
        };

        presence = {
          neocord.enable = false;
        };
        startPlugins = [
          pkgs.vimPlugins.oil-nvim
          inputs.sg-nvim.packages.${pkgs.system}.sg-nvim
        ];
        luaConfigRC = {
          oil-nvim= entryAnywhere ''
            require("oil").setup({
              columns = {
                "icon",
                "permissions",
                "size",
                -- "mtime",
              },
              keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-s>"] = "actions.select_vsplit",
                ["<C-h>"] = "actions.select_split",
                ["<C-t>"] = "actions.select_tab",
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = "actions.close",
                ["<C-l>"] = "actions.refresh",
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["`"] = "actions.cd",
                ["~"] = "actions.tcd",
                ["gs"] = "actions.change_sort",
                ["gx"] = "actions.open_external",
                ["g."] = "actions.toggle_hidden",
                ["g\\"] = "actions.toggle_trash",
              },
            })
          '';
          sg-nvim= entryAnywhere ''
            require("sg").setup({
              enable_cody = true,
            })
          '';
        };
        maps.normal = {
          "-" = {
            action = "<cmd>Oil<CR>";
            silent = true;
            desc = "Open Parent Directory";
          };
          "<leader>-" = {
            action = "<cmd>Oil .<CR>";
            silent = true;
            desc = "Open nvim root directory";
          };
        };
      };
    };
  };
  home = {
    packages = [
      inputs.sg-nvim.packages.${pkgs.system}.default
    ];
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
