{ config, lib, pkgs, inputs, lib', ... }:

{
  options.my.services.valera-box = {
    enable = lib.mkEnableOption "Valera Box Container";
  };

  config = lib.mkIf config.my.services.valera-box.enable {
    networking.nat = {
      enable = true;
      externalInterface = "ens18";
      internalInterfaces = [ "ve-valera-box" ];
    };

    containers.valera-box = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      forwardPorts = [
        { protocol = "tcp"; hostPort = 2222; containerPort = 22; }
        { protocol = "tcp"; hostPort = 8081; containerPort = 80; }
      ];

      config = { config, pkgs, ... }: {
        boot.isContainer = true;
        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
          settings.PermitRootLogin = "no";
        };

        services.mediawiki = {
          enable = true;
          name = "Просто вики";
          passwordFile = "/var/keys/mediawiki-admin-pass";
          url = "http://45.13.237.210:8081";
          httpd.virtualHost = {
            hostName = "45.13.237.210";
            adminAddr = "admin@localhost";
          };
          extraConfig = ''
            $wgMetaNamespace = "Служебка";
          '';
        };

        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.registry.nixpkgs.flake = inputs.nixpkgs;
        nix.nixPath = [ "nixpkgs=''${inputs.nixpkgs}" ];

        users.users.mascot_valera = {
          isNormalUser = true;
          description = "Mascot Valera";
          openssh.authorizedKeys.keys = lib'.extraKeys.mascot_valera;
          extraGroups = [ ];
        };

        networking.firewall.allowedTCPPorts = [ 22 ];
        system.stateVersion = "24.11";
      };
    };
  };
}