{ pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk321";

  # ────────────────────────────────────────────────────────
  # Disable TPM (no TPM chip)
  # ────────────────────────────────────────────────────────
  systemd.services.systemd-tpm2-setup.enable = false;
  systemd.sockets.systemd-tpm2-setup-auto.enable = false;

  # ────────────────────────────────────────────────────────
  # System packages (laptop-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];
}
