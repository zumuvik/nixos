{ ... }: {
  nix.settings = { 
    substituters = [ 
      "https://cache.nixos.org" 
      "https://xddxdd.cachix.org" 
      "https://nix-cachyos-kernel.cachix.org" 
    ]; 
    trusted-public-keys = [ 
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" 
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=" 
      "nix-cachyos-kernel.cachix.org-1:709cn79S9L2XYD6B2S6mE6fF8n+yH5/S12CfS+J4mRM=" 
    ]; 
  };
  imports = [
    ./services/nginx
    ./services/nh.nix
    ./services/3x-ui.nix
    ./services/heroku-bot.nix
    ./services/crafty.nix
    ./services/valent.nix
    ./services/wingsv-panel.nix
    ./hardware
    ./gaming.nix
    ./ui
  ];
}
