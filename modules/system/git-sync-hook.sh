#!/usr/bin/env bash
# Post-commit hook: send UDP signal to OTHER hosts, then push

REPO_DIR="/etc/nixos"
PORT=9876
MY_HOSTNAME=$(hostname)

# Map hostnames to IPs
declare -A HOST_MAP=(
    ["nixlensk323"]="192.168.1.146"
    ["nixlensk322"]="192.168.1.145"
    ["nixlensk321"]="192.168.1.80"
)

MY_IP="${HOST_MAP[$MY_HOSTNAME]}"

# Send UDP signal only to OTHER hosts
for HOST_NAME in "${!HOST_MAP[@]}"; do
    HOST_IP="${HOST_MAP[$HOST_NAME]}"
    if [[ "$HOST_IP" != "$MY_IP" ]]; then
        (echo -n "git-pull" > /dev/udp/"$HOST_IP"/"$PORT") 2>/dev/null || true
    fi
done

# Push to remote (no pull needed — we just committed)
cd "$REPO_DIR" && git push 2>/dev/null || true
