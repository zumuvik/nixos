{
  description = "NixOS configuration for zumuvik's machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixcord.url = "github:FlameFlag/nixcord";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ayugram-desktop = {
      type = "git";
      submodules = true;
      url = "https://github.com/ndfined-crp/ayugram-desktop/";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };
  };

  outputs = { nixpkgs, home-manager, ayugram-desktop, ags, grub2-themes, ... } @ inputs:
  let
    lib = import ./lib;
    inherit (lib) username;

    makeHost = { hostName, enableBluetooth ? false, enableRouter ? false }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs username hostName;
          inherit ayugram-desktop ags grub2-themes;
          lib' = lib;
        };

        modules = [
          ./hosts/${hostName}/default.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          grub2-themes.nixosModules.default

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username hostName; };
              users.${username} = import ./home.nix;
            };
          }
        ] ++ (nixpkgs.lib.optionals enableBluetooth [
          ./modules/system/bluetooth.nix
        ]) ++ (nixpkgs.lib.optionals enableRouter [
          ./modules/system/router.nix
        ]);
      };

  in
  {
    nixosConfigurations = {
      nixlensk323 = makeHost {
        hostName = "nixlensk323";
        enableBluetooth = true;
      };

      nixlensk322 = makeHost {
        hostName = "nixlensk322";
      };

      nixlensk321 = makeHost {
        hostName = "nixlensk321";
        enableBluetooth = true;
      };
    };

    nixosModules = {
      base-system = {
        imports = [
          ./configuration.nix
        ];
      };
    };

    templates.basic = {
      description = "Basic NixOS host template";
      path = ./hosts/template;
    };
  };
}
