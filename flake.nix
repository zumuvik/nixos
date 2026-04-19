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

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cachyos-kernel = {
      url = "github:drakon64/nixos-cachyos-kernel";
    };
  };

  outputs = { nixpkgs, home-manager, self, ags, grub2-themes, sops-nix, nixos-cachyos-kernel, ... } @ inputs:
  let
    lib = import ./lib;
    inherit (lib) username;

    makeHost = { hostName }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs username hostName;
          inherit ags grub2-themes;
          lib' = lib;
        };

        modules = [
          sops-nix.nixosModules.sops
          nixos-cachyos-kernel.nixosModules.default
          ./hosts/${hostName}/default.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          grub2-themes.nixosModules.default

          ( { config, ... }: {
            home-manager = {
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username hostName; my = config.my; inherit (config) modules; };
              users.${username} = import ./home.nix;
            };
          } )
        ];
      };

  in
  {
    nixosConfigurations = {
      nixlensk323 = makeHost {
        hostName = "nixlensk323";
      };

      nixlensk322 = makeHost {
        hostName = "nixlensk322";
      };

      nixlensk321 = makeHost {
        hostName = "nixlensk321";
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