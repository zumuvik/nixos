_:{
   programs.nixvim = {
     enable = true;
     defaultEditor = true;

     opts = {
       number = true;
       relativenumber = true;
       tabstop = 2;
       shiftwidth = 2;
       expandtab = true;
       ignorecase = true;
       smartcase = true;
       cursorline = true;
       termguicolors = true;
       signcolumn = "yes";
       mouse = "a";
       clipboard = "unnamedplus";
       undofile = true;
       swapfile = false;
     };

     globals.mapleader = " ";

     keymaps = [
       { mode = "n"; key = "<leader>w"; action = "<cmd>w<CR>"; }
       { mode = "n"; key = "<leader>q"; action = "<cmd>q<CR>"; }
     ];

     colorschemes.gruvbox = {
       enable = true;
       settings.contrast = "hard";
     };

     plugins = {
       web-devicons.enable = true;
       lualine.enable = true;
       treesitter.enable = true;
       neo-tree.enable = true;
       telescope.enable = true;
       which-key.enable = true;

       lsp = {
         enable = true;
         servers = {
           nixd.enable = true;
           bashls.enable = true;
         };
       };

       cmp = {
         enable = true;
         autoEnableSources = true;
       };
     };

     viAlias = true;
     vimAlias = true;
   };
}
