{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;

      persistBufferSort = true;

      # indicator.style = "underline";
      # hover.enabled = true;

      # button = "󰅙";
      # button = "󰅚";
      # modified.button = "󰀨";
      # inactive.modified.button = "󰗖";

      separatorStyle = "slant";
      closeIcon = "󰅚";
      bufferCloseIcon = "󰅙";
      modifiedIcon = "󰀨";
    };

    maps.normal = {
      # Reordering tabs
      "<m-s-j>" = "<cmd>BufferLineMoveNext<cr>";
      "<m-s-k>" = "<cmd>BufferLineMovePrev<cr>";
      "<m-p>" = "<cmd>BufferLineTogglePin<cr>";

      # Navigating tabs
      "<m-j>" = "<cmd>BufferLineCycleNext<cr>";
      "<m-k>" = "<cmd>BufferLineCyclePrev<cr>";
      "<m-1>" = "<cmd>BufferLineGoToBuffer 1<cr>";
      "<m-2>" = "<cmd>BufferLineGoToBuffer 2<cr>";
      "<m-3>" = "<cmd>BufferLineGoToBuffer 3<cr>";
      "<m-4>" = "<cmd>BufferLineGoToBuffer 4<cr>";
      "<m-5>" = "<cmd>BufferLineGoToBuffer 5<cr>";
      "<m-6>" = "<cmd>BufferLineGoToBuffer 6<cr>";
      "<m-7>" = "<cmd>BufferLineGoToBuffer 7<cr>";
      "<m-8>" = "<cmd>BufferLineGoToBuffer 8<cr>";
      "<m-9>" = "<cmd>BufferLineGoToBuffer 9<cr>";
      "<m-0>" = "<cmd>BufferLineGoToBuffer -1<cr>";

      # Close tab
      "<m-x>" = "<cmd>lua require('bufferline.commands').unpin_and_close()<cr>";
    };
  };
}
