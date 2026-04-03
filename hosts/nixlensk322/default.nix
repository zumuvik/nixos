{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/sites
  ];
}
