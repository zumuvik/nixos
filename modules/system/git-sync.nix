{ config, pkgs, lib, ... }:

let
  username = (import ../../lib).username;
in
{
  networking.firewall.allowedUDPPorts = [ 9876 ];

  # Install git post-commit hook
  systemd.services.git-sync-install-hook = {
    description = "Install git-sync post-commit hook";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/install -m 755 ${./git-sync-hook.sh} /etc/nixos/.git/hooks/post-commit";
    };
  };

  systemd.services.git-sync-listener = {
    description = "Git sync listener — auto git pull on UDP signal";
    after = [ "network-online.target" "git-sync-install-hook.service" ];
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
