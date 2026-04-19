{ pkgs, config, lib, username, ... }:

let
  cfg = config.my.services.git-sync;
in
{
  options.my.services.git-sync.enable = lib.mkEnableOption "Git sync listener and post-commit hook";

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ 9876 ];

    # Install git post-commit hook
    systemd.services.git-sync-install-hook = {
      description = "Install git-sync post-commit hook";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/install -m 755 ${./hook.sh} /etc/nixos/.git/hooks/post-commit";
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
        ExecStart = "${pkgs.python3}/bin/python3 ${./listener.py}";
        Restart = "always";
        RestartSec = 5;
        WorkingDirectory = "/etc/nixos";
        EnvironmentFile = config.sops.secrets."git_sync_env".path;
        Environment = [
          "HOME=/home/${username}"
          "PATH=${pkgs.git}/bin:${pkgs.python3}/bin:/run/current-system/sw/bin"
        ];
      };
    };
  };
}
