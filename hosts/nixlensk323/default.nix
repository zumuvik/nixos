{ config, pkgs, inputs, ... }: {
  imports = [
    ../../configuration.nix
    ./configuration.nix
  ];
}
