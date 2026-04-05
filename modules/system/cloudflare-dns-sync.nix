{ config, lib, pkgs, ... }:
let
  cfg = config.services.cloudflare-dns-sync;
  domainsJson = builtins.toJSON cfg.domains;
in
{
  options.services.cloudflare-dns-sync = {
    enable = lib.mkEnableOption "Cloudflare DNS sync service";
    apiToken = lib.mkOption { type = lib.types.str; };
    checkInterval = lib.mkOption { type = lib.types.str; default = "hourly"; };
    domains = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          zone = lib.mkOption { type = lib.types.str; };
          records = lib.mkOption { type = lib.types.listOf lib.types.str; };
        };
      });
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.timers.cloudflare-dns-sync = {
      description = "Cloudflare DNS sync timer";
      timerConfig.OnCalendar = cfg.checkInterval;
      wantedBy = [ "timers.target" ];
    };
    systemd.services.cloudflare-dns-sync = {
      description = "Sync DNS A records to current public IP";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "5m";
        Environment = "CLOUDFLARE_API_TOKEN=${cfg.apiToken}";
        ExecStart = pkgs.writeShellScript "cloudflare-dns-sync" ''
          set -euo pipefail
          API_TOKEN="$CLOUDFLARE_API_TOKEN"
          CURL=${pkgs.curl}/bin/curl
          CURRENT_IP=$($CURL -s https://ifconfig.me)
          DOMAINS='${domainsJson}'
          update_record() {
            local zone_name="$1" record_name="$2"
            zone_id=$($CURL -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" \
              -H "Authorization: Bearer $API_TOKEN" -H "Content-Type: application/json" | \
              ${pkgs.jq}/bin/jq -r '.result[0].id // empty')
            [ -z "$zone_id" ] && echo "[ERROR] Zone not found: $zone_name" && return 1
            record_id=$($CURL -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$record_name.$zone_name&type=A" \
              -H "Authorization: Bearer $API_TOKEN" -H "Content-Type: application/json" | \
              ${pkgs.jq}/bin/jq -r '.result[0].id // empty')
            if [ -z "$record_id" ]; then
              $CURL -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
                -H "Authorization: Bearer $API_TOKEN" -H "Content-Type: application/json" \
                --data "{\"type\":\"A\",\"name\":\"$record_name.$zone_name\",\"content\":\"$CURRENT_IP\",\"ttl\":300,\"proxied\":false}" | \
                ${pkgs.jq}/bin/jq -r '.success // false' | grep -q true && \
                echo "[OK] Created $record_name.$zone_name -> $CURRENT_IP"
            else
              old_ip=$($CURL -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
                -H "Authorization: Bearer $API_TOKEN" | ${pkgs.jq}/bin/jq -r '.result.content')
              [ "$old_ip" != "$CURRENT_IP" ] && \
                $CURL -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
                  -H "Authorization: Bearer $API_TOKEN" -H "Content-Type: application/json" \
                  --data "{\"type\":\"A\",\"name\":\"$record_name.$zone_name\",\"content\":\"$CURRENT_IP\",\"ttl\":300,\"proxied\":false}" | \
                  ${pkgs.jq}/bin/jq -r '.success // false' | grep -q true && \
                  echo "[OK] Updated $record_name.$zone_name -> $CURRENT_IP" || \
                echo "[OK] $record_name.$zone_name is already $CURRENT_IP"
            fi
          }
          echo "[INFO] Current public IP: $CURRENT_IP"
          echo "$DOMAINS" | ${pkgs.jq}/bin/jq -c '.[]' | while read -r zone; do
            zone_name=$(echo "$zone" | ${pkgs.jq}/bin/jq -r '.zone')
            for record in $(echo "$zone" | ${pkgs.jq}/bin/jq -r '.records[]'); do
              update_record "$zone_name" "$record" || true
            done
          done
        '';
      };
    };
    environment.systemPackages = with pkgs; [ curl jq ];
  };
}
