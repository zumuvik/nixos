{ pkgs, username, lib', ... }:

{
  modules.desktop.enable = true;
  modules.bluetooth.enable = true;

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
  # Sops-nix (управление секретами)
  # ────────────────────────────────────────────────────────
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."git_sync_env" = {};

  # ────────────────────────────────────────────────────────
  # System packages (laptop-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    osu-lazer-bin
  ];
}
