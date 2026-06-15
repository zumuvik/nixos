{ ... }: {
  nix.settings = { 
    substituters = [
      "https://cache.nixos.org"
      "https://cache.garnix.io"
      "https://xddxdd.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];  };
  imports = [
    ./services/nginx
    ./services/nginx/play-site.nix
    ./services/nh.nix
    ./services/3x-ui.nix
    ./services/valera-box.nix
    ./services/heroku-bot.nix
    ./services/crafty.nix
    ./services/valent.nix
    ./services/wingsv-panel.nix
    ./hardware
    ./gaming.nix
    ./ui
  ];
}
