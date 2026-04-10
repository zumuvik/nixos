_: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/sites
    ../../modules/system/wg-easy.nix
  ];
}
