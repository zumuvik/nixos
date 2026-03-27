{ config, pkgs, ... }: {
  # ────────────────────────────────────────────────────────
  # Audio (PipeWire)
  # ────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # ────────────────────────────────────────────────────────
  # SSH
  # ────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # ────────────────────────────────────────────────────────
  # Bluetooth
  # ────────────────────────────────────────────────────────
  services.blueman.enable = true;

  # ────────────────────────────────────────────────────────
  # VPN
  # ────────────────────────────────────────────────────────
  networking.wireguard.enable = true;

  # ────────────────────────────────────────────────────────
  # D-Bus
  # ────────────────────────────────────────────────────────
  services.dbus.enable = true;

  # ────────────────────────────────────────────────────────
  # XDG Desktop Portal (для Wayland)
  # ────────────────────────────────────────────────────────
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
}
