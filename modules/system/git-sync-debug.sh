#!/usr/bin/env bash
set -euo pipefail

# Git Sync Debug Script
# Run: bash /etc/nixos/modules/system/git-sync-debug.sh

PORT=9876
SECRET="nix-git-sync-2026"
REPO_DIR="/etc/nixos"

echo "═══════════════════════════════════════════"
echo "  Git Sync Debug Report"
echo "═══════════════════════════════════════════"
echo ""

# ── Host Info ──────────────────────────────────
echo "── Host ──────────────────────────────────"
echo "Hostname: $(hostname)"
echo "IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'unknown')"
echo ""

# ── Systemd Services ──────────────────────────
echo "── Services ──────────────────────────────"
for svc in git-sync-listener git-sync-install-hook; do
  state=$(systemctl is-active "$svc" 2>/dev/null || echo "not-found")
  echo "  $svc: $state"
done
echo ""

# ── Listener Logs ─────────────────────────────
echo "── Listener Logs (last 20 lines) ─────────"
journalctl -u git-sync-listener --no-pager -n 20 2>/dev/null || echo "  No logs found"
echo ""

# ── Hook Install ──────────────────────────────
echo "── Post-commit Hook ──────────────────────"
HOOK_PATH="$REPO_DIR/.git/hooks/post-commit"
if [ -f "$HOOK_PATH" ]; then
  echo "  Installed: yes"
  echo "  Executable: $([ -x "$HOOK_PATH" ] && echo 'yes' || echo 'NO')"
  echo "  Content:"
  sed 's/^/    /' "$HOOK_PATH"
else
  echo "  Installed: NO (run: sudo systemctl start git-sync-install-hook)"
fi
echo ""

# ── UDP Port ──────────────────────────────────
echo "── UDP Port $PORT ────────────────────────"
if ss -uln | grep -q ":$PORT "; then
  echo "  Listening: yes"
  ss -ulnp "sport = :$PORT" 2>/dev/null | sed 's/^/    /'
else
  echo "  Listening: NO"
fi
echo ""

# ── Firewall ──────────────────────────────────
echo "── Firewall ──────────────────────────────"
if command -v nft &>/dev/null; then
  nft list ruleset 2>/dev/null | grep -i "$PORT" | sed 's/^/    /' || echo "  No rules for port $PORT"
else
  echo "  nft not available"
fi
echo ""

# ── Git Status ────────────────────────────────
echo "── Git ───────────────────────────────────"
cd "$REPO_DIR"
echo "  Branch: $(git branch --show-current)"
echo "  Remote: $(git remote get-url origin 2>/dev/null || echo 'none')"
echo "  Dirty: $(git status --porcelain | wc -l) uncommitted changes"
echo "  Last commit: $(git log -1 --format='%h %s (%ar)')"
echo ""

# ── Host Map ──────────────────────────────────
echo "── Host Map ──────────────────────────────"
declare -A HOST_MAP=(
  ["nixlensk323"]="192.168.1.146"
  ["nixlensk322"]="192.168.1.145"
  ["nixlensk321"]="192.168.1.80"
)
MY_HOSTNAME=$(hostname)
for name in "${!HOST_MAP[@]}"; do
  ip="${HOST_MAP[$name]}"
  marker=""
  [ "$name" = "$MY_HOSTNAME" ] && marker=" (this host)"
  echo "  $name → $ip$marker"
done
echo ""

# ── Connectivity ──────────────────────────────
echo "── Connectivity ──────────────────────────"
for name in "${!HOST_MAP[@]}"; do
  ip="${HOST_MAP[$name]}"
  [ "$name" = "$MY_HOSTNAME" ] && continue
  if ping -c 1 -W 1 "$ip" &>/dev/null; then
    echo "  $ip ($name): reachable"
  else
    echo "  $ip ($name): UNREACHABLE"
  fi
done
echo ""

# ── Test Signal ───────────────────────────────
echo "── Test UDP Signal ───────────────────────"
echo "  Send test signal to all OTHER hosts?"
read -rp "  [y/N] " confirm
if [[ "$confirm" =~ ^[yY] ]]; then
  for name in "${!HOST_MAP[@]}"; do
    ip="${HOST_MAP[$name]}"
    [ "$ip" = "${HOST_MAP[$MY_HOSTNAME]:-}" ] && continue
    if (echo -n "git-pull:${SECRET}" > /dev/udp/"$ip"/"$PORT") 2>/dev/null; then
      echo "  Sent to $ip ($name): ok"
    else
      echo "  Sent to $ip ($name): FAILED"
    fi
  done
else
  echo "  Skipped"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Done"
echo "═══════════════════════════════════════════"
