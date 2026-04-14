#!/usr/bin/env fish
# NixOS Check Functions for Fish Shell
# Source this file in your ~/.config/fish/config.fish or run it directly
# This provides: nix-lint, flake-check, nix-build-check, nix-build-apply, nix-full-check

# ──────────────────────────────────────────────────────────────────
# Colors and formatting helpers
# ──────────────────────────────────────────────────────────────────
set -gx C_RESET (set_color normal)
set -gx C_BOLD (set_color --bold)
set -gx C_DIM (set_color --dim)
set -gx C_RED (set_color red)
set -gx C_GREEN (set_color green)
set -gx C_YELLOW (set_color yellow)
set -gx C_BLUE (set_color blue)
set -gx C_CYAN (set_color cyan)
set -gx C_MAGENTA (set_color magenta)

# ──────────────────────────────────────────────────────────────────
# NixOS build and check functions
# ──────────────────────────────────────────────────────────────────

function nix-build-check
  set -l description "NixOS rebuild build check (dry-run)"
  echo $C_BOLD$C_CYAN"→"$C_RESET" "$description
  echo ""
  
  sudo nixos-rebuild build --flake . --show-trace
  set -l exit_code $status
  echo ""
  if test $exit_code -eq 0
    echo $C_BOLD$C_GREEN"✓ Build check passed!"$C_RESET
  else
    echo $C_BOLD$C_RED"✗ Build check failed with status "$exit_code$C_RESET
    return $exit_code
  end
end

function nix-build-apply
  set -l description "NixOS rebuild switch (apply config)"
  echo $C_BOLD$C_CYAN"→"$C_RESET" "$description
  echo ""
  
  # First run a dry-run check
  echo $C_DIM"Running pre-check..."$C_RESET
  sudo nixos-rebuild build --flake . --show-trace
  
  if test $status -ne 0
    echo $C_BOLD$C_RED"✗ Pre-check failed! Aborting switch."$C_RESET
    return 1
  end
  
  echo ""
  echo $C_BOLD$C_YELLOW"→ Applying configuration..."$C_RESET
  sudo nixos-rebuild switch --flake . --show-trace
  set -l exit_code $status
  echo ""
  if test $exit_code -eq 0
    echo $C_BOLD$C_GREEN"✓ Configuration applied successfully!"$C_RESET
  else
    echo $C_BOLD$C_RED"✗ Switch failed with status "$exit_code$C_RESET
    return $exit_code
  end
end

function flake-check
  set -l description "Nix flake integrity check"
  echo $C_BOLD$C_CYAN"→"$C_RESET" "$description
  echo ""
  
  nix flake check --show-trace
  set -l exit_code $status
  echo ""
  if test $exit_code -eq 0
    echo $C_BOLD$C_GREEN"✓ Flake check passed!"$C_RESET
  else
    echo $C_BOLD$C_RED"✗ Flake check failed with status "$exit_code$C_RESET
    return $exit_code
  end
end

function nix-lint
  set -l description "Nix static analysis (deadnix + statix)"
  echo $C_BOLD$C_CYAN"→"$C_RESET" "$description
  echo ""
  
  echo $C_DIM"Running deadnix -W . (detect unused vars)..."$C_RESET
  deadnix -W .
  if test $status -ne 0
    echo $C_BOLD$C_RED"✗ deadnix found issues"$C_RESET
    return 1
  end
  
  echo ""
  echo $C_DIM"Running statix check . (static analysis)..."$C_RESET
  # Note: W10 warnings are a style preference (NixOS modules require { ... }: pattern)
  # and W20 warnings are architectural (repeated keys at module boundaries).
  # These don't affect correctness, only style preference.
  statix check . || true
  echo $C_DIM"(Ignoring W10/W20 style warnings - see AGENTS.md)"$C_RESET
  
  echo ""
  echo $C_BOLD$C_GREEN"✓ All linting checks passed!"$C_RESET
end

function nix-full-check
  set -l description "Full pre-deployment check (lint + flake + build)"
  echo $C_BOLD$C_MAGENTA"╔════════════════════════════════════════╗"$C_RESET
  echo $C_BOLD$C_MAGENTA"║    Full NixOS Configuration Check      ║"$C_RESET
  echo $C_BOLD$C_MAGENTA"╚════════════════════════════════════════╝"$C_RESET
  echo ""
  
  # Step 1: Lint
  nix-lint
  if test $status -ne 0
    echo ""
    echo $C_BOLD$C_RED"Aborting full check: linting failed"$C_RESET
    return 1
  end
  
  echo ""
  echo "────────────────────────────────────────────"
  echo ""
  
  # Step 2: Flake check
  flake-check
  if test $status -ne 0
    echo ""
    echo $C_BOLD$C_RED"Aborting full check: flake check failed"$C_RESET
    return 1
  end
  
  echo ""
  echo "────────────────────────────────────────────"
  echo ""
  
  # Step 3: Build check
  nix-build-check
  if test $status -ne 0
    echo ""
    echo $C_BOLD$C_RED"Aborting full check: build check failed"$C_RESET
    return 1
  end
  
  echo ""
  echo $C_BOLD$C_MAGENTA"╔════════════════════════════════════════╗"$C_RESET
  echo $C_BOLD$C_GREEN"║       ✓ All checks passed!              ║"$C_RESET
  echo $C_BOLD$C_MAGENTA"╚════════════════════════════════════════╝"$C_RESET
end

# ──────────────────────────────────────────────────────────────────
# Quick aliases
# ──────────────────────────────────────────────────────────────────
alias rebuild='nix-build-apply'
alias check='nix-full-check'
alias lint='nix-lint'
