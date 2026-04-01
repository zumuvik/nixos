{ config, pkgs, lib, ... }:

let
  username = (import ../../lib).username;
in
{
  networking.firewall.allowedUDPPorts = [ 9876 ];

  systemd.services.git-sync-listener = {
    description = "Git sync listener — auto git pull on UDP signal";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ git python3 ];

    serviceConfig = {
      Type = "simple";
      User = username;
      Group = "users";
      ExecStart = "${pkgs.python3}/bin/python3 ${./git-sync-listener.py}";
      Restart = "always";
      RestartSec = 5;
      WorkingDirectory = "/etc/nixos";
      Environment = [
        "HOME=/home/${username}"
        "PATH=${pkgs.git}/bin:${pkgs.python3}/bin:/run/current-system/sw/bin"
      ];
    };
  };
}
