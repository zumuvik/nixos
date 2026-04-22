let
  flake = builtins.getFlake (toString ./.);
  pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
in
  pkgs.vimPlugins.nvim-treesitter.meta.name
