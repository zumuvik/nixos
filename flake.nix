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

  outputs = { self, nixpkgs, home-manager, grub2-themes, ... } @ inputs:
  let
    lib = import ./lib;
    username = lib.username;

    makeNixosHost = { hostName, enableSteam ? false, enableBluetooth ? false, enableRouter ? false }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs username;
          inherit grub2-themes;
        };

        modules = [
          ./hosts/${hostName}
          ./configuration.nix
          home-manager.nixosModules.home-manager
          grub2-themes.nixosModules.default

          # System modules
          ./modules/system/services.nix
          ./modules/system/hardware.nix

          # Home Manager configuration
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.users.${username} = import ./home.nix;
          }

          # Conditional system modules
        ] ++ (nixpkgs.lib.optionals enableBluetooth [
          ./modules/system/bluetooth.nix
        ]) ++ (nixpkgs.lib.optionals enableRouter [
          ./modules/system/router.nix
        ]);
      };

  in
  {
    nixosConfigurations = {
      nixlensk323 = makeNixosHost {
        hostName = "nixlensk323";
        enableSteam = true;
        enableBluetooth = true;
      };

      nixlensk322 = makeNixosHost {
        hostName = "nixlensk322";
        enableRouter = true;
      };

      samolensk321 = makeNixosHost {
        hostName = "samolensk321";
      };
    };

    templates.basic = {
      description = "Basic NixOS host template";
      path = ./hosts/template;
    };
  };
}
