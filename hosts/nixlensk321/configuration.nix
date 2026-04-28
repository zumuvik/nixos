{ pkgs, username, lib', ... }:

{
  my.profiles.desktop.enable = true;
  my.hardware.amdgpu.enable = true;
  my.hardware.bluetooth.enable = true;
  my.hardware.laptop.enable = true;
  my.hardware.kernel-zen.enable = false;
  my.hardware.kernel-cachy.enable = true;
  my.hardware.zram.enable = true;

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

  users.users.${username}.extraGroups = [ "video" "render" ];
}
