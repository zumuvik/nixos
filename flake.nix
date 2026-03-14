{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    ayugram-desktop = {
      type = "git";
      submodules = true;
      url = "https://github.com/ndfined-crp/ayugram-desktop/";
    };

    # Если есть другие inputs — оставь их
  };

  outputs = { self, nixpkgs, ayugram-desktop, ... } @ inputs: {   # ← @ inputs здесь — важно для specialArgs
    nixosConfigurations.nixlensk323 = nixpkgs.lib.nixosSystem {   # ← имя = hostname!
      system = "x86_64-linux";  # если ARM — поменяй на aarch64-linux
      specialArgs = { inherit inputs; };  # ← ЭТО ФИКСИТ undefined 'inputs' !!!
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
