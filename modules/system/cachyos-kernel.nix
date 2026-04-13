{ pkgs, cachyos-kernel, ... }:

{
  # ────────────────────────────────────────────────────────
  # CachyOS Kernel Configuration
  # ────────────────────────────────────────────────────────

  # Use the CachyOS kernel with the BORE scheduler (popular for desktop performance)
  # wrapped in linuxPackagesFor to make it a full package set compatible with modules like v4l2loopback
  boot.kernelPackages = pkgs.linuxPackagesFor cachyos-kernel.packages.${pkgs.system}.linux-cachyos-bore;

  # Binary caches for the CachyOS kernel builds
  nix.settings = {
    substituters = [
      "https://ezkea.cachix.org"
    ];
    trusted-public-keys = [
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFvkZnI+5pD81vjD2Q="
    ];
  };
}
