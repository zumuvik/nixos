{ pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # System Kernel Configuration
  # ────────────────────────────────────────────────────────

  # Use the Zen kernel (high-performance deskop kernel, officially cached)
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Standard Nix settings are sufficient as Zen is in the official NixOS binary cache
}
